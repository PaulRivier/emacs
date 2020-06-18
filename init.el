(add-to-list 'face-ignored-fonts "Noto Color Emoji")

(setq custom-file "~/.emacs.d/custom.el")
(load-file custom-file)


;; EMACS GENERAL

(setq package-archives '(("gnu" . "https://elpa.gnu.org/packages/")
                         ("melpa" . "https://melpa.org/packages/")))

(setq gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3")

;; Variables
(setq make-backup-files nil
      column-number-mode t
      mouse-yank-at-point t
      x-select-enable-primary t
      x-select-enable-clipboard t
      inhibit-startup-screen t
      completion-ignore-case t
      read-buffer-completion-ignore-case t
      ;; Split vertical par défaut
      split-width-threshold 120
      split-height-threshold nil

      confirm-kill-emacs 'y-or-n-p
      display-time-day-and-date t
      display-time-24hr-format t
      visible-bell 't
      sentence-end-double-space nil
      backup-directory-alist '(("." . "~/.backup_emacs"))

      ;; ediff config
      ediff-merge-split-window-function 'split-window-vertically
      ediff-window-setup-function 'ediff-setup-windows-plain

      uniquify-buffer-name-style 'forward

      ;; dont truncate long lines
      ;; (setq truncate-partial-width-windows nil)
      )

(fset 'yes-or-no-p 'y-or-n-p)
;; downcase and upcase are allowed
(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)

(setq-default indent-tabs-mode nil
	          tab-width 4
	          )


;; Modes
(if window-system (tool-bar-mode 0))
(icomplete-mode 1)
(recentf-mode 1)
(show-paren-mode 1)
(blink-cursor-mode 0)

(package-initialize)


;; Functions
(defun unfill-paragraph (&optional region)
  "Takes a multi-line paragraph and makes it into a single line of text."
  (interactive (progn (barf-if-buffer-read-only) '(t)))
  (let ((fill-column (point-max))
        ;; This would override `fill-column' if it's an integer.
        (emacs-lisp-docstring-fill-column t))
    (fill-paragraph nil region)))

(defun comment-or-uncomment-line ()
  "Comment or uncomment current line."
  (interactive)
  (comment-or-uncomment-region
   (line-beginning-position)
   (line-end-position)))

(defun comment-or-uncomment-region-or-line ()
  "Comment or uncomment current region or line."
  (interactive)
  (if (or (and transient-mark-mode mark-active)
	  (and (not transient-mark-mode) (not (eq (point) (mark)))))
      (comment-or-uncomment-region (region-maybe-start) (region-maybe-end))
    (comment-or-uncomment-line)))

(defun beginning-of-line-or-text ()
  "Alternatively call beginning-of-line and beginning-of-line-text"
  (interactive)
  (let ((ppos (point)))
    (beginning-of-line-text)
    (when (= ppos (point)) (beginning-of-line))))

(defun auto-repeat-command (command)
  (let ((repeat-repeat-char
         (when (eq last-command-char
                   last-command-event)
           last-command-char)))
    (call-interactively command)
    (while (eq (read-event) repeat-repeat-char)
      ;; Make each repetition undo separately.
      (auto-repeat-command command)
      (setq unread-command-events (list last-input-event)))))

(defun insert-path-here (arg)
  "Insert a string giving the relative path of a file. With argument, give absolute path."
  (interactive "P")
  (let ((path (read-file-name "Please select a file : " default-directory)))
    (insert (if arg path (file-relative-name path)))))


(defun kiwi-server ()
  "Starts a emacs server with name kiwi"
  (interactive)
  (set-variable 'server-name "kiwi")
  (server-start)
  )



;; Bindings
(define-key global-map (kbd "C-x C-b") 'ibuffer)
(define-key global-map (kbd "M-p") 'backward-paragraph)
(define-key global-map (kbd "M-n") 'forward-paragraph)
(define-key global-map (kbd "M-Q") 'unfill-paragraph)
(define-key global-map "\M-;" 'comment-or-uncomment-region-or-line)

(define-key global-map (kbd "M-S-<left>")  'windmove-left)
(define-key global-map (kbd "M-S-<right>") 'windmove-right)
(define-key global-map (kbd "M-S-<up>")    'windmove-up)
(define-key global-map (kbd "M-S-<down>")  'windmove-down)

(global-set-key (kbd "S-C-<left>") 'shrink-window-horizontally)
(global-set-key (kbd "S-C-<right>") 'enlarge-window-horizontally)
(global-set-key (kbd "S-C-<down>") 'shrink-window)
(global-set-key (kbd "S-C-<up>") 'enlarge-window)

(define-key global-map (kbd "<down>") (lambda ()
			 (interactive)
			 (next-line 1)
			 (unless (eq (window-end) (point-max))
			   (scroll-up 1))))
(define-key global-map (kbd "<up>") (lambda ()
		       (interactive)
		       (previous-line 1)
		       (unless (eq (window-start) (point-min))
			 (scroll-down 1))))



;; MARKDOWN
(use-package markdown-mode
  :mode
  "\\.md\\'"
  :config
  (add-hook 'markdown-mode-hook
            (lambda ()
              ;; (setq fill-column 84)
              ;; (turn-on-auto-fill)

              ;; (turn-on-visual-line-mode)
              ;; (visual-fill-column-mode)
              ;; (adaptive-wrap-prefix-mode)
              ;; (setq-default split-window-preferred-function
              ;;               'visual-fill-column-split-window-sensibly)

              (setq left-fringe-width 0
                    right-fringe-width 0
                    olivetti-body-width 84)
              (olivetti-mode)
              (adaptive-wrap-prefix-mode)

              ))
  )



;; Haskell
(use-package haskell-mode
  :init
  (setq haskell-compile-cabal-build-command "stack build")
  :config
  (define-key haskell-mode-map (kbd "C-c i") 'haskell-navigate-imports)
  (define-key haskell-mode-map (kbd "C-c C-f") 
    (lambda () (interactive)
      (unless (looking-back " ")(insert " "))
      (insert "-> ")))
  (define-key haskell-mode-map (kbd "C-c C-b") 
    (lambda () (interactive)
      (unless (looking-back " ")(insert " "))
      (insert "<- ")))
  (define-key haskell-mode-map (kbd "C-c C-c") 
    (lambda () (interactive)
      (haskell-compile)))
  )




;; CSS MODE
(setq css-indent-offset 2)


