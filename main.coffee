style = document.createElement "style"
style.innerHTML = require "../style"
document.head.appendChild style

Action = require "./action"

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
