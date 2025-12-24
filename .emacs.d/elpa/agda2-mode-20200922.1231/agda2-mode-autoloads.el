;;; agda2-mode-autoloads.el --- automatically extracted autoloads
;;
;;; Code:
(add-to-list 'load-path (directory-file-name (or (file-name-directory #$) (car load-path))))

;;;### (autoloads nil "agda2-mode" "agda2-mode.el" (24582 37471 353639
;;;;;;  150000))
;;; Generated autoloads from agda2-mode.el

(add-to-list 'auto-mode-alist '("\\.l?agda\\'" . agda2-mode))

(modify-coding-system-alist 'file "\\.l?agda\\'" 'utf-8)

(autoload 'agda2-mode "agda2-mode" "\
Major mode for Agda files.

The following paragraph does not apply to Emacs 23 or newer.

  Note that when this mode is activated the default font of the
  current frame is changed to the fontset `agda2-fontset-name'.
  The reason is that Agda programs often use mathematical symbols
  and other Unicode characters, so we try to provide a suitable
  default font setting, which can display many of the characters
  encountered. If you prefer to use your own settings, set
  `agda2-fontset-name' to nil.

Special commands:
\\{agda2-mode-map}

\(fn)" t nil)

;;;***

;;;### (autoloads nil nil ("agda-input.el" "agda2-abbrevs.el" "agda2-highlight.el"
;;;;;;  "agda2-mode-pkg.el" "agda2-queue.el" "agda2.el") (24582 37471
;;;;;;  369639 175000))

;;;***

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; End:
;;; agda2-mode-autoloads.el ends here
