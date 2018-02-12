;; =============================================================================
;;FUNZIONI FORNITE ALL'INTERNO DELLE SPECIFICHE

(defun variablep (v)
  (and
   (symbolp v)(char= #\? (char (symbol-name v) 0))))

(defun skolem-variable ()
  (gentemp "SV-"))

(defun skolem-function* (&rest args)
  (cons (gentemp "SF-") args))

(defun skolem-function (args)
  (apply #'skolem-function* args))

;;==============================================================================
					;FUNZIONI PRINCIPALI

(defun as-cnf (fbf)
  (if (wff fbf)
      (trad-alg fbf)
    "Not a wff"
    )
  )

(defun is-horn (fbf)
  (if (wff fbf)
      (control-horn
       (trad-alg fbf)
       )
    "Not a wff"
    )
  )

;;==============================================================================
				       ;ALGORITMO DI TRADUZIONE

;; algoritmo di traduzione

(defun trad-alg (expr)
  (or-n-ary
   (rm-or
    (un-semplification
     (skolemization
      (rd-negation
       (rm-implication expr)
       )
      )
     )
    )
   )
  )

;; rimozione regole di implicazione
;; passaggio 1 dell'algoritmo

(defun rm-implication (expr)
  (cond
   ((impl expr) (list 'or (list 'not
				(rm-implication (second expr)))
		      (rm-implication (third expr))
		      )
    )
  ((or (exist expr) (univ expr))
    (list
     (first expr)
     (second expr)
     (rm-implication (third expr))
     )
    )
  ((or (conj expr) (disj expr))
   (list
    (first expr)
    (rm-implication (second expr))
    (rm-implication (third expr))
    )
   )
  ((neg expr)
   (list
    (first expr)
    (rm-implication (second expr))
    )
   )
  (T expr)
  )
  )

;; riduzione delle negazioni
;; passaggio 2 dell'algoritmo

(defun rd-negation (expr)
  (cond
   ((neg expr)
    (cond
     ((neg (second expr))
      (rd-negation (second (second expr)))
      )
     ((conj (second expr))
      (rd-negation 
       (list 'or
	     (list 'not (rd-negation (second (second expr))))
	     (list 'not (rd-negation (third (second expr))))
	     )
       )
      )
     ((disj (second expr))
      (rd-negation
       (list 'and
	     (list 'not (rd-negation (second (second expr))))
	     (list 'not (rd-negation (third (second expr))))
	     )
       )
      )
     ((univ (second expr))
      (list 'exist
	    (second (second expr))
	    (rd-negation (list 'not
			       (third (second expr)))
			 )
	    )
      )
     ((exist (second expr))
      (list 'every
	    (second (second expr))
	    (rd-negation (list 'not
			       (third (second expr)))
			 )
	    )
      )
     (T expr)
     )
    )
   ((or
     (conj expr)
     (disj expr)
     )
    (list
     (first expr)
     (rd-negation (second expr))
     (rd-negation (third expr))
     )
    )
   ((or
     (univ expr)
     (exist expr)
     )
    (list
     (first expr)
     (second expr)
     (rd-negation (third expr))
     )
    )
   (T expr)
   )
  )
   
;; skolemizzazione
;; passaggio 3 dell'algoritmo

(defun skolemization (expr &optional (mem nil))
  (cond ((null expr) nil
	 )
	((const expr) expr
	 )
	((listp (first expr))
	 (cons
	  (skolemization (first expr) mem)
	  (skolemization (rest expr) mem)
	  )
	 )
	((eq 'every (first expr))
	 (list 'every
	       (second expr)
	       (skolemization (third expr)
			      (cons (second expr) mem)
			      )
	       )
	 )
	((eq 'exist (first expr))
	 (subst (if mem
		    (skolem-function mem)
		  (skolem-variable))
		(second expr)
		(skolemization (third expr) mem)
		)
	 )
	(T (cons (first expr) (skolemization (rest expr) mem)
		 )
	   )
	)
  )

;; semplificazione degli universali
;; passaggio 4 dell'algoritmo

(defun un-semplification (expr)
  (cond
   ((univ expr)
    (third expr)
    )
   ((or
     (conj expr)
     (disj expr)
     )
    (list
     (first expr)
     (un-semplification (second expr))
     (un-semplification (third expr))
     )
    )
   ((neg expr)
    (list
     (first expr)
     (un-semplification (second expr))
     )
    )
   (T expr)
   )
  )

;; distribuzione dell'or
;; passaggio 5 dell'algoritmo

(defun rm-or (expr)
  (cond
   ((and
     (disj expr)
     (conj (third expr))
     )
    (list 'and
	  (list 'or
		(second expr)
		(second (third expr))
		)
	  (list 'or
		(second expr)
		(third (third expr))
		)
	  )
    )
   ((and
     (disj expr)
     (conj (second expr))
     )
    (list 'and
	  (list 'or
		(second (second expr))
		(third expr)
		)
	  (list 'or
		(third (second expr))
		(third expr)
		)
	  )
    )
   ((neg expr)
    (list
     (first expr)
     (rm-or (second expr))
     )
    )
   (T expr)
   )
  )

(defun or-n-ary (expr)
  (cond
   ((disj expr)
    (list*
     (first expr)
     (mapcar
      (lambda (elem)
	(cond
	 ((disj elem)
	  (list
	   (or-n-ary (second elem))
	   (or-n-ary (third elem))
	   )
	  )
	 (T elem)
	 )
	)
      (rest expr)
      )
     )
    )
   (T expr)
   )
  )

;;==============================================================================
					;FORMULE PER LA VERIFICA DI HORN
(defun control-horn (expr)
  (cond
   ((< (count-positive expr) 2) T)
   (T NIL)
   )
  )

(defun count-positive (expr)
  (cond
   ((or
     (disj expr)
     (conj expr)
     )
    (apply '+
	   (mapcar #'count-positive (rest expr))
	   )
    )
   ((neg expr) 0)
   (T 1)
   )
  )

;;==============================================================================
					;REGOLE
(defun term (expr)
  (or
   (const expr)
   (variablep expr)
   (funct expr)
   )
  )

(defun const (expr)
  (or
   (numberp expr)
   (id expr)
   (null expr)
   )
  )

(defun funct (expr)
  (and
   (not (null expr))
   (listp expr)
   (id (first expr))
   (every 'term (rest expr))
   )
  )

(defun wff (expr)
  (or
   (pred expr)
   (neg expr)
   (conj expr)
   (disj expr)
   (impl expr)
   (univ expr)
   (exist expr)
   )
  )

(defun pred (expr)
  (or
   (id expr)
   (funct expr)
   )
  )

(defun neg (expr)
  (and
   (listp expr)
   (= 2 (length expr))
   (eq 'not (first expr))
   (wff (second expr))
   )
  )

(defun conj (expr)
  (and
   (not (null expr))
   (listp expr)
   (eq 'and (first expr))
   (every 'wff (rest expr))
   )
  )

(defun disj (expr)
  (and
   (not (null expr))
   (listp expr)
   (eq 'or (first expr))
   (every 'wff (rest expr))
   )
  )

(defun impl (expr)
  (and
   (listp expr)
   (= 3 (length expr))
   (eq 'implies (first expr))
   (wff (second expr))
   (wff (third expr))
   )
  )

(defun univ (expr)
  (and
   (listp expr)
   (= 3 (length expr))
   (eq 'every (first expr))
   (variablep (second expr))
   (wff (third expr))
   )
  )

(defun exist (expr)
  (and
   (listp expr)
   (= 3 (length expr))
   (eq 'exist (first expr))
   (variablep (second expr))
   (wff (third expr))
   )
  )

(defun id (expr)
  (and
   (not (variablep expr))
   (not (operator expr))
   (symbolp expr)
   )
  )

(defun operator (expr)
  (or
   (eq 'not expr)
   (eq 'and expr)
   (eq 'or expr)
   (eq 'implies expr)
   (eq 'exist expr)
   (eq 'every expr)
   )
  )
