;; funzioni fornite all'interno delle specifiche

(defun variablep (v)
  (and
   (symbolp v)(char= #\? (char (symbol-name v) 0))))

(defun skolem-variable ()
  (gentemp "SV-"))

(defun skolem-function* (&rest args)
  (cons (gentemp "SF-") args))

(defun skolem-function (args)
  (apply #'skolem-function* args))

;; funzioni principali

(defun as-cnf (fbf)
  ;;...
  )

(defun is-horn (fbf)
  ;;...
  )

;; rimozione regole di implicazione
;; passaggio 1 dell'algoritmo

(defun rm-implication (fbf)
  ;;...
  )

;; riduzione delle negazioni
;; passaggio 2 dell'algoritmo

(defun rd-negation (fbf)
  ;;...
  )

;; skolemizzazione
;; passaggio 3 dell'algoritmo

(defun skolemization (fbf)
  ;;...
  )

;; semplificazione degli universali
;;passaggio 4 dell'algoritmo

(defun un-semplification (fbf)
  ;;...
  )

;; distribuzione dell'or
;; passaggio 5 dell'algoritmo

(defun rm-or (fbf)
  ;;...
  )

;;======================================================
					;REGOLE
;;======================================================

(defun term (expr)
  (or
   (const expr)
   (variablep expr)
   (funct expr)
   )
  )

(defun const (expr)
  (or
   (number expr)
   (id expr)
   )
  )
