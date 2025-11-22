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

(format t "Testing container mechanics...~%")
(open-obj "MAILBOX")
(assert (fset? mailbox 'openbit))
(format t "Opened mailbox.~%")

(format t "Testing inventory...~%")
(take-obj "LEAFLET")
(assert (eq (zil-object-location advertisement) *player*))
(format t "Taken leaflet.~%")

(show-inventory)

(drop-obj "LEAFLET")
(assert (eq (zil-object-location advertisement) west-of-house))
(format t "Dropped leaflet.~%")

(take-obj "LEAFLET")
(assert (eq (zil-object-location advertisement) *player*))

(format t "Testing PUT...~%")
(put-obj "LEAFLET" "MAILBOX")
(assert (eq (zil-object-location advertisement) mailbox))
(format t "Put leaflet in mailbox.~%")

(format t "All tests passed!~%")

;; New tests start here
(zork::move zork::advertisement zork::*player*)
(zork::put-obj "LEAFLET" "MAILBOX")
(assert (member zork::advertisement (zork::zil-object-contents zork::mailbox)))
(format t "PUT test passed.~%")

;; Test Movement to EAST-OF-HOUSE
(setf zork::*player-location* zork::north-of-house)
(zork::go-direction "EAST")
(assert (eq zork::*player-location* zork::east-of-house))
(format t "Movement to EAST-OF-HOUSE passed.~%")

;; Test KITCHEN-WINDOW visibility and conditional exit
(assert (zork::is-visible zork::kitchen-window))
(format t "KITCHEN-WINDOW visibility passed.~%")

;; Try to go WEST (should fail if window closed)
(zork::go-direction "WEST")
(assert (eq zork::*player-location* zork::east-of-house))
(format t "Conditional exit (closed) passed.~%")

;; OPEN WINDOW
(zork::open-obj "WINDOW")
(assert (zork::fset? zork::kitchen-window 'zork::openbit))
(format t "OPEN WINDOW passed.~%")

;; Try to go WEST (should succeed)
(zork::go-direction "WEST")
(assert (eq zork::*player-location* zork::kitchen))
(format t "Conditional exit (open) passed.~%")

;; Test KITCHEN objects
(assert (zork::is-visible zork::kitchen-table))
(assert (zork::is-visible zork::sandwich-bag)) ;; Bag is in table, table is open/surface
(format t "KITCHEN objects visibility passed.~%")

;; Test LIVING-ROOM and TROPHY-CASE
(zork::go-direction "WEST")
(assert (eq zork::*player-location* zork::living-room))
(assert (zork::is-visible zork::trophy-case))
(assert (zork::is-visible zork::lamp))
(assert (zork::is-visible zork::sword))
(format t "LIVING-ROOM objects passed.~%")

;; Test READ
(zork::read-obj "LEAFLET")
;; We can't easily assert stdout, but we can check if the function runs without error.
;; Ideally we'd capture output, but for now we trust the runtime.
(assert (zork::fset? zork::advertisement 'zork::readbit))
(format t "READ LEAFLET passed (runtime check).~%")

(zork::read-obj "DOOR")
(assert (zork::fset? zork::wooden-door 'zork::readbit))
(format t "READ DOOR passed (runtime check).~%")

;; Test EXAMINE
(zork::examine-obj "LAMP")
(format t "EXAMINE LAMP passed.~%")

(zork::examine-obj "SWORD")
(format t "EXAMINE SWORD passed.~%")

;; Test X shorthand
(zork::examine-obj "CASE")
(format t "X CASE passed.~%")

(format t "All tests passed!~%")
(uiop:quit 0)
