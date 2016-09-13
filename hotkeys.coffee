###
Hotkeys
=======

Bind hotkeys

    Hotkey = require "hotkey"

    Hotkey "ctrl+r", ->
      alert "radical!"

We'd like to be able to generate a list of hotkeys with descriptions.

Questions
---------

Should we just use Mousetrap?

Probably :P

Should we allow binding to specific elements?

Imagine a windowing OS where non-iframe apps are inside draggable windows. We'd
like to have each 'app' able to have its own hotkeys and at the same time have
global OS level hotkeys.

Should preventDefault prevent executing the hotkey action?

Probably

Should executing a hotkey preventDefault?

Probably

###

# TODO: This is just a rough outline
module.exports = (element) ->
  handlers = {}

  handle = (event) ->
    {key} = event

    modifiersActive = ["alt", "ctrl", "meta", "shift"].filter (modifier) ->
      event["#{modifier}Key"]

    combo = modifiersActive.concat(key).join("+")

    # TODO: Don't trigger "plain" events in input/text fields

    handlers[combo]?(e)
