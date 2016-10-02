###
Action
======

Actions have a function to call, a hotkey, and a function that determines
whether or not they are disabled. This is so we can present them in the UI for
menus.

The hotkey is for display purposes only and needs to be listened to by a
separate mechanism to perform. [TODO] The action can be executed like a regular
function (instead of needing to use call).

Actions may have icons and help text as well.

###

Observable = require "observable"

# TODO: This is just a test for toggling disabled state
module.exports = (fn, hotkey) ->
  disabled = Observable false
  setInterval ->
    disabled.toggle()
  , 1000

  disabled: disabled
  hotkey: ->
    hotkey
  call: (args...) ->
    fn.call(args...)
