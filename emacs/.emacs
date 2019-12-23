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

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(eval-when-compile
  (require 'use-package))

(server-start)

(scroll-bar-mode -1)
(tool-bar-mode -1)
(menu-bar-mode -1)
(show-paren-mode 1)

(add-to-list 'default-frame-alist '(width  . 136))
(add-to-list 'default-frame-alist '(height . 44))
(add-to-list 'default-frame-alist '(font . "Hack-13"))

(load-theme 'tsdh-dark t)

(global-set-key (kbd "C-;") 'completion-at-point)

(setq-default backup-directory-alist `(("." . "~/.saves"))
      backup-by-copying t
      delete-old-versions t
      kept-new-versions 6
      kept-old-versions 2
      version-control t
      vc-follow-symlinks t
      indent-tabs-mode nil
      debug-on-error t)

(desktop-save-mode 1)
(setq-default desktop-restore-eager 10 ; max number of desktop to restore at startup
              desktop-load-locked-desktop t ; load desktops without asking, even in error cases, woohoo
              desktop-save t ; always save
              desktop-dirname "/home/cht/.emacs-desktop/"
              desktop-base-file-name "desktop-"
)
(add-to-list 'desktop-path "/home/cht/.emacs-desktop/")
;desktop-path

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

(use-package helm
  :diminish helm-mode
  :ensure t
  :init
  (require 'helm-config)
  (helm-mode 1)
  :bind (("C-c h" . helm-mini)
	 ("C-h a" . helm-apropos)
	 ("C-x C-b" . helm-buffers-list)
	 ("C-x b" . helm-buffers-list)
	 ("M-y" . helm-show-kill-ring)
	 ("C-x c o" . helm-occur)
	 ("M-x" . helm-M-x)
         ("<f9>" . test-helm)
	 ("C-x C-f" . helm-find-files)))

(use-package magit
  :ensure t
  :bind (("C-x g" . magit-status)))

(use-package cc-mode
  :defer t
  :after compile
  :config
  (defun cht-c-mode-hook ()
    (hs-minor-mode)
    (local-set-key (kbd "C-c C-k") 'compile)
    (local-set-key (kbd "<f10>") 'hs-hide-block)
    (local-set-key (kbd "<f11>") 'hs-show-block))
  (add-hook 'cc-mode-hook 'cht-c-mode-hook)

  (defconst my-cc-style
  '("k&r"
    (c-offsets-alist . ((innamespace . [0])))))
  (setq c-default-style '((java-mode . "java")
                          (awk-mode . "awk")
                          (c++-mode . "my-cc-style")
                          (c-mode . "my-cc-style")
                          (other . "k&r")))
  (defvar compile-guess-command-table
    '((c-mode . "cc -Wall -Wextra -g %s -o %s -lm")
      (c++-mode . "c++ -Wall -Wextra -std=c++17 -g %s -o %s -lm")))
  (defun compile-guess-command ()
    (let ((command-for-mode (cdr (assq major-mode compile-guess-command-table))))
      (when (and command-for-mode (stringp buffer-file-name))
        (let* ((file-name (file-name-nondirectory buffer-file-name))
               (file-name-sans-prefix (when (and (string-match "\\.[^.]*\\'" file-name)
                                                 (> (match-beginning 0) 0))
                                        (substring file-name 0 (match-beginning 0)))))
          (when file-name-sans-suffix
            (progn
              (make-local-variable 'compile-command)
              (setq compile-commond
                    (if (stringp command-for-mode)
                        (format command-for-mode
                                file-name filename-sans-suffix)
                      (funcall command-for-mode
                               file-name file-name-sans-suffix)))
              compile-command)))))))
          
(use-package helm-descbinds
  :defer t
  :ensure t
  :bind (("C-h b" . helm-descbinds)
	 ("C-h w" . helm-descbinds)))

(use-package s
  :ensure t
  :defer t)
(require 's)

(global-set-key (kbd "C-<tab>") 'hippie-expand)
(setq hippie-expand-try-functions-list
      '(try-expand-all-abbrevs try-expand-dabbrev
	try-expand-dabbrev-all-buffers try-expand-dabbrev-from-kill
	try-complete-lisp-symbol-partially try-complete-lisp-symbol))
(define-key minibuffer-local-map (kbd "C-<tab>") 'hippie-expand)

(use-package company               
  :ensure t
  :defer t
  :init (global-company-mode)
  :config
  (progn
    ;; Use Company for completion
    (bind-key [remap completion-at-point] #'company-complete company-mode-map)

    (setq company-tooltip-align-annotations t
          ;; Easy navigation to candidates with M-<n>
          company-show-numbers t)
    (setq company-dabbrev-downcase nil))
  :diminish company-mode)

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
    (set (make-local-variable 'compile-command) "cargo run"))
  (add-hook 'rust-mode-hook 'my-rust-mode-hook)
  (add-hook 'rust-mode-hook #'racer-mode)
  (define-key rust-mode-map (kbd "TAB") #'company-indent-or-complete-common)
  (setq rust-format-on-save t)))

(progn
  (require 'html-mode)
(define-skeleton html-headline-6
  "HTML strong tag"
  nil
  "<strong>" _ "</strong>")

  (define-key html-mode-map (kbd "C-c b") '


(defun elisp-insert-evaluation ()
  (interactive)
  (let ((current-prefix-arg t))
    (eval-last-sexp current-prefix-arg)))
(define-key emacs-lisp-mode-map (kbd "<f4>") #'elisp-insert-evaluation)

(setq cht-paths-to-top-level-search-directories-assoc
      (list
       (cons ".*/gst-build/.*" "/home/cht/gstreamer/gst-build/subprojects/")
       (cons ".*/WebKit/Tools/.*" "/home/cht/webkit/WebKit/Tools/")
       (cons ".*/WebKit/Source/.*" "/home/cht/webkit/WebKit/Source/")))

(defun cht-project-find-top-level-dir-for-path (current-dir database)
  (cond ((null database) nil)
        (t
         (let ((path-regex (caar database))
               (top-level-dir (cdar database)))
           (if (string-match path-regex current-dir)
               top-level-dir
             (cht-project-find-top-level-dir-for-path current-dir (cdr database)))))))
(defun cht-project-search ()
  (interactive)
  (let ((top-level-search-path (cht-project-find-top-level-dir-for-path buffer-file-name cht-paths-to-top-level-search-directories-assoc)))
    (if top-level-search-path
        (helm-grep-git-1 top-level-search-path)
      (error "No search path matches the cwd"))))
(global-set-key (kbd "<f9>") 'cht-project-search)

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

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   (quote
    (cargo magit rainbow-delimiters rainbow-mode use-package racer helm-descbinds flycheck-rust company-racer))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(rainbow-delimiters-base-error-face ((t (:inherit rainbow-delimiters-base-face :foreground "firebrick1"))))
 '(rainbow-delimiters-depth-1-face ((t (:inherit rainbow-delimiters-base-face :foreground "pale green"))))
 '(rainbow-delimiters-depth-2-face ((t (:inherit rainbow-delimiters-base-face :foreground "sandy brown"))))
 '(rainbow-delimiters-depth-3-face ((t (:inherit rainbow-delimiters-base-face :foreground "PaleGreen2"))))
 '(rainbow-delimiters-depth-4-face ((t (:inherit rainbow-delimiters-base-face :foreground "thistle1"))))
 '(rainbow-delimiters-depth-5-face ((t (:inherit rainbow-delimiters-base-face :foreground "papaya whip"))))
 '(rainbow-delimiters-depth-6-face ((t (:inherit rainbow-delimiters-base-face :foreground "green1"))))
 '(rainbow-delimiters-depth-7-face ((t (:inherit rainbow-delimiters-base-face :foreground "white"))))
 '(rainbow-delimiters-depth-8-face ((t (:inherit rainbow-delimiters-base-face :foreground "coral1"))))
 '(rainbow-delimiters-depth-9-face ((t (:inherit rainbow-delimiters-base-face :foreground "HotPink1")))))
