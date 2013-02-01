;; generally the indentation of a line is determined by its preceding line
(defun cubescript-calculate-from-previous ()
  (beginning-of-line)
  (let ((current (current-indentation)))
    (if (looking-at ".*\\[[^][]*$")
        (+ current tab-width)
      current)))

;; sometimes the content of a line affects its own indentation
(defun cubescript-calculate-from-current ()
  (beginning-of-line)
  (if (looking-at "^\\s-*]")
      (- tab-width)
    0))

(defun cubescript-calculate-indent ()
  (save-excursion
    (let ((adjust (cubescript-calculate-from-current)))
      (forward-line -1)
      (while (looking-at "^\\s-*$")
        (forward-line -1))
      (+ adjust (cubescript-calculate-from-previous)))))

(defun cubescript-indent-line ()
  (let ((indent (cubescript-calculate-indent)))
    (save-excursion (indent-line-to indent))
    (goto-char (max (point) (+ (point-at-bol) indent)))))

(defconst cubescript-symbols "?<>/!@%^&|*+-=~")
(defvar cubescript-mode-syntax-table
  (let ((table (make-syntax-table)))
    (mapc #'(lambda (c)
              (modify-syntax-entry c "_" table))
          cubescript-symbols)
    (modify-syntax-entry ?\{ "." table)
    (modify-syntax-entry ?\} "." table)
    (modify-syntax-entry ?\/ ". 12a" table)
    (modify-syntax-entry ?\n "> a" table)
    (modify-syntax-entry ?\^m "> a" table)
    table))

(defconst cubescript-operators-regexp
  (regexp-opt
   '("?"
     "+"
     "*"
     "-"
     "+f"
     "*f"
     "-f"
     "="
     "!="
     "<"
     ">"
     "<="
     ">="
     "=f"
     "!=f"
     "<f"
     ">f"
     "<=f"
     ">=f"
     "^"
     "!"
     "&"
     "|"
     "~"
     "^~"
     "&~"
     "|~"
     "<<"
     ">>"
     "&&"
     "||"
     "=s"
     "!=s"
     "<s"
     ">s"
     "<=s"
     ">=s") 'symbols))

(defconst cubescript-builtin-regexp
  (regexp-opt
   '("nodebug"
     "push"
     "resetvar"
     "alias"
     "writecfg"
     "do"
     "if"
     "loop"
     "loopwhile"
     "while"
     "loopconcat"
     "loopconcatword"
     "exec"
     "result"
     "concat"
     "concatword"
     "format"
     "at"
     "escape"
     "unescape"
     "stripcolors"
     "substr"
     "sublist"
     "listlen"
     "getalias"
     "getvarmin"
     "getvarmax"
     "getfvarmin"
     "getfvarmax"
     "prettylist"
     "listsplice"
     "listdel"
     "indexof"
     "listfind"
     "looplist"
     "loopfiles"
     "sortlist"
     "div"
     "mod"
     "divf"
     "modf"
     "sin"
     "cos"
     "tan"
     "asin"
     "acos"
     "atan"
     "sqrt"
     "pow"
     "loge"
     "log2"
     "log10"
     "exp"
     "min"
     "max"
     "minf"
     "maxf"
     "abs"
     "absf"
     "cond"
     "name"
     "case"
     "casef"
     "cases"
     "rnd"
     "strcmp"
     "echo"
     "error"
     "strstr"
     "strlen"
     "strreplace"
     "getmillis"
     "sleep"
     "clearsleep") 'words))

(defconst cubescript-ident-regexp
  "[@$][^][\"/;() \t\r\n\0]+")

(defvar cubescript-mode-font-lock-keywords
  `((,cubescript-operators-regexp . font-lock-keyword-face)
    (,cubescript-builtin-regexp . font-lock-builtin-face)
    (,cubescript-ident-regexp . font-lock-variable-name-face)))

;; for pre-emacs24
(unless (fboundp 'prog-mode) (defalias 'prog-mode 'fundamental-mode))

;;;###autoload
(define-derived-mode cubescript-mode
  prog-mode "CubeScript"
  "Major mode for CubeScript.
 \\{cubescript-mode-map}"
  (set (make-local-variable 'indent-line-function)
       'cubescript-indent-line)
  (set (make-local-variable 'font-lock-defaults)
       '((cubescript-mode-font-lock-keywords))))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.cfg$" . cubescript-mode))

(provide 'cubescript-mode)
