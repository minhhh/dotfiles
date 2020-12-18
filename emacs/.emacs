;; Tell emacs where is your personal elisp lib dir
;; this is default dir for extra packages
(add-to-list 'load-path "~/.emacs.d/")

;; Enable ido mode with fuzzy matching
(require 'ido)
(ido-mode t)
(setq ido-enable-flex-matching t) ;; enable fuzzy matching

;; ENABLE AUTOCOMPLETE MODE
;; ------------------------
(add-to-list 'load-path "~/.emacs.d/auto-complete/")
(require 'auto-complete-config)
(add-to-list 'ac-dictionary-directories "~/.emacs.d/auto-complete/ac-dict/")
(ac-config-default)
(auto-complete-mode t)
(setq ac-auto-show-menu 0.0)

;; GENERAL
;; -------
;; Set window title to full filename
;;(setq frame-title-format '("Emacs @ " system-name ": %b %+%+ %f"))
(setq frame-title-format '("%b %+%+ %f"))
(tool-bar-mode -1)

;; show paren mode
(show-paren-mode t)

;; autopair
(require 'autopair)
(autopair-global-mode t) ;; enable autopair in all buffers

;; show and line
(setq column-number-mode t)
(global-linum-mode t)

;; change tab to 4 spaces
(global-set-key (kbd "TAB") 'tab-to-tab-stop)
(setq-default indent-tabs-mode nil)
(setq default-tab-width 4)
(setq tab-width 4)
(setq tab-stop-list (number-sequence 4 200 4))
(global-set-key (kbd "RET") 'newline-and-indent)

;; Enable whitespace
(global-whitespace-mode 1)
(setq whitespace-line-column 250)
(setq whitespace-display-mappings
       ;; all numbers are Unicode codepoint in decimal. try (insert-char 182 ) to see it
      '(
        (space-mark 32 [32] [46]) ; 32 SPACE, 183 MIDDLE DOT 「·」, 46 FULL STOP 「.」
        (newline-mark 10 [10]) ; 10 LINE FEED
        (tab-mark 9 [9655 9] [92 9]) ; 9 TAB, 9655 WHITE RIGHT-POINTING TRIANGLE 「▷」
        ))
;; (add-hook 'before-save-hook 'whitespace-cleanup) ;; remove whitespaces before save

;; setup backup directory
(setq backup-directory-alist `(("." . "~/.saves")))

;; Automatically save and restore sessions
(setq desktop-dirname             "~/.emacs.d/desktop/"
      desktop-base-file-name      "emacs.desktop"
      desktop-base-lock-name      "lock"
      desktop-path                (list desktop-dirname)
      desktop-save                t
      desktop-files-not-to-save   "^$" ;reload tramp paths
      desktop-load-locked-desktop nil)
(desktop-save-mode 0)

;; Theme
(load-file "~/.emacs.d/monokai-theme.el")
(color-theme-monokai)

;; KEY BINDING FOR LINE MANIPULATION
;; ---------------------------------
(defun kill-whole-line-new (arg)
  (interactive "p")
  (beginning-of-line)
  (kill-whole-line)
  )
;; (define-key global-map (kbd "C-S-k") 'kill-whole-line-new)
(define-key global-map (kbd "C-S-k") "\C-a\C-@\C-e\C-d\C-b\C-d\C-f")

(defun backward-kill-line (arg)
  "Kill ARG lines backward."
  (interactive "p")
  (kill-line (- 1 arg)))
(define-key global-map `[(,osxkeys-command-key backspace)] 'backward-kill-line)

(defun duplicate-line1 (arg)
  "Duplicate current line, leaving point in lower line."
  (interactive "*p")
  ;; save the point for undo
  (setq buffer-undo-list (cons (point) buffer-undo-list))
  ;; local variables for start and end of line
  (let ((bol (save-excursion (beginning-of-line) (point)))
        eol)
    (save-excursion
      ;; don't use forward-line for this, because you would have
      ;; to check whether you are at the end of the buffer
      (end-of-line)
      (setq eol (point))
      ;; store the line and disable the recording of undo information
      (let ((line (buffer-substring bol eol))
            (buffer-undo-list t)
            (count arg))
        ;; insert the line arg times
        (while (> count 0)
          (newline)         ;; because there is no newline in 'line'
          (insert line)
          (setq count (1- count)))
        )
      ;; create the undo information
      (setq buffer-undo-list (cons (cons eol (point)) buffer-undo-list)))
    ) ; end-of-let

  ;; put the point in the lowest line and return
  (next-line arg)
  (previous-line arg))

(define-key global-map `[(,osxkeys-command-key shift d)] 'duplicate-line1)

(defun open-previous-line (arg)
      "Open a new line before the current one.
     See also `newline-and-indent'."
      (interactive "p")
      (beginning-of-line)
      (open-line arg)
      (when newline-and-indent
        (indent-according-to-mode)))
(define-key global-map `[(,osxkeys-command-key shift k)] 'open-previous-line)

(defun join-lines (arg)
      (interactive "p")
      (end-of-line)
      (delete-char 1)
      (delete-horizontal-space)
      (insert " "))
(define-key global-map `[(,osxkeys-command-key j)] 'join-lines)

;; TEXT MANIPULATION
(define-key global-map (kbd "A-k A-u") 'upcase-region)
(define-key global-map (kbd "A-k A-l") 'downcase-region)
(define-key global-map (kbd "A-/") 'comment-region-or-line)
(define-key global-map (kbd "A-M-/") 'uncomment-region-or-line)
(define-key global-map (kbd "C-S-t") 'delete-trailing-whitespace)

;; Search for current selection or current word at point
;; by Nikolaj Schumacher, 2008-10-20. Released under GPL.
(defun semnav-up (arg)
  (interactive "p")
  (when (nth 3 (syntax-ppss))
    (if (> arg 0)
        (progn
          (skip-syntax-forward "^\"")
          (goto-char (1+ (point)))
          (decf arg))
      (skip-syntax-backward "^\"")
      (goto-char (1- (point)))
      (incf arg)))
  (up-list arg))

;; by Nikolaj Schumacher, 2008-10-20. Released under GPL.
(defun extend-selection (arg &optional incremental)
  "Select the current word.
Subsequent calls expands the selection to larger semantic unit."
  (interactive (list (prefix-numeric-value current-prefix-arg)
                     (or (region-active-p)
                         (eq last-command this-command))))
  (if incremental
      (progn
        (semnav-up (- arg))
        (forward-sexp)
        (mark-sexp -1))
    (if (> arg 1)
        (extend-selection (1- arg) t)
      (if (looking-at "\\=\\(\\s_\\|\\sw\\)*\\_>")
          (goto-char (match-end 0))
        (unless (memq (char-before) '(?\) ?\"))
          (forward-sexp)))
      (mark-sexp -1))))
(define-key global-map (kbd "A-r") 'extend-selection)

(defvar isearch-initial-string nil)
(defun isearch-set-initial-string ()
  (remove-hook 'isearch-mode-hook 'isearch-set-initial-string)
  (setq isearch-string isearch-initial-string)
  (isearch-search-and-update))
(defun isearch-forward-at-point (&optional regexp-p no-recursive-edit)
  "Interactive search forward for the symbol at point."
  (interactive "P\np")
  (if regexp-p (isearch-forward regexp-p no-recursive-edit)
    (let* ((begin (region-beginning))
           (end (region-end)))
      (if (region-active-p)
          (progn
            (goto-char begin)
            (setq isearch-initial-string (buffer-substring begin end))
            (add-hook 'isearch-mode-hook 'isearch-set-initial-string)
            (isearch-forward regexp-p)))
          (progn
            (forward-char-same-line 1)
            (backward-word)
            (set-mark (point))
            (forward-word)))))

(define-key global-map (kbd "A-d") 'isearch-forward-at-point)
   ;  ; ; ; ; ; ;
(add-to-list 'load-path "~/.emacs.d/iedit")
(require 'iedit)
(define-key global-map (kbd "C-A-g") 'iedit-mode)

;; KEY BINDING FOR MOVING AROUND
;; -------------------------------
(define-key global-map (kbd "M-<up>") "\M-{")
(define-key global-map (kbd "M-<down>") "\M-}")

;; Go to matching parenthese
(defun forward-or-backward-sexp (&optional arg)
  "Go to the matching parenthesis character if one is adjacent to point."
  (interactive "^p")
  (cond ((looking-at "\\s(") (forward-sexp arg))
        ((looking-back "\\s)" 1) (backward-sexp arg))
        ;; Now, try to succeed from inside of a bracket
        ((looking-at "\\s)") (forward-char) (backward-sexp arg))
        ((looking-back "\\s(" 1) (backward-char) (forward-sexp arg))))
(define-key global-map (kbd "M-m") 'forward-or-backward-sexp)

;; KEY BINDING FOR SEARCHING STUFF
;; -------------------------------

;; First, configure HELM
(add-to-list 'load-path "~/.emacs.d/helm")
(require 'helm-config)
(setq helm-idle-delay 0.1)
(setq helm-input-idle-delay 0.1)
(setq helm-c-locate-command "mdfind -name %s %s")

;; Search in all buffers
(eval-after-load "helm-regexp"
  '(helm-attrset 'follow 1 helm-source-moccur))

(defun my-helm-multi-all ()
  "multi-occur in all buffers backed by files."
  (interactive)
  (helm-multi-occur
   (delq nil
         (mapcar (lambda (b)
                   (when (buffer-file-name b) (buffer-name b)))
                 (buffer-list)))))
(global-set-key (kbd "C-o") 'my-helm-multi-all)

(define-key global-map `[(,osxkeys-command-key meta f)] 'query-replace)

;; Use project tile grep instead of rgrep
;;(define-key global-map `[(,osxkeys-command-key shift f)] 'rgrep)
(define-key global-map `[(,osxkeys-command-key shift f)] 'projectile-grep)

(add-to-list 'load-path "~/.emacs.d/projectile/")
(add-to-list 'load-path "~/.emacs.d/s/")
(add-to-list 'load-path "~/.emacs.d/dash/")
(require 'projectile)
(require 'helm-projectile)
(projectile-global-mode t)
;;(setq projectile-use-native-indexing t)
;;(setq projectile-enable-caching t) ;; Use projectile cache, remember to C-c p i to invalidate cache

;; Use helm-projectile instead of helm-locate
;;(global-set-key (kbd "C-p") 'helm-locate)
(global-set-key (kbd "C-p") 'helm-projectile)

;; SPEEDBAR
;;(speedbar 1)
(put 'downcase-region 'disabled nil)
(put 'scroll-left 'disabled nil)
