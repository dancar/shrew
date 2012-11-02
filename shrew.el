;; shrew.el


(defvar shrew-current-project-dir
  "~/dev"
  "Current project dir")

(defvar shrew-buffer-name
  " *Shrew*"
  "Shrew buffer name")

(define-derived-mode shrew-mode
  special-mode
  "Shrew"
  "Major mode for Shrew.
          \\{shrew-mode-map}"
  (message "Starting shrew-mode")
  (setq shrew-base-list
        (split-string
         (with-temp-buffer
           (shell-command
            (concat "find " shrew-current-project-dir " -type d -maxdepth 1") t)
           (buffer-string))
         "\n"
         t))
  (shrew-update-buffer)
  (shrew-start-minibuffer-listening)
  (read-from-minibuffer "Select: ")
  )

(define-key shrew-mode-map (kbd "<RET>") 'shrew-open-selected-file)
(define-key shrew-mode-map (kbd "q") 'shrew-quit)

(defun shrew-open-selected-file ()
  (interactive)
  (let
      (
       (selected-file
        (buffer-substring-no-properties (line-beginning-position) (line-end-position))
        )
       )
    (message "your file is %s" selected-file)
    (shrew-quit)
    ))

(defun shrew ()
  (interactive)
  (setq shrew-buffer (get-buffer-create shrew-buffer-name))
  (switch-to-buffer shrew-buffer)
  (shrew-mode)
  )

(defun shrew-update-buffer ()
  (let* (
         (mb-text (minibuffer-contents))
         (filtered-list
          (delete-if-not
           (lambda(file)
             (string-match mb-text file))
            shrew-base-list))
         (list-with-endlines
          (mapcar
           (lambda(x) (concat x "\n" ))
           filtered-list))
         (marked-list-with-endlines (cons (concat " ->" (car list-with-endlines) "\n") (cdr list-with-endlines)))
         (text (apply 'concat marked-list-with-endlines))
         )
    (with-current-buffer shrew-buffer
      (toggle-read-only nil)
      (erase-buffer)
      (insert
       (format "Filter-text: %s \n" mb-text ))
      (insert text)
      (toggle-read-only 1)
      )
    ))

(defun shrew-quit ()
  (interactive)
  (shrew-stop-minibuffer-listening)
  (quit-window)
  )

(defun shrew-get-dir-files (dir)
  (split-string
   (with-temp-buffer
     (shrew-insert-dir-files)
     "\n"
     t)))

(defun shrew-start-minibuffer-listening ()
  (setq shrew-minibuffer-timer
        (run-with-idle-timer 0.01 1 'shrew-check-minibuffer-input)))

(defun shrew-stop-minibuffer-listening ()
  (cancel-timer shrew-minibuffer-timer)
  )

(defun shrew-check-minibuffer-input ()
  (shrew-update-buffer)
  )


;;;;stolen from helm:
;;   "Extract input string from the minibuffer and use it maybe."
;;   (let ((delay 0.1))
;;     (if (or (not delay) (helm-action-window))
;;         (helm-check-minibuffer-input-1)
;;         (helm-new-timer
;;          'helm-check-minibuffer-input-timer
;;          (run-with-idle-timer delay nil 'helm-check-minibuffer-input-1)))))

;; (defun helm-check-minibuffer-input-1 ()
;;   "Check minibuffer content."
;;   (with-helm-quittable
;;     (with-selected-window (or (active-minibuffer-window)
;;                               (minibuffer-window))
;;       (helm-check-new-input (minibuffer-contents)))))
;; (def
