;;; cubescript-mode.el --- major mode for editing CubeScript

;; Copyright (C) 2013

;; Author:  R. Peele
;; Keywords: languages

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; This major mode provides syntax highlighting and indentation for
;; CubeScript, the configuration and scripting language used in Cube,
;; Cube 2, and derivative game engines. Because CubeScript is
;; generally backwards compatible with the simpler configuration
;; languages used by the Quake and Source engines, this mode won't
;; get in the way when editing their .cfg files, either.

;;; Code:

(defun cubescript-calculate-from-previous ()
  "Return the correct indentation for the line following the one at point.

This is equal to the current indentation unless the last bracket
character on this line is an open bracket, in which case the
indentation is increased by `tab-width'."
  (beginning-of-line)
  (let ((current (current-indentation)))
    (if (looking-at ".*\\[[^][]*$")
        (+ current tab-width)
      current)))

(defun cubescript-calculate-from-current ()
  "Return (delta) indentation based on the content of the line being indented.

If the first non-whitespace character of the line is a closing
bracket, this is -`tab-width'. Otherwise, it is 0."
  (beginning-of-line)
  (if (looking-at "^\\s-*]")
      (- tab-width)
    0))

(defun cubescript-calculate-indent ()
  "Return the correct indentation for the current line."
  (save-excursion
    (let ((adjust (cubescript-calculate-from-current)))
      (forward-line -1)
      (while (looking-at "^\\s-*$")
        (forward-line -1))
      (+ adjust (cubescript-calculate-from-previous)))))

(defun cubescript-indent-line ()
  "Indent the current line, moving point accordingly."
  (let ((indent (cubescript-calculate-indent)))
    (save-excursion (indent-line-to indent))
    (goto-char (max (point) (+ (point-at-bol) indent)))))

(defconst cubescript-symbols "?<>\\/!@%^&|*+-=~")
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
    table)
  "Syntax table for CubeScript.

Differences from default syntax table include // line comments,
characters from `cubescript-symbols' as symbols, and {} treated
as punctuation instead of parens.")

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
     ">=s") 'symbols)
  "Regexp matching CubeScript's operators.")

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
     "clearsleep") 'words)
  "Regexp matching CubeScript's core builtin functions (from command.cpp).")

(defconst cubescript-ident-regexp
  "[@$][^][\"/;() \t\r\n\0]+"
  "Regexp matching a CubeScript variable or macro reference.")

(defvar cubescript-mode-font-lock-keywords
  `((,cubescript-operators-regexp . font-lock-keyword-face)
    (,cubescript-builtin-regexp . font-lock-builtin-face)
    (,cubescript-ident-regexp . font-lock-variable-name-face))
  "Font lock keywords for CubeScript.")

;; for pre-emacs24
(unless (fboundp 'prog-mode) (defalias 'prog-mode 'fundamental-mode))

;; major mode definition
;;;###autoload
(define-derived-mode cubescript-mode
  prog-mode "CubeScript"
  "Major mode for editing CubeScript.
 \\{cubescript-mode-map}"
  (set (make-local-variable 'indent-line-function)
       'cubescript-indent-line)
  (set (make-local-variable 'font-lock-defaults)
       '((cubescript-mode-font-lock-keywords)))
  (set (make-local-variable 'comment-start) "//"))

;; associate with .cfg file extension
;;;###autoload
(add-to-list 'auto-mode-alist '("\\.cfg$" . cubescript-mode))

(provide 'cubescript-mode)
;;; cubescript-mode.el ends here

