;;; --- Performance Optimizations ---
;; LSP servers send a lot of data; these settings keep Emacs snappy.

;; Increase the amount of data Emacs reads from processes (default is 4k)
(setq read-process-output-max (* 1024 1024)) ;; 1mb

;; Increase garbage collection threshold during startup and LSP usage
(setq gc-cons-threshold 100000000) ;; 100mb

;;; --- Package Management Setup ---
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;; Install use-package if not present (though built-in in 30.2)
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

;;; --- Core LSP Configuration ---

(use-package lsp-mode
  :init
  ;; set prefix for lsp-command-keymap (few alternatives - "C-l", "C-c l")
  (setq lsp-keymap-prefix "C-c l")
  :hook (;; Replace these with the modes you use
         (python-mode . lsp)
         (rust-mode . lsp)
         (js-mode . lsp)
         (typescript-mode . lsp)
         ;; which-key integration
         (lsp-mode . lsp-enable-which-key-integration))
  :commands lsp
  :custom
  ;; Performance & Behavior
  (lsp-log-io nil)                      ; Disable logging for performance
  (lsp-restart 'auto-restart)
  (lsp-ui-doc-enable t)                 ; Show docs on hover
  (lsp-ui-doc-show-with-cursor t)
  (lsp-ui-sideline-show-diagnostics t)  ; Show errors at the end of the line
  (lsp-headerline-breadcrumb-enable t)  ; Show breadcrumbs at the top
  (lsp-modeline-code-actions-enable t)
  (lsp-lens-enable t))                  ; Show references/implementations above functions

;;; --- Visuals & UI ---

(use-package lsp-ui
  :commands lsp-ui-mode
  :custom
  (lsp-ui-doc-position 'at-point)
  (lsp-ui-sideline-enable t)
  (lsp-ui-sideline-show-hover t))

;;; --- Completion & Syntax ---

(use-package company
  :hook (lsp-mode . company-mode)
  :bind (:map company-active-map
         ("<tab>" . company-complete-selection))
  :custom
  (company-minimum-prefix-length 1)
  (company-idle-delay 0.0))

(use-package flycheck
  :init (global-flycheck-mode))

(use-package which-key
  :config
  (which-key-mode))

;;; --- How to add your custom stuff ---
;; You can now add your language-specific settings or keybindings below.
;; Example: (setq lsp-rust-analyzer-display-chaining-hints t)
