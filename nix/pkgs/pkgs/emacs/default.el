; ---------------------------------------------------------------- locale
(set-language-environment "utf-8")
(set-terminal-coding-system 'utf-8)
(prefer-coding-system 'utf-8)

; ---------------------------------------------------------------- backup files
; Disable backup files
(setq make-backup-files nil)
;(setq version-control t)

(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))

; ---------------------------------------------------------------- Nix stuff
(load-library "nix-mode")

; ---------------------------------------------------------------- Colors and display
(require 'rainbow-delimiters)
(add-hook 'prog-mode-hook 'rainbow-delimiters-mode)

;; make colors more rainbowy! And pink!
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :stipple nil :background "black" :foreground "white" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 100 :width normal :foundry "unknown" :family "Inconsolata"))))
 '(cursor ((t (:background "hotpink"))))
 '(mode-line ((t (:background "hotpink" :foreground "black" :weight light))))
 '(mode-line-inactive ((t (:inherit mode-line :background "grey30" :foreground "grey80" :box (:line-width -1 :color "grey40")))))
 '(rainbow-delimiters-depth-1-face ((t (:foreground "red1" :weight bold))))
 '(rainbow-delimiters-depth-2-face ((t (:foreground "orange" :weight bold))))
 '(rainbow-delimiters-depth-3-face ((t (:foreground "yellow1" :weight bold))))
 '(rainbow-delimiters-depth-4-face ((t (:foreground "green1" :weight bold))))
 '(rainbow-delimiters-depth-5-face ((t (:foreground "DodgerBlue1" :weight bold))))
 '(rainbow-delimiters-depth-6-face ((t (:foreground "cyan" :weight bold))))
 '(rainbow-delimiters-depth-7-face ((t (:foreground "dark violet" :weight bold))))
 '(rainbow-delimiters-depth-8-face ((t (:foreground "magenta" :weight bold))))
 '(rainbow-delimiters-depth-9-face ((t (:foreground "slate gray" :weight bold))))
 '(rainbow-delimiters-unmatched-face ((t (:background "red" :foreground "black" :weight bold))))
 '(region ((t (:background "HotPink4")))))


(custom-set-variables
 '(c-basic-offset 2)
 '(c-default-style "linux")
 '(tramp-archive-enabled nil) ;; Blows up on finding an '.exe' dir in a PATH component. Required to work by e.g. python-mode.
)

; ---------------------------------------------------------------- Metainfo display
; Show line and column numbers in mode line
(line-number-mode 1)
(column-number-mode 1)
; (display-time)

; ---------------------------------------------------------------- windowing stuff
(when window-system
  even-window-heights nil
  resize-mini-windows nil
  (setq default-frame-alist '(
    (top . 0) (left . 80)
    (height . 100) (width . 141)
    ;(cursor-type . "bar")
  ))
)

; ---------------------------------------------------------------- keys
(global-set-key (kbd "M-s") 'isearch-repeat-forward)
(global-set-key (kbd "M-r") 'isearch-repeat-backward)
