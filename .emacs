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

;; (use-package lsp-pyright
;;   :after lsp-mode

  ;; :custom
  ;; ;; Force lsp-pyright to use your installed pyright command.
  ;; ;; The lsp-pyright docs show this variable being used
  ;; ;; to select the Pyright command.
  ;; (lsp-pyright-langserver-command "/home/smagri/.local/bin/pyright")

  
;;   :hook
;;   (python-mode . (lambda ()
;;                    (require 'lsp-pyright)
;;                    (lsp-deferred))))
;;; ------------------------------------------------------------
;;; Python IntelliSense using Pyright
;;; Normal Python .py files, not MicroPython
;;; ------------------------------------------------------------

(use-package lsp-pyright
  :after lsp-mode

  :custom
  ;; Use your installed pyright command.
  ;; /home/smagri/.local/bin is already added to exec-path/PATH
  ;; near the top of your .emacs file.
  (lsp-pyright-langserver-command "pyright")

  :config
  (defun smagri-python-lsp-start ()
    "Start Pyright LSP for normal Python files."
    (require 'lsp-pyright)
    (lsp-deferred))

  ;; Normal Python mode.
  (add-hook 'python-mode-hook #'smagri-python-lsp-start)

  ;; Emacs 30 may use python-ts-mode instead of python-mode.
  ;; This makes completion work there too.
  (when (boundp 'python-ts-mode-hook)
    (add-hook 'python-ts-mode-hook #'smagri-python-lsp-start)))




;;
;; For micropython projects disable flycheck, it produces false errors
;;



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
  (define-key company-active-map (kbd "TAB") #'company-complete-selection)
  (define-key company-active-map (kbd "<tab>") #'company-complete-selection)

;; Need them for tab completion in suggestions 
;; Keep TAB free for indentation/yasnippet
;;  (define-key company-active-map (kbd "TAB") nil)
;;  (define-key company-active-map (kbd "<tab>") nil)
  )




;; ============================================================
;; Format current buffer using LSP / clangd / clang-format
;;
;; Otherwise spaces occur in fn prototypes in cpp mode
;; ============================================================

(defun smagri-format-buffer ()
  "Format the current buffer using lsp-mode if available."
  (interactive)
  (if (bound-and-true-p lsp-mode)
      (lsp-format-buffer)
    (indent-region (point-min) (point-max))))





;;; ------------------------------------------------------------
;;; Fix bad C++ / Arduino completion spacing on current line
;;;
;;; Examples:
;;;   Controller:: setTolerance      -> Controller::setTolerance
;;;   Ackerman::Ackerman::  setGoal  -> Ackerman::Ackerman::setGoal
;;;   u8g2. clearBuffer              -> u8g2.clearBuffer
;;;   obj-> method                   -> obj->method
;;;   int tw =  u8g2.func()          -> int tw = u8g2.func()
;;;   bool   Ackerman::func()        -> bool Ackerman::func()
;;;
;;; Use:
;;;   Put cursor on the bad line, then press C-c f l
;;; ------------------------------------------------------------

(defun smagri-fix-cpp-current-line-spacing ()
  "Fix unwanted spaces inserted by completion on the current C/C++ line."
  (interactive)
  (save-excursion
    (let ((beg (line-beginning-position))
          (end (line-end-position)))

      ;; Fix spaces around ->
      ;; obj-> method  or  obj -> method  becomes obj->method
      (goto-char beg)
      (while (re-search-forward "[ \t]*->[ \t]*" end t)
        (replace-match "->" nil nil)
        (setq end (line-end-position)))

      ;; Fix spaces around ::
      ;; Controller:: setTolerance becomes Controller::setTolerance
      ;; Ackerman::Ackerman::  setGoal becomes Ackerman::Ackerman::setGoal
      (goto-char beg)
      (while (re-search-forward "[ \t]*::[ \t]*" end t)
        (replace-match "::" nil nil)
        (setq end (line-end-position)))

      ;; Fix spaces around .
      ;; u8g2. clearBuffer becomes u8g2.clearBuffer
      (goto-char beg)
      (while (re-search-forward "[ \t]*\\.[ \t]*" end t)
        (replace-match "." nil nil)
        (setq end (line-end-position)))

      ;; Collapse repeated spaces inside the line, but keep indentation.
      ;; This fixes:
      ;;   bool   Ackerman::func()
      ;;   int tw =  u8g2.func()
      ;;
      ;; Do not use this helper on comment/string lines where you want
      ;; multiple spaces preserved.
      (goto-char beg)
      (skip-chars-forward " \t" end)
      (while (re-search-forward "[ \t][ \t]+" end t)
        (replace-match " " nil nil)
        (setq end (line-end-position)))))

  (message "Fixed C++ spacing on current line"))

;;(global-set-key (kbd "C-c f l") #'smagri-fix-cpp-current-line-spacing)




;;; ------------------------------------------------------------
;;; Custom C / C++ / Arduino / Python editing settings
;;; Safe with lsp-mode/company
;;; ------------------------------------------------------------

;;; ------------------------------------------------------------
;;; Make RET auto-indent in C / C++ / Arduino / Python
;;; ------------------------------------------------------------

(electric-indent-mode 1)

;; C / C++ / Arduino .ino
;; .ino files are opened as c++-mode in your config, so this covers them too.
(defun simones-c-mode-hook ()
  "Set up Simone's C editing style."
  (c-set-style "linux")

  ;; C indent = 4 spaces
  (setq-local c-basic-offset 4)
  (setq-local indent-tabs-mode nil)
  (setq-local tab-width 4)

  ;; Brace / colon behaviour
  (setq-local c-hanging-braces-alist
              '((brace-list-open)
                (brace-list-close)))

  (setq-local c-hanging-colons-alist
              '((case-label after)))

  ;; Indentation rules
  (c-set-offset 'substatement-open 0)
  (c-set-offset 'statement-case-intro 4)
  (c-set-offset 'case-label 4)
  (c-set-offset 'statement-case-open 4)

  (setq-local c-comment-only-line-offset 0)

  ;; Keep old comment style preference
  (c-toggle-comment-style -1))


(defun simones-c++-mode-hook ()
  "Set up Simone's C++ / Arduino editing style."
  (c-set-style "linux")

  ;; C++ / Arduino indent = 4 spaces
  (setq-local c-basic-offset 4)
  (setq-local indent-tabs-mode nil)
  (setq-local tab-width 4)

  ;; Brace / colon behaviour
  (setq-local c-hanging-braces-alist
              '((brace-list-open)
                (brace-list-close)))

  (setq-local c-hanging-colons-alist
              '((case-label after)))

  ;; Indentation rules
  (c-set-offset 'substatement-open 0)
  (c-set-offset 'statement-case-intro 4)
  (c-set-offset 'case-label 4)
  (c-set-offset 'statement-case-open 4)

  (setq-local c-comment-only-line-offset 0))


(defun simones-python-mode-hook ()
  "Set up Simone's Python editing style."
  (setq-local python-indent-offset 4)
  (setq-local indent-tabs-mode nil)
  (setq-local tab-width 4))


;; Use add-hook. Do not overwrite the whole hook variable.
(add-hook 'c-mode-hook #'simones-c-mode-hook)
(add-hook 'c++-mode-hook #'simones-c++-mode-hook)
(add-hook 'python-mode-hook #'simones-python-mode-hook)

(with-eval-after-load 'cc-mode
  (define-key c-mode-base-map (kbd "RET") #'c-context-line-break)
  (define-key c-mode-base-map (kbd "<return>") #'c-context-line-break)
  (define-key c-mode-base-map (kbd "C-m") #'c-context-line-break))

;; Python
(with-eval-after-load 'python
  (define-key python-mode-map (kbd "RET") #'newline-and-indent)
  (define-key python-mode-map (kbd "<return>") #'newline-and-indent)
  (define-key python-mode-map (kbd "C-m") #'newline-and-indent))



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




;; ============================================================
;; set titlebar to path/filename:
;; ============================================================
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



;; Setup helm
;;
;; (add-to-list 'load-path "~/.emacs.d/custom")
;; (require 'setup-helm)
;; (require 'setup-helm-gtags)
;;
;;For now, test these three:
;;M: (featurep 'setup-helm)
;;M: (featurep 'helm)
;;M: helm-mode
;;If they all return t, then setup-helm is loading. - they do

;; Tell Emacs where your personal setup files are
(add-to-list 'load-path
             (file-name-as-directory
              (expand-file-name "custom" user-emacs-directory)))

(require 'setup-helm)
(require 'setup-helm-gtags)



;; ============================================================
;; Diminish
;; Hide minor-mode names from the mode line
;; Cosmetic only
;; ============================================================
(use-package diminish
  :ensure t)

(with-eval-after-load 'abbrev
  (diminish 'abbrev-mode ""))

(with-eval-after-load 'yasnippet
  (diminish 'yas-minor-mode ""))



;; ============================================================
;; AVR register/function highlighting
;;
;; Highlight AVR registers and functions.  This will make the main AVR
;; symbols colored  like keywords.  You can extend  the list  with any
;; registers you use.
;;
;; Cosmetic only. Safe with lsp-mode/company.
;; ============================================================

(defun smagri-avr-highlighting ()
  "Highlight common AVR register names and AVR delay functions."
  (font-lock-add-keywords
   nil
   '(("\\<\\(DDRB\\|PORTB\\|PINB\\|DDRC\\|PORTC\\|PINC\\|DDRD\\|PORTD\\|PIND\\|TCCR0A\\|TCCR0B\\|TCCR1A\\|TCCR1B\\|TCCR2A\\|TCCR2B\\|OCR0A\\|OCR0B\\|OCR1A\\|OCR1B\\|OCR2A\\|OCR2B\\|TIMSK0\\|TIMSK1\\|TIMSK2\\|EIMSK\\|EIFR\\|PCICR\\|PCMSK0\\|PCMSK1\\|PCMSK2\\|ADMUX\\|ADCSRA\\|ADCSRB\\|ADCL\\|ADCH\\|UDR0\\|UCSR0A\\|UCSR0B\\|UCSR0C\\|UBRR0H\\|UBRR0L\\|_delay_ms\\|_delay_us\\)\\>"
      . font-lock-keyword-face)))
  (font-lock-flush))

(add-hook 'c-mode-hook #'smagri-avr-highlighting)
(add-hook 'c++-mode-hook #'smagri-avr-highlighting)
(add-hook 'arduino-mode-hook #'smagri-avr-highlighting)


;; ==================================================================
;; Setup Arduino code
;;
;; ==================================================================

;; Treat Arduino .ino files as C++ files for clangd/lsp-mode.
(add-to-list 'auto-mode-alist '("\\.ino\\'" . c++-mode))

;; Treat .h files as C++ by default.
(add-to-list 'auto-mode-alist '("\\.h\\'" . c++-mode))

;; C / C++ / Arduino files use clangd through lsp-mode
(add-hook 'c-mode-hook #'lsp-deferred)
(add-hook 'c++-mode-hook #'lsp-deferred)

;; IntelliSense in cpp files that have arduino libraries in them
;; (setq lsp-clients-clangd-args
;;       '("--background-index"
;;         "--completion-style=detailed"
;;         "--header-insertion=iwyu"))
;; IntelliSense in cpp files that have Arduino libraries in them.
;; Use bundled completion to avoid weird inserted completion prefixes.
(setq lsp-clients-clangd-args
      '("--background-index"
        "--completion-style=bundled"
        "--header-insertion=never"))




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
(global-set-key (kbd "C-c l s") #'lsp-restart-workspace)
(global-set-key (kbd "C-c f b") #'smagri-format-buffer)

;;C-c f  l fix bad completion  spacing on current line  only, must put
;;cursor somewhere on the line
(global-set-key (kbd "C-c f l") #'smagri-fix-cpp-current-line-spacing)
;;C-c f b    clang-format whole buffer, only when deliberately wanted
(global-set-key (kbd "C-c f f") #'sm/clang-format-current-defun)
