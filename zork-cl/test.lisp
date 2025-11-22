(require 'asdf)
(load "zork.asd")
(asdf:load-system :zork)

(in-package :zork)

(format t "Initializing game...~%")
(init-game)

(format t "Checking player location...~%")
(assert (eq *player-location* west-of-house))
(format t "Player is at West of House.~%")

(format t "Checking objects...~%")
(assert (get-obj 'mailbox))
(assert (get-obj 'advertisement))
(format t "Objects exist.~%")

(format t "Testing LOOK...~%")
(look)

(format t "Testing object properties...~%")
(assert (fset? mailbox 'contbit))
(assert (string= (zil-object-desc mailbox) "small mailbox"))

(format t "Testing movement...~%")
(go-direction "NORTH")
(assert (eq *player-location* north-of-house))
(format t "Moved to North of House.~%")

(go-direction "SOUTH")
(assert (eq *player-location* north-of-house))
(format t "Blocked movement verified (stayed at North of House).~%")

(go-direction "SW")
(assert (eq *player-location* west-of-house))
(format t "Moved back to West of House.~%")

(format t "All tests passed!~%")
(uiop:quit 0)
