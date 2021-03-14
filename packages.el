;;; packages.el --- w3m layer packages file for Spacemacs.
;;
;; Copyright (c) 2012-2017 Sylvain Benner & Contributors
;;
;; Author: Kuroi Mato <venmos@fuck.gfw.es>
;; URL: https://github.com/syl20bnr/spacemacs
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

;;; Code:

(setq w3m-packages
      '(
        w3m
        helm-w3m
        ))

(defun v/w3m-save-buffer-to-file ()
  (interactive)
  (let* ((curr (buffer-file-name))
         (new (read-file-name
               "Save to file: " nil nil nil
               (and curr (file-name-nondirectory curr))))
         (mustbenew (if (and curr (file-equal-p new curr)) 'excl t)))
    (if (use-region-p)
        (write-region (region-beginning) (region-end) new nil nil nil mustbenew)
      (save-restriction
        (widen)
        (write-region (point-min) (point-max) new nil nil nil mustbenew)))))

(defun v/w3m-player-movie ()
  (interactive)
  (let ((link (w3m-anchor)))
    (if (not link)
        (message "The point is not link.")
   (cond ((string-match "/\\/www\\.youtube\\.com\\/watch\/?" link)
          (message (concat "loading from youtube..." link))
          (call-process "mpv" nil nil nil link))
         ((string-match "/\\/www\\.bilibili\\.com\\/video\/" link)
            (message (concat "loading from bilibili..." link))
            (call-process "bilidan" nil nil nil link)))
   (message "Sorry, Playback error. please check url."))))

(defun v/w3m-copy-link ()
  (interactive)
  (let ((link (w3m-anchor)))
    (if (not link)
        (message "The point is not link.")
      (kill-new link)
      (message "Copy \"%s\" to clipboard." link))))

(defun w3m/init-helm-w3m ()
  "Initializes helm-w3m and adds keybindings for its exposed functionalities."
  (use-package helm-w3m
    :commands (helm-w3m-bookmarks)
    :init
    (progn
      (spacemacs/set-leader-keys
        "awb" 'helm-w3m-bookmarks))))

(defun v/w3m-open-url-with (fn url)
  "Open url according to w3m url open function 'fn', and auto handle url prefix"
  (cond ((string-prefix-p "http://" url) (funcall fn url))
        ((string-prefix-p "https://" url) (funcall fn url))
        (t (funcall fn (concat "http://" url)))))

(defun v/w3m-open-url (url)
  "Opens url in new w3m session with 'http://' appended"
  (interactive
   (list (read-string "Enter website address (default: google.com):" nil nil "google.com" nil )))
  (v/w3m-open-url-with 'w3m-goto-url url))

(defun v/w3m-open-url-new-session (url)
  "Opens url in new w3m session with 'http://' appended"
  (interactive
   (list (read-string "Enter website address (default: google.com):" nil nil "google.com" nil )))
  (v/w3m-open-url-with 'w3m-goto-url-new-session url))

(defun w3m/init-w3m()
  "Initializes w3m and adds keybindings for its exposed functionalities."
  (use-package w3m
    :defer t
    :init
    (progn
      (spacemacs/declare-prefix "aw" "w3m")
      (spacemacs/set-leader-keys
        "awo" 'v/w3m-open-url
        "awf" 'w3m-find-file
        "aws" 'w3m-search)
      (spacemacs/declare-prefix-for-mode 'w3m-mode "mt" "toggles")
      (spacemacs/set-leader-keys-for-major-mode 'w3m-mode
        ;; "ti" 'w3m-toggle-inline-image
        ;; "tI" 'w3m-toggle-inline-images

        "p" 'v/w3m-player-movie
        "y" 'v/w3m-copy-link
        "f" 'w3m-find-file

        "o" 'v/w3m-open-url
        "O" 'v/w3m-open-url-new-session
        "t" 'w3m-view-this-url-new-session
        "T" 'w3m-create-empty-session

        "s" 'w3m-search
        "S" 'w3m-search-new-session
        "l" 'w3m-next-buffer

        "h" 'w3m-previous-buffer
        "x" 'w3m-delete-buffer
        "d" 'v/w3m-save-buffer-to-file
        "D" 'w3m-save-buffer))
    (progn
      (evilified-state-evilify-map w3m-mode-map
        :mode w3m-mode
        :eval-after-load w3m
        :bindings
        "0" 'evil-digit-argument-or-evil-beginning-of-line
        "$" 'evil-end-of-line
        "f" 'evil-find-char
        "F" 'evil-find-char-backward

        "o" 'ace-link-w3m

        "]]" 'w3m-next-form
        "[[" 'w3m-previous-form

        "H" 'w3m-view-previous-page
        "L" 'w3m-view-next-page
        "^" 'w3m-view-parent-page

        "gf" 'w3m-view-source
        "gh" 'w3m-view-header

        "d" 'w3m-download-this-url
        "M-d" 'w3m-download

        "I" 'w3m-view-image
        "M-i" 'w3m-save-image
        "mti" 'w3m-toggle-inline-image
        "mtI" 'w3m-toggle-inline-images

        "ge" 'w3m-bookmark-edit
        "ga" 'w3m-bookmark-add-current-url
        "gm" 'w3m-view-url-with-external-browser
        "gb" 'helm-w3m-bookmarks
        "gB" 'w3m-bookmark-view

        "gr" 'w3m-reload-this-page
        "gR" 'w3m-reload-all-pages

        "q" 'w3m-close-window
        "ZQ" 'w3m-quit
        "ZZ" 'quit-window))))

(with-eval-after-load 'w3m
  (define-key w3m-mode-map (kbd "C-f") 'evil-scroll-page-down)
  (define-key w3m-mode-map (kbd "C-b") 'evil-scroll-page-up)
  (define-key w3m-mode-map (kbd "SPC") 'evil-evilified-state))

(defun v/init-w3m ()
  (use-package w3m
    :init
    (progn
      (setq browse-url-browser-function 'w3m-goto-url-new-session
            w3m-user-agent "Mozilla/5.0 (Linux; U; Android 2.3.3; zh-tw; HTC_Pyramid Build/GRI40) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533."
            w3m-coding-system 'utf-8
            w3m-file-coding-system 'utf-8
            w3m-file-name-coding-system 'utf-8
            w3m-input-coding-system 'utf-8
            w3m-output-coding-system 'utf-8
            w3m-terminal-coding-system 'utf-8))))

;;; packages.el ends here
