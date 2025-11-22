(in-package #:zork)

;;; Translated ZIL Objects

;;; From 1DUNGEON.ZIL

(object rooms
  (desc "Rooms"))

(object local-globals
  (desc "Local Globals"))

(object global-objects
  (desc "Global Objects"))

(room west-of-house
  (in rooms)
  (desc "West of House")
  (north to north-of-house)
  (south to south-of-house)
  (ne to north-of-house)
  (se to south-of-house)
  (west to forest-1)
  (east "The door is boarded and you can't remove the boards.")
  (action west-house)
  (flags rlandbit onbit sacredbit))

(room north-of-house
  (in rooms)
  (desc "North of House")
  (sw to west-of-house)
  (se to east-of-house)
  (west to west-of-house)
  (east to east-of-house)
  (north to path)
  (south "The windows are all boarded.")
  (flags rlandbit onbit sacredbit))

(object mailbox
  (in west-of-house)
  (synonym mailbox box)
  (adjective small)
  (desc "small mailbox")
  (flags contbit trytakebit)
  (action mailbox-f))

(object advertisement
  (in mailbox)
  (synonym advertisement leaflet booklet mail)
  (adjective small)
  (desc "leaflet")
  (flags readbit takebit burnbit))

;;; Dummy routines for actions
(routine west-house ()
  (tell "You are standing in an open field west of a white house, with a boarded front door.~%"))

(routine mailbox-f ()
  (tell "The mailbox is closed.~%"))

;;; Set initial player location
(defun init-game ()
  (setf *player-location* west-of-house))

(object board
  (in local-globals)
  (synonym boards board)
  (desc "board")
  (flags ndescbit)
  (action board-f))

(object teeth
  (in global-objects)
  (synonym overboard teeth)
  (desc "set of teeth")
  (flags ndescbit)
  (action teeth-f))

(object wall
  (in global-objects)
  (synonym wall walls)
  (adjective surrounding)
  (desc "surrounding wall"))

(object granite-wall
  (in global-objects)
  (synonym wall)
  (adjective granite)
  (desc "granite wall")
  (action granite-wall-f))

(object songbird
  (in local-globals)
  (synonym bird songbird)
  (adjective song)
  (desc "songbird")
  (flags ndescbit)
  (action songbird-f))

;;; Dummy actions
(routine board-f () (tell "The board is boring.~%"))
(routine teeth-f () (tell "The teeth are sharp.~%"))
(routine granite-wall-f () (tell "The wall is hard.~%"))
(routine songbird-f () (tell "The bird sings.~%"))
