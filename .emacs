;;; ------------------------------------------------------------
;;; Pristine Emacs 30.2 configuration for IntelliSense
;;; C / C++ / Arduino .ino / Python
;;; Uses: lsp-mode + company + flycheck
;;;
;;; Important:
;;; Python is forced to use pyright, not pylsp.
;;;
;; Now you will have:
;; Auto-completion / IntelliSense
;; Function signatures on hover
;; Go-to-definition (M-.) / References (M-?)
;; Rename symbols (M-x lsp-rename)
;; Diagnostics / linting via Flycheck
;;; ------------------------------------------------------------


;;; ------------------------------------------------------------
;;; Make Emacs find user-installed command-line tools
;;; Needed for pyright / pyright-langserver in ~/.local/bin
;;; ------------------------------------------------------------

(let ((local-bin "/home/smagri/.local/bin"))
  (add-to-list 'exec-path local-bin)
  (setenv "PATH" (concat local-bin path-separator (getenv "PATH"))))


;;; ------------------------------------------------------------
;;; Package setup
;;; ------------------------------------------------------------

(require 'package)

(setq package-archives
      '(("gnu"    . "https://elpa.gnu.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/")
        ("melpa"  . "https://melpa.org/packages/")))

(package-initialize)

;; Refresh package list automatically if needed.
(unless package-archive-contents
  (package-refresh-contents))

;; Install use-package if needed.
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)

;; Automatically install packages mentioned below if missing.
(setq use-package-always-ensure t)


;;; ------------------------------------------------------------
;;; Basic Emacs behaviour
;;; ------------------------------------------------------------

(setq inhibit-startup-screen t)
(setq ring-bell-function 'ignore)

;; Show line numbers in programming buffers.
;; (add-hook 'prog-mode-hook #'display-line-numbers-mode)

;; Highlight matching brackets.
(show-paren-mode 1)

;; Use spaces instead of tabs.
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)


;;; ------------------------------------------------------------
;;; Arduino / C / C++ file associations
;;; ------------------------------------------------------------

;; Treat Arduino .ino files as C++ files.
(add-to-list 'auto-mode-alist '("\\.ino\\'" . c++-mode))

;; Treat .h files as C++ by default.
(add-to-list 'auto-mode-alist '("\\.h\\'" . c++-mode))


;;; ------------------------------------------------------------
;;; Syntax checking: flycheck
;;; ------------------------------------------------------------

(use-package flycheck
  :init
  (global-flycheck-mode))


;;; ------------------------------------------------------------
;;; LSP mode: main IntelliSense engine
;;; ------------------------------------------------------------

