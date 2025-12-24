;;; gnu-elpa-autoloads.el --- automatically extracted autoloads
;;
;;; Code:
(add-to-list 'load-path (directory-file-name (or (file-name-directory #$) (car load-path))))

;;;### (autoloads nil "gnu-elpa-utils" "gnu-elpa-utils.el" (24582
;;;;;;  48617 764244 219000))
;;; Generated autoloads from gnu-elpa-utils.el
 (eval-after-load 'package
  '(unless (assoc "gnu" package-archives)
     (push '("gnu" . "https://elpa.gnu.org/packages/")
           package-archives)))
 ;; Skip load-source-file-function which would slow us down by
 ;; a factor 2 (this assumes we were careful to save this file
 ;; so it doesn't need any decoding).
 (let ((load-source-file-function nil))
  (require 'gnu-elpa-features nil 'noerror))

;;;***

;;;### (autoloads nil nil ("gnu-elpa-features.el" "gnu-elpa-maint.el"
;;;;;;  "gnu-elpa-pkg.el" "gnu-elpa.el") (24582 48617 772244 229000))

;;;***

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; End:
;;; gnu-elpa-autoloads.el ends here
