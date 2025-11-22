(in-package #:zork)

;;; Runtime support for ZIL

(defvar *objects* (make-hash-table :test 'eq)
  "Registry of all ZIL objects.")

(defclass zil-object ()
  ((name :initarg :name :accessor zil-object-name)
   (desc :initarg :desc :accessor zil-object-desc :initform "")
   (flags :initarg :flags :accessor zil-object-flags :initform nil)
   (synonyms :initarg :synonyms :accessor zil-object-synonyms :initform nil)
   (adjectives :initarg :adjectives :accessor zil-object-adjectives :initform nil)
   (location :initarg :location :accessor zil-object-location :initform nil)
   (contents :initarg :contents :accessor zil-object-contents :initform nil)
   (action :initarg :action :accessor zil-object-action :initform nil)
   (properties :initarg :properties :accessor zil-object-properties :initform (make-hash-table :test 'eq))))

(defmethod print-object ((obj zil-object) stream)
  (print-unreadable-object (obj stream :type t :identity t)
    (format stream "~A" (zil-object-name obj))))

(defun get-obj (name)
  (gethash name *objects*))

(defun add-obj (name obj)
  (setf (gethash name *objects*) obj))

;;; Flag handling

(defun fset (obj flag)
  (pushnew flag (zil-object-flags obj)))

(defun fclear (obj flag)
  (setf (zil-object-flags obj) (delete flag (zil-object-flags obj))))

(defun fset? (obj flag)
  (member flag (zil-object-flags obj)))

;;; Object movement

(defun move (obj dest)
  "Move OBJ to DEST."
  (let ((old-loc (zil-object-location obj)))
    (when old-loc
      (setf (zil-object-contents old-loc)
            (delete obj (zil-object-contents old-loc)))))
  (setf (zil-object-location obj) dest)
  (when dest
    (push obj (zil-object-contents dest))))

(defun remove-obj (obj)
  "Remove OBJ from its location."
  (move obj nil))

;;; Global variables (ZIL globals)
;;; In ZIL, <GLOBAL FOO 123> creates a global variable.
;;; We will map this to CL defparameter in macros, but we might need runtime access if names are dynamic.

;;; Parser Stub

(defvar *player-location* nil "Current location of the player.")

(defun parser (input)
  "Simple parser stub."
  (let* ((words (uiop:split-string (string-upcase input)))
         (verb (first words))
         (noun (second words)))
    (cond
      ((string= verb "LOOK")
       (look))
      ((string= verb "GO")
       (if noun
           (go-direction noun)
           (format t "Go where?~%")))
      ((string= verb "QUIT")
       (return-from parser :quit))
      (t (format t "I don't know the word ~A.~%" verb)))))

(defun go-direction (dir-str)
  "Attempt to move in the given direction."
  (let* ((dir-sym (intern dir-str :zork))
         (props (zil-object-properties *player-location*))
         (exit (gethash dir-sym props)))
    (if exit
        (cond
          ;; (NORTH TO ROOM) -> (TO ROOM)
          ((and (listp exit) (eq (first exit) 'to))
           (let ((dest (second exit)))
             (if (symbolp dest)
                 (setf dest (get-obj dest)))
             (if dest
                 (progn
                   (move *player-location* nil) ; Remove from old
                   (setf *player-location* dest)
                   (look))
                 (format t "You can't go that way (invalid destination).~%"))))
          ;; (NORTH "You can't go that way")
          ((stringp exit)
           (format t "~A~%" exit))
          (t (format t "You can't go that way.~%")))
        (format t "You can't go that way.~%"))))

(defun look ()
  "Implementation of LOOK verb."
  (if *player-location*
      (progn
        (format t "~&~A~%" (zil-object-desc *player-location*))
        ;; List contents
        (let ((contents (zil-object-contents *player-location*)))
          (when contents
            (format t "You see:~%")
            (dolist (obj contents)
              (format t "  ~A~%" (zil-object-desc obj))))))
      (format t "You are in the void.~%")))

(defun run-game ()
  "Main game loop."
  (format t "Welcome to Zork CL!~%")
  (loop
    (format t "> ")
    (force-output)
    (let ((input (read-line)))
      (when (eq (parser input) :quit)
        (return)))))
