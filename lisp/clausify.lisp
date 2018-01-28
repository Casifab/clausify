					; skolemizzazione
(defun variablep (v)
  (and (symbolp v) (char= #\? (char (symbol-name v) 0))))

(defun skolem-variable ()
  (gentemp "SV-"))

(defun skolem-function* (&rest args)
  (cons (gentemp "SF-") args))

(defun skolem-function (args)
  (apply #’skolem-function* args))
