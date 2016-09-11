style = document.createElement "style"
style.innerHTML = require "../style"
document.head.appendChild style

Observable = require "observable"

Action = (fn, hotkey) ->
  disabled = Observable false
  setInterval ->
    disabled.toggle()
  , 1000

  disabled: disabled
  hotkey: ->
    hotkey
  call: (args...) ->
    fn.call(args...)

sampleMenuParsed = require "../samples/notepad-menu"
MenuView = require "../views/file-menu"
{element} = MenuView sampleMenuParsed,
  new:(Action ->
    console.log 'New!'
  , "Ctrl+N")
  pageSetup: (Action ->
    console.log "settin up a page"
  , "Ctrl+Shift+P")
document.body.appendChild element
