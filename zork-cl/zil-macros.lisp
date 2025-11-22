(in-package #:zork)

;;; ZIL Macros

(defmacro routine (name args &body body)
  "Defines a ZIL routine. Maps to CL defun."
  `(defun ,name ,args
     ,@body))

(defmacro global (name value)
  "Defines a ZIL global. Maps to CL defparameter."
  `(defparameter ,name ,value))

(defmacro constant (name value)
  "Defines a ZIL constant. Maps to CL defconstant."
  `(defconstant ,name ,value))

(defmacro object (name &rest clauses)
  "Defines a ZIL object."
  (let ((desc "")
        (flags nil)
        (location nil)
        (synonyms nil)
        (adjectives nil)
        (action nil)
        (props nil))
    (dolist (clause clauses)
      (case (first clause)
        (in (setf location (second clause)))
        (desc (setf desc (second clause)))
        (flags (setf flags (rest clause)))
        (synonym (setf synonyms (rest clause)))
        (adjective (setf adjectives (rest clause)))
        (action (setf action (second clause)))
        (t (push clause props)))) ; Store other properties
    
    `(progn
       (defparameter ,name
         (make-instance 'zil-object
                        :name ',name
                        :desc ,desc
                        :flags ',flags
                        :synonyms ',synonyms
                        :adjectives ',adjectives
                        :action ',action))
       (add-obj ',name ,name)
       ;; Handle location if specified
       ,(when location
          `(move ,name ,location))
       ;; Store extra properties
       ,@(loop for (key . val) in props
               collect `(setf (gethash ',key (zil-object-properties ,name)) ',val))
       ,name)))

(defmacro tell (str &rest args)
  "ZIL TELL macro. Maps to format."
  `(format t ,str ,@args))

(defmacro bset (obj flag)
  "ZIL BSET macro. Sets a flag on an object."
  `(fset ,obj ,flag))

(defmacro bclear (obj flag)
  "ZIL BCLEAR macro. Clears a flag from an object."
  `(fclear ,obj ,flag))

(defmacro bset? (obj flag)
  "ZIL BSET? macro. Checks if a flag is set."
  `(fset? ,obj ,flag))

;;; ZIL COND handles ELSE as T
(defmacro zil-cond (&rest clauses)
  "ZIL COND macro. Replaces ELSE with T in clauses."
  `(cond ,@(loop for clause in clauses
                 collect (if (eq (first clause) 'else)
                             `(t ,@(rest clause))
                             clause))))

;;; Shadow CL:COND with ZIL-COND if we were strictly parsing ZIL.
;;; For now, we will use ZIL-COND manually or assume translation.

;;; ROOM macro
(defmacro room (name &rest clauses)
  "ZIL ROOM macro. Maps to OBJECT."
  `(object ,name ,@clauses))
