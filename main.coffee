Action = require "./action"
Modal = require "./modal"
FileMenuView = require "./views/file-menu"
MenuItemView = require "./views/menu-item"
Observable = require "observable"
#ContextMenu = require "./context-menu"

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

  rootNode = {}
  rootNode.parent = rootNode

  {element:contextMenu} = MenuItemView sampleMenuParsed[0], {}, rootNode, rootNode, Observable()
  contextMenu.classList.add "context"

  document.addEventListener "contextmenu", (e) ->
    e.preventDefault()
    console.log e
    document.body.appendChild contextMenu

module.exports = {
  Modal
  MenuItemView
  Style:
    modal: require "./style/modal"
}
