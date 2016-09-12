(defun org-toggle-latex-overlays (arg)
  "Toggle LaTeX fragments.  The prefix ARG is passed to `org-preview-latex-fragment'."
  (interactive "P")
  (if (org--list-latex-overlays)
      (org-remove-latex-fragment-image-overlays)
    (org-toggle-latex-fragment '(16)))
  nil)


(plist-put org-format-latex-options :scale 1.8)

(defun tq-turn-it-in ()
  "Save all buffers, add files, create a SYSTEM-INFO file, commit them and push.
Check *techela log* for error messages."
  (interactive)
  (tq-insert-system-info)

  ;; Let's assume turning in will work, and set the time.
  (gb-set-filetag "TURNED-IN" (current-time-string))

  ;; make sure all buffers are saved
  (save-some-buffers t t)
  
  (mygit "git add *")
  
  (let ((status (car (mygit "git commit -am \"turning in\""))))
    (unless (or (= 0 status)		; no problem
		(= 1 status))		; no change in files
      (gb-set-filetag "TURNED-IN"
		      (concat "Failed: " (current-time-string)))
      (switch-to-buffer "*techela log*")
      (error "Problem committing.  Check the logs")))

  (unless (= 0 (car (mygit "git push -u origin master")))
    (mygit "git commit --amend -m \"*** TURNING IN FAILED ***.\"")
    (gb-set-filetag "TURNED-IN" (concat "Failed: " (current-time-string)))
    (save-buffer)
    (switch-to-buffer "*techela log*")
    (error "Problem pushing to server.  Check the logs"))

  (save-buffer)
  (message
   (let ((choices '("Woohoo, you turned it in!"
		    "Awesome, you rocked that turn in!"
		    "Way to go, you turned it in!"
		    "Great job, you turned it in!"
		    "Sweet, you turned it in!"
		    "Booya, you turned it in!")))
     (nth (cl-random (length choices)) choices))))


;; * Ipython notebook

(org-add-link-type
 "ipynb"
 (lambda (path)
   (when (not (file-exists-p path))
     (with-temp-file path
       (insert "{
 \"cells\": [],
 \"metadata\": {},
 \"nbformat\": 4,
 \"nbformat_minor\": 0
}")))
   (start-process-shell-command "jupyter" nil (format "jupyter notebook %s" path))))


(load-file (expand-file-name "lisp/org-highlighter.el" tq-course-directory))
(define-key org-mode-map (kbd "M-h") 'org-highlighter/body)
