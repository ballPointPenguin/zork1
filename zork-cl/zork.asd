(asdf:defsystem #:zork
  :description "A Common Lisp port of Zork 1 (ZIL)"
  :author "Antigravity"
  :license "MIT"
  :serial t
  :components ((:file "package")
               (:file "zil-macros")
               (:file "zil-runtime")
               (:file "zork-objects")))
