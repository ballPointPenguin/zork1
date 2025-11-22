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
  (flags rlandbit onbit sacredbit)
  (global boarded-window board white-house forest))

(room north-of-house
  (in rooms)
  (desc "North of House")
  (sw to west-of-house)
  (se to east-of-house)
  (west to west-of-house)
  (east to east-of-house)
  (north to path)
  (south "The windows are all boarded.")
  (flags rlandbit onbit sacredbit)
  (global boarded-window board white-house forest))

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
  (flags readbit takebit burnbit)
  (text "WELCOME TO ZORK!

    ZORK is a game of adventure, danger, and low cunning. In it you will explore some of the most amazing territory ever seen by mortals. No computer should be without one!"))

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

;;; New Objects

(object white-house
  (in global-objects)
  (synonym house)
  (desc "white house")
  (flags ndescbit))

(object forest
  (in global-objects)
  (synonym forest trees)
  (desc "forest")
  (flags ndescbit))

(object boarded-window
  (in local-globals)
  (synonym window)
  (adjective boarded)
  (desc "boarded window")
  (flags ndescbit))

(object kitchen-window
  (in local-globals)
  (synonym window)
  (adjective kitchen small)
  (desc "kitchen window")
  (flags doorbit ndescbit)
  (action kitchen-window-f))

(room east-of-house
  (in rooms)
  (desc "Behind House")
  (north to north-of-house)
  (south to south-of-house)
  (sw to south-of-house)
  (nw to north-of-house)
  (east to clearing)
  (west to kitchen if kitchen-window is open)
  (in to kitchen if kitchen-window is open)
  (action east-house)
  (flags rlandbit onbit sacredbit)
  (global white-house kitchen-window forest))

(room kitchen
  (in rooms)
  (desc "Kitchen")
  (east to east-of-house if kitchen-window is open)
  (west to living-room)
  (out to east-of-house if kitchen-window is open)
  (up to attic)
  (action kitchen-fcn)
  (flags rlandbit onbit sacredbit)
  (global kitchen-window chimney stairs))

(room living-room
  (in rooms)
  (desc "Living Room")
  (east to kitchen)
  (west "The door is nailed shut.")
  (action living-room-fcn)
  (flags rlandbit onbit sacredbit)
  (global stairs))

(object wooden-door
  (in living-room)
  (synonym door lettering writing)
  (adjective wooden gothic strange west)
  (desc "wooden door")
  (flags readbit doorbit ndescbit transbit)
  (action front-door-fcn)
  (text "The engravings translate to \"This space intentionally left blank.\""))

(object trophy-case
  (in living-room)
  (synonym case)
  (adjective trophy)
  (desc "trophy case")
  (flags transbit contbit ndescbit trytakebit searchbit)
  (action trophy-case-fcn))

(object kitchen-table
  (in kitchen)
  (synonym table)
  (adjective kitchen)
  (desc "kitchen table")
  (flags ndescbit contbit openbit surfacebit))

(object sandwich-bag
  (in kitchen-table)
  (synonym bag sack)
  (adjective brown elongated smelly)
  (desc "brown sack")
  (flags takebit contbit burnbit))

(object sword
  (in living-room)
  (synonym sword orcrist glamdring blade)
  (adjective elvish old antique)
  (desc "sword")
  (ldesc "There is an elvish sword here.")
  (flags takebit weaponbit trytakebit))

(object lamp
  (in living-room)
  (synonym lamp lantern light)
  (adjective brass)
  (desc "brass lantern")
  (flags takebit lightbit)
  (ldesc "There is a brass lantern (battery-powered) here.")
  (action lantern))

(object chimney
  (in local-globals)
  (synonym chimney)
  (desc "chimney")
  (flags ndescbit))

(object stairs
  (in local-globals)
  (synonym stairs stairway)
  (desc "stairs")
  (flags ndescbit))

;;; Dummy routines
(routine kitchen-window-f () (tell "The window is closed.~%"))
(routine east-house () (tell "You are behind the white house.~%"))
(routine kitchen-fcn () (tell "You are in the kitchen.~%"))
(routine living-room-fcn () (tell "You are in the living room.~%"))
(routine front-door-fcn () (tell "The door is nailed shut.~%"))
(routine trophy-case-fcn () (tell "It's a trophy case.~%"))
(routine lantern () (tell "It's a lamp.~%"))

