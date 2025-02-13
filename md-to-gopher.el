(defun md-to-gopher ()
  "Find the date and title in the buffer, print them to the minibuffer, and write the remaining content to a text file."
(interactive)
  (let ((content (buffer-string))
        (output-dir "~/") ;; Change this to your desired directory
        (gopher-dir "~/gopher/") ;; Change this to your gopher directory
        title date)
;; Ensure the directory exists
    (unless (file-exists-p output-dir)
      (make-directory output-dir t))
    ;; Extract frontmatter
    (when (string-match (rx bol "+++" (* space) eol
                            (group (*? anything))
                            "+++" (* space) eol
                            (group (* anything))) content)
      (let ((frontmatter (match-string 1 content)))
        (setq content (match-string 2 content))
        ;; Extract date and title
        (when (string-match "date *= *['\"]\\([0-9-]+\\)T" frontmatter)
          (setq date (match-string 1 frontmatter)))
        (when (string-match "title *= *['\"]\\([^'\"]+\\)['\"]" frontmatter)
          (setq title (match-string 1 frontmatter)))))
    ;; Print to minibuffer
    (message "Date: %s, Title: %s" (or date "Not found") (or title "Not found"))
    ;; Define output file path
    (setq output-file (concat (file-name-as-directory output-dir)
                              (file-name-nondirectory
                               (concat (file-name-sans-extension (buffer-file-name)) ".txt"))))
    (setq gophermap-file (concat (file-name-as-directory gopher-dir) "gophermap"))
    (setq entry (format "0%s\t%s\n" title (file-name-nondirectory output-file)))
    ;; Check if the entry already exists before writing the file
    (when (or (not (file-exists-p gophermap-file))
              (not (with-temp-buffer
                     (insert-file-contents gophermap-file)
                     (string-match-p (regexp-quote entry) (buffer-string)))))
      ;; Write file
      (with-temp-file output-file
        (when date (insert date "\n\n"))
        (when title (insert title "\n\n"))
        (insert content "\n"))
      (message "Exported to %s" output-file)
      ;; Append to gophermap
      (with-temp-buffer
        (insert entry)
        (append-to-file (point-min) (point-max) gophermap-file))
      (message "Appended to gophermap at %s" gophermap-file))))


;; Bind the function to a command for easy access
(global-set-key (kbd "C-c g") 'md-to-gopher)
