;; If I do not set the gnutls-algorithm-priority, I get this error on Debian Buster,
;; Debugger entered -- Lisp error: (file-error "https://elpa.gnu.org/packages/archive-contents" "Bad Request")
(require 'gnutls)
(setq gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3")

(require 'package)
(let* ((no-ssl (and (memq system-type '(windows-nt ms-dos))
                    (not (gnutls-available-p))))
       (proto (if no-ssl "http" "https")))
  (when no-ssl
    (warn "\
Your version of Emacs does not support SSL connections,
which is unsafe because it allows man-in-the-middle attacks.
There are two things you can do about this warning:
1. Install an Emacs version that does support SSL and be safe.
2. Remove this warning from your init file so you won't see it again."))
  ;; Comment/uncomment these two lines to enable/disable MELPA and MELPA Stable as desired
  (add-to-list 'package-archives (cons "melpa" (concat proto "://melpa.org/packages/")) t)
  ;;(add-to-list 'package-archives (cons "melpa-stable" (concat proto "://stable.melpa.org/packages/")) t)
  (when (< emacs-major-version 24)
    ;; For important compatibility libraries like cl-lib
    (add-to-list 'package-archives (cons "gnu" (concat proto "://elpa.gnu.org/packages/")))))
(package-initialize)

(eval-when-compile
  (require 'use-package))

;; KEYMAP
;; C-;            completion-at-point 
;; C-<tab>        hippe-expansion (consulting more source for generating expansions)
;; <f1>           'compile    generic "compile project"
;; <f2>           'next-error skips to next error from last compile
;; <f3>           'recompile  
;; <f4>           'cht/search   lookup whatever is under point inteligently
;; <f11>          zoom in out

(setq inhibit-startup-message t)
(server-start)

(add-to-list 'default-frame-alist '(width  . 136))
(add-to-list 'default-frame-alist '(height . 44))
(add-to-list 'default-frame-alist '(font . "Mono-15"))

(scroll-bar-mode -1)
(tool-bar-mode -1)
(show-paren-mode 1)

(load-theme 'alect-black t)
(global-font-lock-mode 1)

(global-set-key (kbd "C-;") 'completion-at-point)
(global-auto-revert-mode t)

(setq exec-path (append (list (expand-file-name "~/.local/bin")
                              (expand-file-name "~/bin"))
                        exec-path))

(use-package desktop
  :ensure t
  :config 
  (progn
    (desktop-save-mode 1)
    (setq-default
     desktop-load-locked-desktop t
     desktop-restore-eager 10)))

(setq-default backup-directory-alist `(("." . "~/.emacs.d/saves"))
      backup-by-copying t
      delete-old-versions t
      kept-new-versions 6
      kept-old-versions 2
      version-control t
      vc-follow-symlinks t
      indent-tabs-mode nil
      debug-on-error t)

(global-set-key (kbd "C-<tab>") 'hippie-expand)
(setq hippie-expand-try-functions-list
      '(try-expand-all-abbrevs try-expand-dabbrev
	try-expand-dabbrev-all-buffers try-expand-dabbrev-from-kill
	try-complete-lisp-symbol-partially try-complete-lisp-symbol))
(define-key minibuffer-local-map (kbd "C-<tab>") 'hippie-expand)

(setq-default grep-save-buffers nil)
(setq-default compilation-scroll-output 'first-error)

;;; auto insertions
;;; for when you open files with well known extensions and want them
;;; boilerplated automatically.
(use-package autoinsert
  :config
  (progn
    (auto-insert-mode t)
    (add-hook 'find-file-hook 'auto-insert)
    ;; do not ask about auto-insertions, just do them
    (setq-default auto-insert-query nil)
    ;; format of auto-insert mini language
    ;; alist of (matcher skeleton)
    ;; where matcher is either
    ;;    mode-name symbol, eg. 'cc-mode
    ;;    regex matching file name, eg. (rx (seq ".el" eos))
    ;;    regex with description, g. ((rx (seq ".el" eos)) . "Emacs lisp files")
    ;; 
    (add-to-list
     'auto-insert-alist
     `((,(rx (seq "."
                  (or (any "Hh")
                      "hh" "hpp" "hxx" "h++"))
             eos) . "C / C++ header")
       (replace-regexp-in-string
        "[^A-Z0-9]" "_"
        (replace-regexp-in-string
         "\\+" "P"
         (upcase (file-name-nondirectory buffer-file-name))))
       "/* " str " */" \n
       "/* Copyright (C) " (format-time-string "%Y") " Igalia. S.L. All rights reserved. */\n\n"
       _))))

(use-package color-moccur
  :ensure t
  :commands (isearch-moccur isearch-all)
  :bind (("M-s O" . moccur)
         :map isearch-mode-map
         ("M-o" . isearch-moccur)
         ("M-O" . isearch-moccur-all))
  :init
  (setq isearch-lazy-highlight t))

(defun insert-date ()
  (interactive)
  (insert (shell-command-to-string "echo -n $(date +'%a %d/%m/%Y')")))

(defun cht-text-mode-hook ()
  (local-set-key (kbd "C-;") 'ispell-complete-word)
  (flyspell-mode))
(add-hook 'text-mode-hook 'cht-text-mode-hook)

(use-package rainbow-delimiters
  :ensure t
  :config
  (add-hook 'prog-mode-hook 'rainbow-delimiters-mode))

(use-package ansi-color
  :ensure t)

(defun cht:display-ansi-colors ()
  "Convert ANSI terminal codes into colors across the whole buffer."
  (interactive)
  (ansi-color-apply-on-region (point-min) (point-max)))

;;
(setq org-todo-keywords
      '((sequence "TODO" "DOING" "STALLED" "|" "REVIEW" "DONE")))

(use-package magit
  :ensure t
  :bind (("C-x g" . magit-status)))

;; (use-package cc-mode
;;   :defer t
;;   :after compile
;;   :config
;;   (defun cht-c-mode-hook ()
;;     (hs-minor-mode)
;;     (local-set-key (kbd "C-c C-k") 'compile)
;;     (local-set-key (kbd "<f10>") 'hs-hide-block)
;;     (local-set-key (kbd "<f11>") 'hs-show-block))
;;   (add-hook 'cc-mode-hook 'cht-c-mode-hook)

(use-package tramp
  :defer 5
  :config
  ;; jww (2018-02-20): Without this change, tramp ends up sending hundreds of
  ;; shell commands to the remote side to ask what the temporary directory is.
  (put 'temporary-file-directory 'standard-value '("/tmp"))
  (setq tramp-default-method "ssh"  ;; faster than default scp
        tramp-auto-save-directory "~/.cache/emacs/backups"
        tramp-persistency-file-name "~/.emacs.d/data/tramp"))


(global-set-key (kbd "<f1>") 'compile)
(global-set-key (kbd "<f2>") 'next-error)
(global-set-key (kbd "<f3>") 'recompile)
(setq-default compilation-ask-about-save nil)

(defun cht-c-mode-hook ()
  (hs-minor-mode)
  (local-set-key (kbd "C-c C-k") 'compile)
  (local-set-key (kbd "M-/") 'lsp-find-references)
  (local-set-key (kbd "<f10>") 'hs-hide-block)
  (local-set-key (kbd "<f11>") 'hs-show-block))

(add-hook 'c-mode-common-hook 'cht-c-mode-hook)

(defconst my-cc-style
  '("k&r"
    (c-offsets-alist . ((innamespace . [0])))))
(setq c-default-style '((java-mode . "java")
                        (awk-mode . "awk")
                        (c++-mode . "my-cc-style")
                        (c-mode . "my-cc-style")
                        (other . "k&r")))

(use-package lsp-mode :commands lsp)
(use-package lsp-ui :commands lsp-ui-mode)
(use-package company-lsp :commands company-lsp)
;; I work on projects with too many files.
(setq lsp-enable-file-watchers nil)
;; disable client-side cache and sorting:
(setq company-transformers nil company-lsp-async t company-lsp-cache-candidates nil)
;; https://github.com/emacs-lsp/lsp-mode/issues/1342
;; without this, i get some very annoying edits happening automatically
(setq lsp-enable-on-type-formatting nil)

(use-package ccls
  :ensure t
  :hook ((c-mode c++-mode objc-mode cuda-mode) .
         (lambda ()
           ;; FIXME: This is specific to webkit and should be conditioned on that.
           (setq ccls-initialization-options
                 ;'(:index (:comments 0 :threads 8 :initalWhitelist [".*/WebCore/.*", ".*/WebKit/.*", ] :initialBlacklist [".*"]) :completion (:detailedLabel t)))
                 '(:index (:comments 0 :threads 8) :completion (:detailedLabel t)))

           (setq ccls-executable "ccls")
           (require 'ccls)
           ;(lsp)
           )))


;; Find it too distracting
;; (global-flycheck-mode 1)
;; (with-eval-after-load 'flycheck
;;   (add-hook 'flycheck-mode-hook #'flycheck-pycheckers-setup)
;;   (setq-default flycheck-disabled-checkers '(emacs-lisp-checkdoc)))

;; FIXME: Add to C mode scope somehow
(defun my-compile ()
  (interactive)
  (defvar compile-guess-command-table
    '((c-mode . "cc -Wall -Wextra -g %s -o %s -lm")
      (c++-mode . "c++ -Wall -Wextra -std=c++2a -g %s -o %s -lm")))
  (let ((command-for-mode
         (cdr (assq major-mode compile-guess-command-table))))
    (when (and command-for-mode (stringp buffer-file-name))
      (let* ((file-name (file-name-nondirectory buffer-file-name))
             (file-name-sans-prefix (when (and (string-match "\\.[^.]*\\'" file-name)
                                               (> (match-beginning 0) 0))
                                      (substring file-name 0 (match-beginning 0)))))
        (when file-name-sans-prefix
          (progn
            (let ((compile-command
                   (if (stringp command-for-mode)
                       (format command-for-mode
                               file-name file-name-sans-prefix)
                     (funcall command-for-mode
                              file-name file-name-sans-prefix)))
                  (compilation-ask-about-save nil))
              (message (format "CHT.....%S" compile-command))
              (compile compile-command))))))))
(global-set-key (kbd "<f5>") 'my-compile)
          
;;;###autoload
(define-skeleton cht-perl-template
  "Insert a copyright by $ORGANIZATION notice at cursor."
  "Company: "
  comment-start
  "Copyright (C) " `(format-time-string "%Y") " by "
  (or (getenv "ORGANIZATION")
      str)
  '(if (copyright-offset-too-large-p)
       (message "Copyright extends beyond `copyright-limit' and won't be updated automatically."))
  comment-end \n)

(define-skeleton cht/skel-fflush-msg
  "Insert a copyright by $ORGANIZATION notice at cursor."
  nil
  > "fprintf(stderr, \"CHT: " _ "\\n\"); fflush(stderr);")

(defun cht/c-common-mode-keys (map)
  "Set my personal keys for C and C++. 
Argument MAP is c-mode-map or c++-mode-map."
  (message "Setting keys for common c mode.")
  (define-key map '[(meta tab)]               #'hippie-expand)

  ;(define-key map '[(control b) (control b)]  #'compile)
  ;; macros, templates, skeletons:
  (define-key map (kbd "C-c m p") #'cht/skel-fflush-msg))

(add-hook 'c++-mode-hook
          (lambda ()
            ;; my keybindings
            (cht/c-common-mode-keys c++-mode-map)
            ))
(add-hook 'c-mode-hook
          (lambda ()
            ;; my keybindings
            (cht/c-common-mode-keys c-mode-map)
            ))

(use-package s
  :ensure t
  :defer t)
(require 's)

(use-package hydra
  :ensure t
  :defer t
  :config
  (defhydra hyrdra-zoom (global-map "<f11>")
    "zoom"
    ("+" text-scale-increase "in")
    ("-" text-scale-decrease "out")))

(use-package ivy
  :diminish
  :ensure t
  :demand t

  :bind (("C-x b" . ivy-switch-buffer)
         ("C-x B" . ivy-switch-buffer-other-window)
         ("M-H"   . ivy-resume))

  :bind (:map ivy-minibuffer-map
              ("<tab>" . ivy-alt-done)
              ("SPC"   . ivy-alt-done-or-space)
              ("C-d"   . ivy-done-or-delete-char)
              ("C-i"   . ivy-partial-or-done)
              ("C-r"   . ivy-previous-line-or-history)
              ("M-r"   . ivy-reverse-i-search))

  :bind (:map ivy-switch-buffer-map
              ("C-k" . ivy-switch-buffer-kill))

  :custom
  (ivy-dynamic-exhibit-delay-ms 200)
  (ivy-height 10)
  (ivy-initial-inputs-alist nil t)
  (ivy-magic-tilde nil)
  (ivy-re-builders-alist '((t . ivy--regex-ignore-order)))
  (ivy-use-virtual-buffers t)
  (ivy-wrap t)

  :preface
  (defun ivy-done-or-delete-char ()
    (interactive)
    (call-interactively
     (if (eolp)
         #'ivy-immediate-done
       #'ivy-delete-char)))

  (defun ivy-alt-done-or-space ()
    (interactive)
    (call-interactively
     (if (= ivy--length 1)
         #'ivy-alt-done
       #'self-insert-command)))

  (defun ivy-switch-buffer-kill ()
    (interactive)
    (debug)
    (let ((bn (ivy-state-current ivy-last)))
      (when (get-buffer bn)
        (kill-buffer bn))
      (unless (buffer-live-p (ivy-state-buffer ivy-last))
        (setf (ivy-state-buffer ivy-last)
              (with-ivy-window (current-buffer))))
      (setq ivy--all-candidates (delete bn ivy--all-candidates))
      (ivy--exhibit)))

  ;; This is the value of `magit-completing-read-function', so that we see
  ;; Magit's own sorting choices.
  (defun my-ivy-completing-read (&rest args)
    (let ((ivy-sort-functions-alist '((t . nil))))
      (apply 'ivy-completing-read args)))

  :config
  (ivy-mode 1)
  (ivy-set-occur 'ivy-switch-buffer 'ivy-switch-buffer-occur))

(use-package counsel
  :after ivy
  :ensure t
  :demand t
  :diminish
  :custom (counsel-find-file-ignore-regexp
           (concat "\\(\\`\\.[^.]\\|"
                   (regexp-opt completion-ignored-extensions)
                   "\\'\\)"))
  :bind (("C-*"     . counsel-org-agenda-headlines)
         ("C-x C-f" . counsel-find-file)
         ("C-c e l" . counsel-find-library)
         ("C-c e q" . counsel-set-variable)
         ("C-c c u" . counsel-unicode-char)
         ("C-c f"   . counsel-describe-function)
         ("C-x r b" . counsel-bookmark)
         ("M-x"     . counsel-M-x)
         ;; ("M-y"     . counsel-yank-pop)

         ("M-s f" . counsel-file-jump)
         ;; ("M-s g" . counsel-rg)
         ("M-s j" . counsel-dired-jump))
  :commands counsel-minibuffer-history
  :init
  (bind-key "M-r" #'counsel-minibuffer-history minibuffer-local-map)
  :config
  (add-to-list 'ivy-sort-matches-functions-alist
               '(counsel-find-file . ivy--sort-files-by-date))

  (defun counsel-recoll-function (string)
    "Run recoll for STRING."
    (if (< (length string) 3)
        (counsel-more-chars 3)
      (counsel--async-command
       (format "recollq -t -b %s"
               (shell-quote-argument string)))
      nil))

  (defun counsel-recoll (&optional initial-input)
    "Search for a string in the recoll database.
  You'll be given a list of files that match.
  Selecting a file will launch `swiper' for that file.
  INITIAL-INPUT can be given as the initial minibuffer input."
    (interactive)
    (counsel-require-program "recollq")
    (ivy-read "recoll: " 'counsel-recoll-function
              :initial-input initial-input
              :dynamic-collection t
              :history 'counsel-git-grep-history
              :action (lambda (x)
                        (when (string-match "file://\\(.*\\)\\'" x)
                          (let ((file-name (match-string 1 x)))
                            (find-file file-name)
                            (unless (string-match "pdf$" x)
                              (swiper ivy-text)))))
              :unwind #'counsel-delete-process
              :caller 'counsel-recoll)))

(use-package swiper
  :ensure t
  :after ivy
  :bind ("C-M-s" . swiper)
  :bind (:map swiper-map
              ("M-y" . yank)
              ("M-%" . swiper-query-replace)
              ("C-." . swiper-avy)
              ("M-c" . swiper-mc))
  :bind (:map isearch-mode-map
              ("C-o" . swiper-from-isearch)))


;; (use-package projectile
;;   :defer 5
;;   :ensure t
;;   :diminish
;;   :bind* (("C-c TAB" . projectile-find-other-file)
;;           ("C-c P" . (lambda () (interactive)
;;                        (projectile-cleanup-known-projects)
;;                        (projectile-discover-projects-in-search-path))))
;;   :bind-keymap ("C-c p" . projectile-command-map)
;;   :config
;;   ;(projectile-global-mode)

;;   (defun my-projectile-invalidate-cache (&rest _args)
;;     ;; We ignore the args to `magit-checkout'.
;;     (projectile-invalidate-cache nil))

;;   (eval-after-load 'magit-branch
;;     '(progn
;;        (advice-add 'magit-checkout
;;                    :after #'my-projectile-invalidate-cache)
;;        (advice-add 'magit-branch-and-checkout
;;                    :after #'my-projectile-invalidate-cache))))

;; (use-package counsel-projectile
;;   :after (counsel projectile)
;;   :config
;;   (counsel-projectile-mode 1))


;; also, too much scope, too much confusion
;; (use-package helm
;;   :diminish helm-mode
;;   :init
;;   (progn
;;     (require 'helm-config)
;;     (setq helm-candidate-number-limit 100)
;;     ;; From https://gist.github.com/antifuchs/9238468
;;     (setq helm-idle-delay 0.0 ; update fast sources immediately (doesn't).
;;           helm-input-idle-delay 0.01  ; this actually updates things
;;                                         ; reeeelatively quickly.
;;           helm-yas-display-key-on-candidate t
;;           helm-quick-update t
;;           helm-M-x-requires-pattern nil
;;           helm-ff-skip-boring-files t)
;;     (helm-mode))
;;   :bind (("C-c h" . helm-mini)
;;          ("C-h a" . helm-apropos)
;;          ("C-x C-b" . helm-buffers-list)
;;          ("C-x C-f" . helm-find-files)
;;          ("C-x b" . helm-buffers-list)
;;          ("M-y" . helm-show-kill-ring)
;;          ("M-x" . helm-M-x)
;;          ("C-x c o" . helm-occur)
;;          ("C-x c s" . helm-swoop)
;;          ("C-x c y" . helm-yas-complete)
;;          ("C-x c Y" . helm-yas-create-snippet-on-region)
;;          ("C-x c b" . my/helm-do-grep-book-notes)
;;          ("C-x c SPC" . helm-all-mark-rings)))

(use-package rust-mode
  :ensure t
  :defer t
  :init
  (require 'rust-mode)
  (add-to-list 'auto-mode-alist '("\\.rs\\'" . rust-mode))

  :config
  (use-package racer
    :ensure t
    :config
    (add-hook 'racer-mode-hook #'eldoc-mode)
    (add-hook 'racer-mode-hook #'company-mode)
    (setq-default racer-rust-src-path (expand-file-name "~/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/lib/rustlib/src/rust/src/"))
  (use-package cargo
    :ensure t
    :config
    (add-hook 'rust-mode-hook 'cargo-minor-mode))
  (use-package company-racer :ensure t)
  (use-package flycheck-rust
    :ensure t
    :config
    (add-hook #'flycheck-mode-hook #'flycheck-rust-setup))
  (defun my-rust-mode-hook ()
    (set (make-local-variable 'compile-command) "cargo run")
    (local-set-key (kdb "C-c <tab>") #'rust-format-buffer))
  (add-hook 'rust-mode-hook 'my-rust-mode-hook)
  (add-hook 'rust-mode-hook #'racer-mode)
  (define-key rust-mode-map (kbd "TAB") #'company-indent-or-complete-common)
  (setq rust-format-on-save t)))

(use-package rg
  :ensure t
  :commands (rg rg-project rg-dwim))
(rg-enable-default-bindings)

(defun elisp-insert-evaluation ()
  (interactive)
  (let ((current-prefix-arg t))
    (eval-last-sexp current-prefix-arg)))
(define-key emacs-lisp-mode-map (kbd "<f4>") #'elisp-insert-evaluation)

(setq cht-paths-to-top-level-search-directories-assoc
      (list
       (cons ".*/gst-build/.*" "/home/cht/gstreamer/gst-build/subprojects/")
       (cons ".*/WebKit/Tools/.*" "/home/cht/igalia/sources/WebKit/Tools/")
       (cons ".*/WebKit/Source/.*" "/home/cht/igalia/sources/WebKit/Source/")))

(defun cht-project-find-top-level-dir-for-path (current-dir database)
  (cond ((null database) nil)
        (t
         (let ((path-regex (caar database))
               (top-level-dir (cdar database)))
           (if (string-match path-regex current-dir)
               top-level-dir
             (cht-project-find-top-level-dir-for-path current-dir (cdr database)))))))

(use-package fzf
  :ensure t)

(defun cht-project-search ()
  (interactive)
  (let ((top-level-search-path (cht-project-find-top-level-dir-for-path buffer-file-name cht-paths-to-top-level-search-directories-assoc)))
    (if top-level-search-path
        (helm-grep-git-1 top-level-search-path)
      (error "No search path matches the cwd"))))
(defun wk-search ()
  (interactive)

  (fzf/start (expand-file-name "~/igalia/sources/WebKit/Source")
             (fzf/grep-cmd "git grep" fzf/git-grep-args)))
(global-set-key (kbd "<f9>") 'wk-search)

(require 'fzf)
;(global-set-key (kbd "<f1>") (lambda () (interactive) (fzf)))

(defun cht/org-examplify-region (beg end &optional results-switches inline)
  "Examplify the region by wrapping it in #+begin_example/#+end_example."
  (interactive "*r")
  (let ((size (count-lines beg end)))
    (save-excursion
      (cond ((= size 0))	      ; do nothing for an empty result
	    (t
	     (goto-char beg)
	     (insert "#+begin_example\n")
	     (let ((p (point)))
	       (if (markerp end) (goto-char end) (forward-char (- end beg)))
	       (org-escape-code-in-region p (point)))
	     (insert "#+end_example\n"))))))


(defun cht/revert-all-no-confirm ()
  "Revert all file buffers, without confirmation.
Buffers visiting files that no longer exist are ignored.
Files that are not readable (including do not exist) are ignored.
Other errors while reverting a buffer are reported only as messages."
  (interactive)
  (let (file)
    (dolist (buf  (buffer-list))
      (setq file  (buffer-file-name buf))
      (when (and file  (file-readable-p file))
        (with-current-buffer buf
          (with-demoted-errors "Error: %S" (revert-buffer t t)))))))

(defun webkit-resolve-traceback-line (line)
 "Resolve a non-symbolic trace to a symbolic function name using
addr2line

Example input lines

1   0x7fa0e43aa0fc /home/cturner/webkit/build-GTK-upstream-webkit-2.24-RelWithDebInfo/lib/libwebkit2gtk-4.0.so.37(+0x1ee50fc) [0x7fa0e43aa0fc]
and
2   0x7fa0dfba09c5 /usr/lib/x86_64-linux-gnu/libgobject-2.0.so.0(g_type_create_instance+0x1e5) [0x7fa0dfba09c5]

Line 1 has no symbol info, line 2 however does"

 (if (string-match " 0x[^/]+\\([^(]+\\)(\\([^+]*\\)\\+\\([0-9a-zA-Z]+\\)" line)
     (let ((lib-name (match-string 1 line))
	   (symbolic-name (match-string 2 line))
	   (offset (match-string 3 line)))
       (if (string= symbolic-name "")
	   (s-chomp (shell-command-to-string (format "addr2line -Cpse %s -f %s" lib-name offset)))
	 symbolic-name))
   (format "no frame for traceback line: %s\n" line)))

(defun webkit-backtrace-resolve-region ()
  "Iterate all trace back lines from WTFReportBacktrace, and resolve
their function names using addr2line. This is a problem when you call
WTFReportBacktrace in a RelWithDebInfo build, for some reason, despite
the debug info being in the shared objects, you don't get symbolic
function names for a number of frames."
  (interactive)
  (save-excursion
    (let* ((beg (region-beginning))
	   (end (region-end))
	   (resolved-lines
	    (mapcar #'webkit-resolve-traceback-line (s-lines (buffer-substring-no-properties beg end)))))
      (kill-region beg end)
      (insert (s-join "\n" resolved-lines)))))
(defun c++filt ()
  "Run c++filt over the active region"
  (interactive)
  (shell-command-on-region
   (region-beginning)
   (region-end)
   "c++filt"
   (current-buffer)
   t
   nil
   nil))

(defvar *webkit-trac-base-url* "https://trac.webkit.org/browser/webkit/trunk/")
(defun webkit-track-url-for-src-file ()
  (interactive)
  (let* ((buffer-name (buffer-file-name))
         (wk-src-path (s-chop-prefix "/home/cht/igalia/sources/WebKit/" buffer-name)))
    (browse-url (format "%s%s#L%s" *webkit-trac-base-url* wk-src-path (line-number-at-pos)))))

;(require 'elpy)
;(setq python-shell-interpreter "python"
;     python-shell-prompt-detect-failure-warning nil)

;; this was too distracting for me...

 (use-package elpy
   :ensure t
   :config
   (setq elpy-rpc-python-command "python3")
   :init
   (elpy-enable))


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   (quote
    ("04dd0236a367865e591927a3810f178e8d33c372ad5bfef48b5ce90d4b476481" "a0feb1322de9e26a4d209d1cfa236deaf64662bb604fa513cca6a057ddf0ef64" "7153b82e50b6f7452b4519097f880d968a6eaf6f6ef38cc45a144958e553fbc6" "690ae280f6d805719491ad46976be23a87799f2c7fa569003de463532af95e6c" "5ed25f51c2ed06fc63ada02d3af8ed860d62707e96efc826f4a88fd511f45a1d" "de1f10725856538a8c373b3a314d41b450b8eba21d653c4a4498d52bb801ecd2" default)))
 '(package-selected-packages
   (quote
    (clang-format dockerfile-mode geiser lsp-haskell projectile counsel hydra swiper ivy moccur-edit color-moccur color-moccur-edit yaml-mode alect-themes brutal-theme pydoc brutalist-theme elpy go-mode docker pyvenv rg meson-mode flycheck-pycheckers flycheck helm-git helm-git-grep fzf company-lsp lsp-ui ccls eglot-jl eglot xr cargo magit rainbow-delimiters rainbow-mode use-package racer helm-descbinds flycheck-rust company-racer)))
 '(safe-local-variable-values
   (quote
    ((eval ignore-errors
           (require
            (quote whitespace))
           (whitespace-mode 1))
     (whitespace-line-column . 79)
     (whitespace-style face indentation)
     (eval progn
           (c-set-offset
            (quote case-label)
            (quote 0))
           (c-set-offset
            (quote innamespace)
            (quote 0))
           (c-set-offset
            (quote inline-open)
            (quote 0)))))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(org-level-3 ((t (:inherit blue))))
 '(rainbow-delimiters-base-error-face ((t (:inherit rainbow-delimiters-base-face :foreground "firebrick1"))))
 '(rainbow-delimiters-depth-1-face ((t (:inherit rainbow-delimiters-base-face :foreground "dark gray"))))
 '(rainbow-delimiters-depth-2-face ((t (:inherit rainbow-delimiters-base-face :foreground "dark orange"))))
 '(rainbow-delimiters-depth-3-face ((t (:inherit rainbow-delimiters-base-face :foreground "dark green"))))
 '(rainbow-delimiters-depth-4-face ((t (:inherit rainbow-delimiters-base-face :foreground "dark magenta"))))
 '(rainbow-delimiters-depth-5-face ((t (:inherit rainbow-delimiters-base-face :foreground "gold"))))
 '(rainbow-delimiters-depth-6-face ((t (:inherit rainbow-delimiters-base-face :foreground "green1"))))
 '(rainbow-delimiters-depth-7-face ((t (:inherit rainbow-delimiters-base-face :foreground "orange red"))))
 '(rainbow-delimiters-depth-8-face ((t (:inherit rainbow-delimiters-base-face :foreground "coral1"))))
 '(rainbow-delimiters-depth-9-face ((t (:inherit rainbow-delimiters-base-face :foreground "HotPink1"))))
 '(rainbow-delimiters-mismatched-face ((t (:background "#FFDCDC" :underline (:color "red" :style wave)))))
 '(rainbow-delimiters-unmatched-face ((t (:background "#FFDCDC" :underline (:color "red" :style wave))))))

(use-package geiser
  :ensure t
  :config
  (setq geiser-active-implementations '(racket)))

(use-package clang-format
  :ensure t
  :config
  (global-set-key [C-M-tab] 'clang-format-region))
