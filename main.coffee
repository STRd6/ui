Action = require "./action"
Modal = require "./modal"
FileMenuView = require "./views/file-menu"
MenuItemView = require "./views/menu-item"
MenuView = require "./views/menu"
Observable = require "observable"
ContextMenuView = require "./views/context-menu"

global.assert = require "./lib/assert"

if PACKAGE.name is "ROOT"
  style = document.createElement "style"
  style.innerHTML = [
    require "./style/main"
    require "./style/modal"
  ].join("\n")
  document.head.appendChild style

  sampleMenuParsed = require "../samples/notepad-menu"
  {element} = FileMenuView sampleMenuParsed,
    new: (Action ->
      console.log 'New!'
    , "Ctrl+N")
    pageSetup: (Action ->
      console.log "settin up a page"
    , "Ctrl+Shift+P")
    print: ->
      p = document.createElement('p')
      p.innerText = "hello"
      Modal.show p

  document.body.appendChild element

  contextMenu = ContextMenuView
    items: sampleMenuParsed[0][1]

  document.addEventListener "contextmenu", (e) ->
    e.preventDefault()

    contextMenu.display
      inElement: document.body
      x: e.pageX
      y: e.pageY

module.exports = {
  Modal
  MenuItemView
  Style:
    modal: require "./style/modal"
}
