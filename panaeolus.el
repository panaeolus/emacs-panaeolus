(require 'a)
(require 'font-lock)
(require 'eldoc)
(require 'inf-clojure)
(require 'panaeolus-database)
(require 'shut-up)

(defvar panaeolus--font-lock-list '())

(defface panaeoulus--font-lock-p-on
  '((((class color)) (:background "#0AD600" :foreground "#e8ffe2" :bold t))
    (t (:inverse-video t)))
  "Face for highlighting during evaluation."
  :group 'csound-mode-font-lock)

(defvar panaeoulus--font-lock-p-on 'panaeoulus--font-lock-p-on)


(defface panaeoulus--font-lock-p-off
  '((((class color)) (:background "#d10000" :foreground "#ffedee" :bold t))
    (t (:inverse-video t)))
  "Face for highlighting during evaluation."
  :group 'csound-mode-font-lock)

(defvar panaeoulus--font-lock-p-off 'panaeoulus--font-lock-p-off)


(defface panaeoulus--font-lock-demo
  '((((class color)) (:foreground "#ff00ae" :bold t)))
  "Face for highlighting during evaluation."
  :group 'csound-mode-font-lock)

(defvar panaeoulus--font-lock-demo 'panaeoulus--font-lock-demo)

(defface panaeoulus--font-lock-kill
  '((((class color)) (:background "#fffa00" :foreground "#d10000" :bold t))
    (t (:inverse-video t)))
  "Face for highlighting during evaluation."
  :group 'csound-mode-font-lock)

(defvar panaeoulus--font-lock-kill 'panaeoulus--font-lock-kill)


(push '("\\_<demo\\_>\\|\\_<forever\\_>" . 'panaeoulus--font-lock-demo) panaeolus--font-lock-list)

(push `(,(concat "\\<nseq\\_>\\|\\<grid\\_>"
		 "\\|\\<len\\_>\\|\\<uncycle\\_>"
		 "\\|\\<midi\\_>\\|\\<octave\\_>"
		 "\\|\\<louder\\_>\\|\\<quieter\\_>\\|\\<scramble\\_>"
		 "\\|\\<xtim\\_>\\|\\<xtratim\\_>\\|\\<scale\\_>")
	. 'font-lock-function-name-face) panaeolus--font-lock-list)

(push '("\\<kill\\_>\\|\\<solo\\_>" . 'panaeoulus--font-lock-kill) panaeolus--font-lock-list)

(push `(,(concat "\\<organ\\_>\\|\\<sweet\\_>\\|\\<sampler\\_>"
		 "\\|\\<sweet\\_>\\|\\<asfm\\_>\\|\\<low_conga\\_>"
		 "\\|\\<mid_conga\\_>\\|\\<scan\\_>\\|\\<pluck\\_>"
		 "\\|\\<nuclear\\_>\\|\\<tb303\\_>\\|\\<priest\\_>"
		 "\\|\\<hammer\\_>" "\\|\\<nsampler\\_>") .
		 'font-lock-doc-face) panaeolus--font-lock-list)

(push '("\\<lofi\\_>\\|\\<freeverb\\_>\\|\\<flanger\\_>\\|\\<delayl\\_>\\|\\<butbp\\_>\\|\\<butlp\\_>\\|\\<buthp\\_>" .
	'font-lock-highlighting-faces) panaeolus--font-lock-list)


(font-lock-add-keywords 'clojurescript-mode panaeolus--font-lock-list)

;; (defun panaeolus--font-lock-setup ()
;;   (font-lock-add-keywords 'clojurescript-mode panaeolus--font-lock-list))

(defun panaeolus--beginning-of-sexp ()
  "Move to the beginning of current sexp.
Return the number of nested sexp the point was over or after."
  (let ((parse-sexp-ignore-comments t)
        (num-skipped-sexps 0))
    (condition-case _
        (progn
          ;; First account for the case the point is directly over a
          ;; beginning of a nested sexp.
          (condition-case _
              (let ((p (point)))
                (forward-sexp -1)
                (forward-sexp 1)
                (when (< (point) p)
                  (setq num-skipped-sexps 1)))
            (error))
          (while
              (let ((p (point)))
                (forward-sexp -1)
                (when (< (point) p)
                  (setq num-skipped-sexps (1+ num-skipped-sexps))))))
      (error))
    num-skipped-sexps))


(defun panaeolus-eldoc-function ()
  (interactive)
  (let* ((fn-name (save-excursion
		    (prog2 (panaeolus--beginning-of-sexp)
			(thing-at-point 'symbol))))
	 (lookup (gethash fn-name panaeolus-fn-database))) 
    (if lookup
	(append `(,fn-name) (car lookup))
      "")))

(defun panaeolus-arglist-command (str) 
  (setq result (car (gethash str panaeolus-fn-database)))
  (if result result ""))

(defun panaeolus--eldoc-setup ()
  (setq eldoc-documentation-function #'panaeolus-eldoc-function))


(defun panaeolus-kill (&optional and-go)
  (interactive "P")
  (let ((end (prog2 (end-of-defun) (point)))
	(beg (prog2 (beginning-of-defun) (point)))
	(case-fold-search t))
    (search-forward "seq" end t)
    (end-of-line)  
    (newline-and-indent)
    (insert "kill")
    (end-of-defun)
    (inf-clojure-eval-region beg (point) and-go)))

(defun panaeolus-util-chomp (str)
  "Chomp leading and tailing whitespace from STR."
  (while (string-match "\\`\n+\\|^\\s-+\\|\\s-+$\\|\n+\\'"
		       str)
    (setq str (replace-match "" t t str)))
  str)


;; (comint-send-string (inf-clojure-proc) "\"hii\" ")

;; (inf-clojure--send-string (inf-clojure-proc) "(panaeolus.engine/get-pattern-reg-state)")

;; panaeolus--runtime-state

(defvar panaeolus-minor-mode-map nil)

(setq panaeolus--runtime-state nil)

(setq panaeolus--loaded-p nil)

(add-hook 'inf-clojure-mode-hook (lambda () (setq panaeolus--loaded-p nil)))

;; (setq panaeolus--runtime-state '())

(defun panaeolus-colorize-pat ()
  (when (listp panaeolus--runtime-state)
    (save-excursion
      (beginning-of-buffer)
      (while (search-forward-regexp "\\_<pat\\_>" nil t)
	(replace-match "")
	(let ((old-point (point))
	      (pat "pat")
	      (pat-name (save-excursion (forward-word) (symbol-at-point))))
	  (if (member (symbol-name pat-name) panaeolus--runtime-state)
	      (put-text-property 0 3 'font-lock-face 'panaeoulus--font-lock-p-on pat)
	    (put-text-property 0 3 'font-lock-face 'panaeoulus--font-lock-p-off pat))
	  (goto-char old-point)
	  (insert pat))))))

(defun panaeolus-update-runtime-state ()
  (interactive)
  (when panaeolus--loaded-p
    (run-with-idle-timer 0.2 nil
			 (lambda ()
			   (inf-clojure--send-string (inf-clojure-proc) "(panaeolus.engine/get-pattern-reg-state)")))
    (run-with-idle-timer 2 nil (lambda ()
				 (panaeolus-colorize-pat)))))

(defun panaeolus-eval-last-sexp ()
  (interactive)
  (inf-clojure-eval-last-sexp)
  (panaeolus-update-runtime-state))

(defun panaeolus-eval-defun ()
  (interactive)
  (funcall 'inf-clojure-eval-defun)
  (panaeolus-update-runtime-state))

(setq panaeolus-minor-mode-map
      (let ((map (make-sparse-keymap)))
	(define-key map (kbd "C-c C-g") #'(message "Hello!"))
	(define-key map (kbd "C-M-x")  'panaeolus-eval-defun)
	(define-key map (kbd "C-x C-e")  'panaeolus-eval-last-sexp)
	map))

(defun panaeolus-trim-output (str)
  (replace-regexp-in-string "^.*=>" "" str))

(defun panaeolus-trim-parens (str)
  (concat "("
	  (->> (replace-regexp-in-string "(" "" str)
	       (replace-regexp-in-string ")" "")
	       (replace-regexp-in-string "\n" "")
	       (replace-regexp-in-string ":panaeolus-runtime" "list"))
	  ")"))

(defun panaeolus-trim-clojure (str)
  (replace-regexp-in-string "#_=>" "" str))


(defun inf-clojure-preoutput-filter (str)
  "Preprocess the output STR from interactive commands."
  (cond
   ((string-prefix-p "inf-clojure-" (symbol-name (or this-command last-command)))
    ;; Remove subprompts and prepend a newline to the output string
    (inf-clojure-chomp (concat "\n" (inf-clojure-remove-subprompts str))))
   ((string-match-p ":panaeolus-runtime" str) (prog2 (setq panaeolus--runtime-state
							   (eval (read (panaeolus-trim-parens
									(panaeolus-trim-output str)))))
						  ""))
   ((string-match-p "Panaeolus loaded" str) (progn (setq panaeolus--loaded-p t)
						   (panaeolus-update-runtime-state)
						   str))
   (t (panaeolus-trim-clojure str))))



;;;###autoload
(define-minor-mode panaeolus-minor-mode
  "Minor mode for live-coding with panaeolus."
  :keymap 'panaeolus-minor-mode-map
  (panaeolus--eldoc-setup)
  ;; (setq yas-snippet-dirs '("/Users/Skarhildur/.emacs.d/packages/emacs-panaeolus/snippets/"))  
  ;; (setq inf-clojure-arglist-command 'panaeolus-arglist-command)
  )


(provide 'panaeolus-minor-mode)
