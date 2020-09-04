;;; .emacs --- my minimal Emacs config  -*- lexical-binding: t; -*-

;; Copyright (C) 2020 Thomas Ingram

;;; Commentary:

;; This is a complete rewrite of my Emacs config with following goals:
;;  - simplfy my config around `use-package'
;;  - rely as much as possible on built in Emacs features
;;  - keep external dependencies to a minimum of well trusted projects
;;

;;; Code:

;; Increase mememory
(setq gc-cons-threshold 100000000)

(setq read-process-output-max (* 1024 1024))

;; Prefer newest elisp files
(setq load-prefer-newer t)

;; Move auto-generated code out of init.el
(setq custom-file "~/.config/emacs/customizations.el")
(load custom-file 't)

;;; Visuals

(setq-default frame-title-format '("%b  -  GNU Emacs"))

;; Hide the startup screen
(setq inhibit-startup-screen t)

;; Hide toolbar
(tool-bar-mode -1)
(column-number-mode 1)

;; Increase font size
(set-face-attribute 'default nil :height 140)


;;; Editing

;; Set default line width to 80 characters
(setq-default fill-column 80)

;; On save delete trailing whitespace
(add-hook 'before-save-hook 'delete-trailing-whitespace)


;;; Built-in Tools

;; Custom ls command flags
(setq dired-listing-switches "-la --group-directories-first")

;; Allow using 'a' key in dired
(put 'dired-find-alternate-file 'disabled nil)

;; ibuffer is a better buffer-menu
(global-set-key (kbd "C-x C-b") 'ibuffer)

;; Open terminal
(global-set-key (kbd "C-x t") 'shell)


;;; Package

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(package-initialize)
;; One day use-package will be included by default...
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(require 'use-package)


;;; Languages

;; Emacs Lisp
(use-package emacs-lisp-mode
  :bind (:map emacs-lisp-mode-map
	      ("C-c C-r" . eval-region)
	      ("C-c C-b" . eval-buffer))
  :hook ((emacs-lisp-mode . flymake-mode)))

(use-package c-mode
  :bind (:map c-mode-map
	      ("C-c c"   . compile)
	      ("C-c C-c" . recompile)
	      ("C-c g"   . gdb)
              ("C-c C-r" . gdb-run))
  :hook ((c-mode . electric-pair-mode)
	 (c-mode . flymake-mode)))


;; Python
(use-package python-mode
  :hook ((python-mode . electric-pair-mode)))


;; Golang
(use-package go-mode
  :ensure t
  :bind (:map go-mode-map
	      ("C-c c"   . compile)
	      ("C-c C-c" . recompile)
	      ("C-c d"   . godoc)
              ("C-c f"   . gofmt)
              ("C-c g"   . gdb)
              ("C-c C-g" . gdb-run))
  :config
  (defun my/go-mode-set-local ()
    (set (make-local-variable 'compile-command) "go build -v "))
  :hook ((go-mode . my/go-mode-set-local)
	 (go-mode . subword-mode)
	 (go-mode . electric-pair-mode)
	 (before-save . gofmt-before-save)))


;;; Packages

;; delight is similar to deminish mode but provided in GNU ELPA.
;; Both have built in use package support
(use-package delight
  :ensure t)

;; Programming

; Drop down auto-completion support
(use-package company
  :ensure t
  :delight
  ;; :hook (emacs-lisp-mode . company-mode)
  ;; Perhaps I should enable on a per mode basis?
  :config
  (global-company-mode 1)
  :custom
  (company-idle-delay 0)
  (company-minimum-prefex-length 1))

;; Writing

;; Org Mode
(use-package org
  :bind (("C-x a" . org-agenda)
	 ("C-x c" . org-capture))
  :hook ((org-mode . flyspell-mode)
	 (org-mode . auto-fill-mode))
  :config
  ;; Org src evaluation langauges
  (org-babel-do-load-languages 'org-babel-load-languages
			       '((emacs-lisp . t)
				 (shell . t)
				 (latex . t)))

  ;; enable org templates
  (require 'org-tempo)
  :custom
  ;; Org agenda setup
  (org-agenda-files '("~/todo.org"))
  (org-agenda-include-diary t)
  (org-agenda-todo-list-sublevels nil)

  ;; If clock is running bug me if I stop working
  (org-clock-idle-time 10)

  (org-capture-templates
   `(("t" "Todo" entry (file+headline "~/todo.org" "")
      "* TODO %^{Todo}\n %i\n %a\n\n%?")
     ("j" "Journal" entry (file+headline
			   "~/Documents/me.org"
			   ,(substring (current-time-string) -4 nil))
      "* %u %^{Entry title}\n %?\n"))))


(use-package auctex
  :defer t
  :config
  (defun my/latex-compile ()
    "My compile latex function"
    (interactive)
    (save-buffer)
    (TeX-command "LaTeX" 'TeX-master-file))

  (setq TeX-command-default 'LaTeX)

  :bind (:map TeX-mode-map
	      ("C-c _" . "\\textunderscore "))

  :hook ((TeX-mode . auto-fill-mode)
	 (TeX-mode . flyspell-mode)))


;; Magit improved git management
(use-package magit
  :ensure t
  :bind ("C-x g" . magit))


;; Theme
(use-package modus-operandi-theme
  :ensure t
  :config
  (load-theme 'modus-operandi))
