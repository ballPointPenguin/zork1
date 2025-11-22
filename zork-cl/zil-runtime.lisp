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

;;; Global variables (ZIL globals)
;;; In ZIL, <GLOBAL FOO 123> creates a global variable.
;;; We will map this to CL defparameter in macros, but we might need runtime access if names are dynamic.

;;; Parser Stub

(defvar *player* (make-instance 'zil-object :name 'player :desc "You")
  "The player object, holding inventory.")

(defvar *player-location* nil "Current location of the player.")

(defun parser (input)
  "Simple parser stub."
  (let* ((words (uiop:split-string (string-upcase input)))
         (verb (first words))
         (noun (second words))
         (prep (third words))
         (indirect (fourth words)))
    (cond
      ((string= verb "LOOK")
       (look))
      ((string= verb "GO")
       (if noun
           (go-direction noun)
           (format t "Go where?~%")))
      ((string= verb "TAKE")
       (if noun
           (take-obj noun)
           (format t "Take what?~%")))
      ((string= verb "DROP")
       (if noun
           (drop-obj noun)
           (format t "Drop what?~%")))
      ((string= verb "PUT")
       (if (and noun prep indirect (string= prep "IN"))
           (put-obj noun indirect)
           (format t "Put what in what?~%")))
      ((string= verb "INVENTORY")
       (show-inventory))
      ((string= verb "I")
       (show-inventory))
      ((string= verb "OPEN")
       (if noun
           (open-obj noun)
           (format t "Open what?~%")))
      ((string= verb "CLOSE")
       (if noun
           (close-obj noun)
           (format t "Close what?~%")))
      ((string= verb "QUIT")
       (return-from parser :quit))
      (t (format t "I don't know the word ~A.~%" verb)))))

(defun put-obj (obj-name container-name)
  (let ((obj (resolve-obj obj-name))
        (cont (resolve-obj container-name)))
    (cond
      ((null obj)
       (format t "You don't see ~A here.~%" obj-name))
      ((null cont)
       (format t "You don't see ~A here.~%" container-name))
      ((not (eq (zil-object-location obj) *player*))
       (format t "You aren't holding the ~A.~%" obj-name))
      ((not (or (fset? cont 'contbit) (fset? cont 'surfbit)))
       (format t "You can't put things in the ~A.~%" container-name))
      ((and (fset? cont 'contbit) (not (fset? cont 'openbit)))
       (format t "The ~A is closed.~%" container-name))
      (t
       (move obj cont)
       (format t "Done.~%")))))

(defun is-visible (obj)
  "Check if OBJ is visible to the player."
  (let ((loc (zil-object-location obj)))
    (cond
      ((null loc) nil)
      ((eq loc *player*) t)
      ((eq loc *player-location*) t)
      ((and *player-location*
            (member (zil-object-name obj) (gethash 'global (zil-object-properties *player-location*))))
       t)
      ((and (fset? loc 'openbit) (is-visible loc)) t)
      (t nil))))

(defun resolve-obj (name)
  "Find a visible object by name."
  (let ((obj-name (if (symbolp name) name (intern (string-upcase name) :zork))))
    (maphash (lambda (k v)
               (declare (ignore k))
               (when (and (is-visible v)
                          (or (eq (zil-object-name v) obj-name)
                              (member obj-name (zil-object-synonyms v))))
                 (return-from resolve-obj v)))
             *objects*)
    nil))

(defun open-obj (name)
  (let ((obj (resolve-obj name)))
    (cond
      ((null obj)
       (format t "You don't see that here.~%"))
      ((not (or (fset? obj 'contbit) (fset? obj 'doorbit)))
       (format t "You can't open that.~%"))
      ((fset? obj 'openbit)
       (format t "It is already open.~%"))
      (t
       (fset obj 'openbit)
       (format t "Opened.~%")))))

(defun close-obj (name)
  (let ((obj (resolve-obj name)))
    (cond
      ((null obj)
       (format t "You don't see that here.~%"))
      ((not (or (fset? obj 'contbit) (fset? obj 'doorbit)))
       (format t "You can't close that.~%"))
      ((not (fset? obj 'openbit))
       (format t "It is already closed.~%"))
      (t
       (fclear obj 'openbit)
       (format t "Closed.~%")))))

(defun take-obj (name)
  (let ((obj (resolve-obj name)))
    (cond
      ((null obj)
       (format t "You don't see that here.~%"))
      ((eq (zil-object-location obj) *player*)
       (format t "You already have that.~%"))
      ((fset? obj 'trytakebit)
       (move obj *player*)
       (format t "Taken.~%"))
      ((fset? obj 'takebit)
       (move obj *player*)
       (format t "Taken.~%"))
      (t
       (format t "You can't take that.~%")))))

(defun drop-obj (name)
  (let ((obj (resolve-obj name)))
    (cond
      ((null obj)
       (format t "You don't have that.~%"))
      ((not (eq (zil-object-location obj) *player*))
       (format t "You don't have that.~%"))
      (t
       (move obj *player-location*)
       (format t "Dropped.~%")))))

(defun show-inventory ()
  (let ((inv (zil-object-contents *player*)))
    (if inv
        (progn
          (format t "You are carrying:~%")
          (dolist (obj inv)
            (format t "  ~A~%" (zil-object-desc obj))))
        (format t "You are empty-handed.~%"))))

(defun look-contents (obj indent)
  (when (or (fset? obj 'openbit) (fset? obj 'transbit))
    (let ((contents (zil-object-contents obj)))
      (when contents
        (dolist (c contents)
          (format t "~V@T~A~%" indent (zil-object-desc c))
          (look-contents c (+ indent 2)))))))

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
              (format t "  ~A~%" (zil-object-desc obj))
              (look-contents obj 4)))))
      (format t "You are in the void.~%")))

(defun go-direction (dir-str)
  "Attempt to move in the given direction."
  (let* ((dir-sym (intern dir-str :zork))
         (props (zil-object-properties *player-location*))
         (exit (gethash dir-sym props)))
    (cond
      ((null exit)
       (format t "You can't go that way.~%"))
      ((stringp exit)
       (format t "~A~%" exit))
      ((listp exit)
       ;; Handle (TO dest ...)
       (if (eq (first exit) 'to)
           (let ((dest (second exit))
                 (rest (cddr exit)))
             ;; Check conditions
             (cond
               ((null rest)
                (move-player dest))
               ((and (eq (first rest) 'if)
                     (eq (third rest) 'is)
                     (eq (fourth rest) 'open))
                (let ((obj (resolve-obj (second rest)))) ; This might fail if obj not visible?
                  ;; Actually, for exit checks, we might need to look up globally or in room globals
                  ;; But resolve-obj checks visibility.
                  ;; KITCHEN-WINDOW is global, so it should be visible.
                  (if (and obj (fset? obj 'openbit))
                      (move-player dest)
                      (format t "The ~A is closed.~%" (second rest)))))
               (t
                (format t "You can't go that way (unhandled condition).~%"))))
           (format t "You can't go that way.~%")))
      (t (format t "You can't go that way.~%")))))

(defun move-player (dest-name)
  (let ((dest (if (symbolp dest-name) (get-obj dest-name) dest-name)))
    (if dest
        (progn
          (move *player-location* nil) ; Remove from old (conceptually, though rooms don't contain rooms)
          (setf *player-location* dest)
          (look))
        (format t "You can't go that way (invalid destination).~%"))))

(defun run-game ()
  "Main game loop."
  (format t "Welcome to Zork CL!~%")
  (loop
    (format t "> ")
    (force-output)
    (let ((input (read-line)))
      (when (eq (parser input) :quit)
        (return)))))
