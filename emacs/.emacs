(require 'package)
(let* ((no-ssl (and (memq system-type '(windows-nt ms-dos))
                    (not (gnutls-available-p))))
       (proto (if no-ssl "http" "https")))
  (when no-ssl (warn "\
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

(add-to-list 'package-archives
             '("melpa-stable" . "https://stable.melpa.org/packages/") t)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(font-use-system-font t)
 '(org-capture-templates nil)
 '(package-selected-packages
   (quote
    (flycheck-rust cargo company-lsp ledger-mode magit company racer borland-blue-theme zones helm melpa-upstream-visit)))
 '(vc-follow-symlinks t))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(setq backup-directory-alist `(("." . "~/.saves")))
(setq backup-by-copying t)
(setq delete-old-versions t
  kept-new-versions 6
  kept-old-versions 2
  version-control t)

(global-set-key (kbd "C-<tab>") 'hippie-expand)
(setq hippie-expand-try-functions-list
      '(try-expand-all-abbrevs try-expand-dabbrev
	try-expand-dabbrev-all-buffers try-expand-dabbrev-from-kill
	try-complete-lisp-symbol-partially try-complete-lisp-symbol))
(define-key minibuffer-local-map (kbd "C-<tab>") 'hippie-expand)

(setq kept-old-versions 0
      kept-new-versions 5
      dired-kept-versions 5
      delete-old-versions t)

;; default to case insensitive
(eval-after-load "grep"
  '(grep-apply-setting 'grep-command "grep --color -niH -e "))

;; enter the debugger whenever something goes wrong
(setq-default debug-on-error t)

;; helm
(require 'helm-config)
(global-set-key (kbd "M-x") #'helm-M-x)
(global-set-key (kbd "C-x r b") #'helm-filtered-bookmarks)
(global-set-key (kbd "C-x C-f") #'helm-find-files)
(helm-mode 1)

(set-face-attribute 'default nil :font "Mono-12" )
(set-frame-font "Mono-12" nil t)

(desktop-save-mode 1)
;; this is used to make sure we don't try and restore the desktop in
;; daemon mode, doing so doesn't make sense since the daemon cannot
;; use GUI features to restore such things.
(add-hook 'after-make-frame-functions 'desktop-read)
;; desktop-path is a handy variable

(server-start)

(require 's)  ; string library

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

(load-theme 'borland-blue t)

(require 'ansi-color)
(defun display-ansi-colors ()
  (interactive)
  (ansi-color-apply-on-region (point-min) (point-max)))

(setq-default indent-tabs-mode nil)
;(define-key 'c-mode-map (kbd "C-c C-k") #'compile)
(add-hook 'c-mode-common-hook 'flyspell-prog-mode)
(setq-default c-basic-offset 4)

(require 'rust-mode)
(define-key rust-mode-map (kbd "TAB") #'company-indent-or-complete-common)
(add-hook 'rust-mode-hook #'racer-mode)
(add-hook 'racer-mode-hook #'eldoc-mode)
(add-hook 'racer-mode-hook #'company-mode)
(add-hook 'rust-mode-hook 'cargo-minor-mode)

(setq racer-rust-src-path "/home/cturner/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/lib/rustlib/src/rust/src")
(setq company-tooltip-align-annotations t)

(add-hook 'rust-mode-hook
          (lambda ()
            (local-set-key (kbd "C-c <tab>") #'rust-format-buffer)))
(add-hook 'flycheck-mode-hook #'flycheck-rust-setup)
