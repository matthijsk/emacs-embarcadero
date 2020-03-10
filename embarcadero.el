;;; embarcadero.el --- Embarcadero interoperability -*- lexical-binding: t -*-

;; Copyright © 2019 Matthijs Kool

;; Author: Matthijs Kool <m.kool@stylecncmachines.com>
;; Created: 27 Feb 2019
;; Version: 0.4.2
;; Keywords: languages, tools
;; URL: http://scm-unix-02:3000/matthijs/emacs-embarcadero

;; This file is NOT part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify it
;; under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful, but WITHOUT
;; ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
;; or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
;; License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see http://www.gnu.org/licenses.

;;; Commentary:
;; Interoperability utilities to enable use of Embarcadero tools and files with
;; Emacs.
;;
;; Provides dfm-mode, a generic mode to enable syntax highlighting for
;; Embarcadero DFM files.
;;
;; Provides bds-insert-todo-comment, a convenience function to insert C++
;; Builder style TODO comments.
;;
;; Provides bds-show-help, a convenience function to quickly launch the
;; Embarcadero documentation viewers.
;;
;; Sets up auto-mode-alist autoloads for common Embarcadero project file types.

;;; Code:

(require 'generic-x)

;;;###autoload
(define-generic-mode dfm-mode
  nil ; comment list
  '("inherited" "object" "end" "True" "False")
  '(("\\<[0-9]+" . font-lock-constant-face)
    ("'.*'" . font-lock-string-face))
  '("\\.dfm\\'")
  nil
  "Generic mode for editing Embarcadero DFM files.")

(defgroup embarcadero nil "Embarcadero interoperability."
  :prefix "bds-"
  :group 'tools)

(defcustom bds-installation-dir "C:/Program Files (x86)/Embarcadero/Studio/19.0/"
  "Embarcadero C++ Builder installation directory."
  :type '(directory)
  :group 'embarcadero)

(defcustom bds-help-dir (concat bds-installation-dir "Help/Doc")
  "Embarcadero C++ Builder help directory."
  :type '(directory)
  :group 'embarcadero)

;;;###autoload
(defun bds-insert-todo-comment (comment &optional priority owner category)
  "Insert C++ Builder TODO comment.
PRIORITY must be a number between 0 and 5. If PRIORITY is not a
number, equal to 0 or larger than 5 it is not recorded in the
comment.

A TODO item has the format \"/* TODO PRIORITY -oOWNER -cCATEGORY : COMMENT
*/\"."
  (interactive "*MComment: \nnPriority: \nMOwner: \nMCategory: ")
  (insert (concat "/* TODO "
                  (when (and (integerp priority) (>= priority 1) (<= priority 5))
                    (concat (number-to-string priority) " "))
                  (when (> (length owner) 0)
                    (concat "-o" owner " "))
                  (when (> (length category) 0)
                    (concat "-c" category " "))
                  ": " comment " */")))

;;;###autoload
(defun bds-show-help ()
  "Show Embarcadero integrated help.
Displays an interactive menu where the user can choose between
the following help categories:

- code examples
- data
- dinkumware
- fmx
- indy
- libraries
- system
- topics
- vcl

After selecting a category the Windows chm viewer will launch. By
default, the launcher looks in the directory specified by the
variable `bds-help-dir'."
  (interactive)
  (let ((choices '("codeexamples"
                   "data"
                   "dinkumware"
                   "fmx"
                   "Indy10"
                   "libraries"
                   "system"
                   "topics"
                   "vcl")))
    ;; Start the help viewer (hh.exe) in a maximized state.
    (w32-shell-execute "open"
                       (concat bds-help-dir "/" (completing-read "Choose Embarcadero help category: " choices) ".chm")
                       nil
                       3)))

;;;###autoload
(progn
  (add-to-list 'auto-mode-alist '("\\.cbproj\\'" . xml-mode))
  (add-to-list 'auto-mode-alist '("\\.groupproj\\'" . xml-mode))
  (add-to-list 'auto-mode-alist '("\\.optset\\'" . xml-mode))
  (add-to-list 'auto-mode-alist '("\\.rh\\'" . c++-mode))
  (add-to-list 'auto-mode-alist '("\\.dfm\\'" . dfm-mode))
  (add-to-list 'auto-mode-alist '("\\.rc\\'" . rc-generic-mode)))

(provide 'embarcadero)

;;; embarcadero.el ends here