(use-package lsp-mode
  ;;  :commands (lsp lsp-deferred)
  :demand t

  ;; IMPORTANT:
  ;; Do not put python-mode here.
  ;; Python is started separately through lsp-pyright below.
  :hook
  ((c-mode   . lsp-deferred)
   (c++-mode . lsp-deferred))

  :init
  ;; Force lsp-mode not to choose pylsp.
  ;; Your lsp-describe-session showed pylsp was being selected.
  ;; We want pyright instead.
  (setq lsp-disabled-clients '(pylsp pyls mspyls jedi-language-server))

  :custom
  ;; Use company-capf for completion.
  (lsp-completion-provider :capf)

  ;; Keep interface simpler.
  (lsp-headerline-breadcrumb-enable nil)
  (lsp-lens-enable nil)

  ;; Better performance.
  (lsp-idle-delay 0.3)
  (lsp-log-io nil)

  ;; Use flycheck rather than flymake.
  (lsp-diagnostics-provider :flycheck)

  ;; clangd is the C/C++ language server.
  (lsp-clients-clangd-executable "/usr/bin/clangd")

  ;; Optional: stop clangd auto-inserting #include lines.
  ;; Comment this out if you want clangd to suggest includes.
  (lsp-clients-clangd-args '("--header-insertion=never"))

  :config
  ;; Useful LSP shortcuts.
  (define-key lsp-mode-map (kbd "C-c l r") #'lsp-rename)
  (define-key lsp-mode-map (kbd "C-c l a") #'lsp-execute-code-action)
  (define-key lsp-mode-map (kbd "C-c l d") #'lsp-find-definition)
  (define-key lsp-mode-map (kbd "C-c l h") #'lsp-describe-thing-at-point))


;;; ------------------------------------------------------------
;;; Optional LSP UI extras
;;; ------------------------------------------------------------

(use-package lsp-ui
  :after lsp-mode
  :commands lsp-ui-mode
  :hook (lsp-mode . lsp-ui-mode)
  :custom
  ;; Documentation popup.
  (lsp-ui-doc-enable t)
  (lsp-ui-doc-delay 0.4)

  ;; Diagnostics/messages on the right side.
  (lsp-ui-sideline-enable t)
  (lsp-ui-sideline-show-diagnostics t)
  (lsp-ui-sideline-show-hover nil)
  (lsp-ui-sideline-show-code-actions t))


;;; ------------------------------------------------------------
;;; Python IntelliSense using Pyright
;;; ------------------------------------------------------------

(use-package lsp-pyright
  :after lsp-mode

  :custom
  ;; Force lsp-pyright to use your installed pyright command.
  ;; The lsp-pyright docs show this variable being used
  ;; to select the Pyright command.
  (lsp-pyright-langserver-command "/home/smagri/.local/bin/pyright")

  :hook
  (python-mode . (lambda ()
                   (require 'lsp-pyright)
                   (lsp-deferred))))



;;; ------------------------------------------------------------
;;; Completion popup: company-mode
;;; ------------------------------------------------------------

(use-package company
  :hook (after-init . global-company-mode)
  :custom
  ;; Start suggestions quickly.
  (company-idle-delay 0.2)

  ;; Start suggesting after 1 character.
  (company-minimum-prefix-length 1)

  ;; lsp-mode provides completions through completion-at-point.
  (company-backends '(company-capf))

  ;; Show numbers in the completion list.
  (company-show-numbers t)

  ;; Keep popup aligned.
  (company-tooltip-align-annotations t)

  :bind
  (:map company-active-map
        ("TAB" . company-complete-selection)
        ("<tab>" . company-complete-selection)
        ("RET" . company-complete-selection)
        ("<return>" . company-complete-selection)))

;; ============================================================
;; Company completion popup keys
;; C-n/C-p move through suggestions.
;; RET accepts suggestion.
;; TAB is left free for indentation/yasnippet.
;; ============================================================

(with-eval-after-load 'company
  (define-key company-active-map (kbd "C-n") #'company-select-next)
  (define-key company-active-map (kbd "C-p") #'company-select-previous)
  (define-key company-active-map (kbd "RET") #'company-complete-selection)
  (define-key company-active-map (kbd "<return>") #'company-complete-selection)

;; Need them for tab completion in suggestions 
;;   ;; Keep TAB free for indentation/yasnippet
  (define-key company-active-map (kbd "TAB") nil)
  (define-key company-active-map (kbd "<tab>") nil)
  )



;;; ------------------------------------------------------------
;;; C / C++ indentation preferences
;;; ------------------------------------------------------------

(setq-default c-basic-offset 4)

(defun simone-c-cpp-style ()
  "Simple C/C++ style settings."
  (setq c-basic-offset 4)
  (setq indent-tabs-mode nil))

(add-hook 'c-mode-hook #'simone-c-cpp-style)
(add-hook 'c++-mode-hook #'simone-c-cpp-style)


;;; ------------------------------------------------------------
;;; Helpful diagnostic commands
;;; ------------------------------------------------------------

(defun simone-lsp-status ()
  "Show whether lsp-mode is active in the current buffer."
  (interactive)
  (if (bound-and-true-p lsp-mode)
      (message "lsp-mode is ON in this buffer.")
    (message "lsp-mode is OFF in this buffer.")))

(defun simone-lsp-debug ()
  "Open useful LSP debug information."
  (interactive)
  (if (bound-and-true-p lsp-mode)
      (lsp-describe-session)
    (message "lsp-mode is not active in this buffer. Try M-x lsp.")))


;;; ------------------------------------------------------------
;;; End of pristine .emacs
;;; ------------------------------------------------------------

;;; Emacs highlighting configuration
;;;
(global-font-lock-mode 1)
(setq font-lock-maximum-decoration t)

(when (boundp 'treesit-font-lock-level)
  (setq treesit-font-lock-level 4))

(show-paren-mode 1)
(setq show-paren-delay 0)
(setq show-paren-style 'parenthesis)

(global-hl-line-mode 1)

;;; Exact old highlighting colours
;;;
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:family "Liberation Mono" :foundry "1ASC" :background "#000015" :foreground "white" :slant normal :weight normal :height 100 :width normal))))
 '(font-lock-comment-face ((((class color)) (:foreground "MediumSeaGreen"))))
 '(font-lock-type-face ((((class color)) (:foreground "plum"))))
 '(font-lock-variable-name-face ((((class color)) (:foreground "#FF4277")))))



;; Howto launch meld from emacs
;;
;; M-x meld-files
(defun meld-files (file1 file2)
  "Run Meld on two files."
  (interactive "fFile 1: \nfFile 2: ")
  (start-process "meld" nil "/usr/bin/meld"
                 (expand-file-name file1)
                 (expand-file-name file2)))



;; add yasnippet to modes, ie AUTO-COMPLETION of LANGUAGE PRIMATIVES
;;
;; type 'yas-describe-tables' to determine the snippets available in
;; the current mode
;;
;; see@5:37min 4 this cleaner settup https://www.youtube.com/watch?v=4aYMa8f6B0o
;;
(use-package yasnippet ;; install package
  :diminish 
  :ensure t ;; install package if not already installed
  :config   ;; execute code after package is loaded
  :init     ;; execute code before package is loaded
  (yas-global-mode 1) ;; enables yasnippet in all modes
  (use-package yasnippet-snippets  ;; package dependancy
    :diminish
    :ensure t
    )
  (yas-reload-all) ;; seems important when you write your own snippets

  )



;; gdb IDE-like interface                                                                                           
;;                                                                                                                  
(setq                                                                                                               
;; use gdb-many-windows by default                                                                                  
 gdb-many-windows t                                                                                                 
                                                                                                                    
;; Non-nil means display source file containing the main routine at startup                                         
 gdb-show-main t
 )
;;                                                                                                                  
;; sidebar/fringe of a buffer                                                                                       
;;                                                                                                                  
;; very useful for gdb/GUD debugging                                                                                
;;                                                                                                                  
;; make both fringes 4 pixels wide                                                                                  
;; (fringe-mode 4)                                                                                                  
;;                                                                                                                  
;; ;; make the left fringe 4 pixels wide and the right disappear                                                    
;; (fringe-mode '(4 . 0))                                                                                           
;;                                                                                                                  
;; ;; restore the default sizes == 8pixels,(rounded to multiple)                                                    
;; (fringe-mode nil)                                                                                                
(fringe-mode '(32 . 0))                                                                                             

 

;; ============================================================
;; Automatically insert matching brackets, braces, parentheses,
;; and quotes.
;; ============================================================
(electric-pair-mode 1)




;; set titlebar to path/filename:                                                                                   
;;                                                                                                                  
;; sets filename with full path %f                                                                                  
;; major mode type %m                                                                                               
;; narrow if appropriate %n                                                                                         
;; biffer name %b                                                                                                   
;;                                                                                                                  
;; /lu1/smagri                                                                                                      
;; (when window-system                                                                                              
;;   (setq-default frame-title-format '("%f [%m] %n"))                                                              
;;   (setq frame-title-format '((:eval default-directory)))                                                         
;;   )                                                                                                              
                                                                                                                    
;; directories ~/                                                                                                   
;; filenames /lu1/smagri                                                                                            
(setq frame-title-format                                                                                            
      '(buffer-file-name "%f [%m] %n"                                                                               
             (dired-directory dired-directory "%b")))                                                               
                                                                                                                    
;; emacs -nw                                                                                                        
;;                                                                                                                  
(defun xterm-title-update ()                                                                                        
  (interactive)                                                                                                     
  (send-string-to-terminal (concat "\033]1; " (buffer-name) "\007"))                                                
  (if buffer-file-name                                                                                              
      (send-string-to-terminal (concat "\033]2; " (buffer-file-name) "\007"))                                       
    (send-string-to-terminal (concat "\033]2; " (buffer-name) "\007")))                                             
  )
;; This would run it constantly after every command, probably unecessary
;;(add-hook 'post-command-hook 'xterm-title-update)


;; ============================================================
;; Menu bar, tool bar, scroll bar
;; ============================================================

;; Keep menu bar visible
(menu-bar-mode 1)

;; Keep toolbar visible, if available
(when (fboundp 'tool-bar-mode)
  (tool-bar-mode 1))

;; Hide scrollbar, if available
(when (fboundp 'scroll-bar-mode)
  (scroll-bar-mode -1))



;; ============================================================
;; Treemacs
;; IDE-like file/project navigation
;; Safe with lsp-mode/company IntelliSense
;; ============================================================
(use-package treemacs
  :ensure t
  :diminish
  :defer t
  :init
  (with-eval-after-load 'winum
    (define-key winum-keymap (kbd "M-0") #'treemacs-select-window))

  :config
  (setq treemacs-collapse-dirs                 (if treemacs-python-executable 3 0)
        treemacs-deferred-git-apply-delay      0.5
        treemacs-display-in-side-window        t
        treemacs-eldoc-display                 t
        treemacs-file-event-delay              5000
        treemacs-file-follow-delay             0.2
        treemacs-follow-after-init             t
        treemacs-goto-tag-strategy             'refetch-index
        treemacs-indentation                   2
        treemacs-indentation-string            " "
        treemacs-is-never-other-window         nil
        treemacs-max-git-entries               5000
        treemacs-missing-project-action        'ask
        treemacs-no-delete-other-windows       t
        treemacs-position                      'left
        treemacs-show-cursor                   nil
        treemacs-show-hidden-files             t
        treemacs-sorting                       'alphabetic-asc
        treemacs-space-between-root-nodes      t
        treemacs-width                         35)

  ;; Enable Treemacs helper modes
  (treemacs-follow-mode t)
  (treemacs-filewatch-mode t)
  (treemacs-fringe-indicator-mode t)

  ;; Only works in  treemacs-version greater than 3.3,  but only 3.2
  ;; is stable  from melpa Auto-save and  restore Treemacs workspace
  ;; (projects, folders, window width)
  ;;(treemacs-save-workspace-mode 1)   ;; enable persistent workspaces
  ;; chatGPT  I would still keep persistence disabled until your Emacs setup is stable.
  
  ;; Git integration
  (pcase (cons (not (null (executable-find "git")))
               (not (null treemacs-python-executable)))
    (`(t . t)
     (treemacs-git-mode 'deferred))
    (`(t . _)
     (treemacs-git-mode 'simple)))

  :bind
  (:map global-map
        ("M-0"       . treemacs-select-window)
        ("C-x t 1"   . treemacs-delete-other-windows)
        ("C-x t t"   . treemacs)
        ("C-x t B"   . treemacs-bookmark)
        ("C-x t C-t" . treemacs-find-file)
        ("C-x t M-t" . treemacs-find-tag)))



;; package projectile
;;
;; most useful commands(but I think treemacs-helm combination makes
;; this useless for finding the 'other' files). 'other' files are same
;; name but different type, eg ranger.cpp to ranger.h
;;
;; projectile-find-other-file-other-window
;; projectile-find-other-file-other-buffer
;;
;; (use-package projectile-mode-line
;;   :init
;;   (projectile-global-mode)
;;   (setq projectile-enable-caching t))




;; Personal general key mappings, put here so other mode remappings
;; get overridden, I don't like it when that happens.
;;(global-set-key (kbd "\C-cg")   'goto-line)
;;
;; New way these should be written.
;;(global-set-key (kbd "C-c c") #'comment-or-uncomment-region)
(global-set-key "\C-cwl"	'what-line)
(global-set-key "\C-cfj"	'set-justification-full)
(global-set-key	"\C-ci"		'indent-region)
(global-set-key	"\C-cm"		'menu-bar-mode)
(global-set-key	"\C-cc"     'comment-or-uncomment-region)
(global-set-key	"\C-cpl"	'compile)
(global-set-key	"\C-cds"	'desktop-save)
(global-set-key	"\C-cdr"	'desktop-read)
(global-set-key	"\C-xb"		'ibuffer)
(global-set-key (kbd "C-c f m") #'meld-files)
