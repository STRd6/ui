Action = require "./action"
Modal = require "./modal"
MenuBarView = require "./views/menu-bar"
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

  sampleMenuParsed = require "../samples/demo"
  {element} = MenuBarView
    items: sampleMenuParsed,
    handlers:
      alert: ->
        Modal.alert "yolo"
      prompt: ->
        Modal.prompt "Pretty cool, eh?", "Yeah!"
        .then console.log
      confirm: ->
        Modal.confirm "Jawsome!"
        .then console.log

  document.body.appendChild element

  contextMenu = ContextMenuView
    items: sampleMenuParsed[1][1]
    handlers: {}

  document.addEventListener "contextmenu", (e) ->
    if e.target is document.body
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
