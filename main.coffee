Action = require "./action"
modal = require "./modal"
MenuView = require "./views/file-menu"

if PACKAGE.name is "ROOT"
  style = document.createElement "style"
  style.innerHTML = [
    require "./style/main"
    require "./style/modal"
  ].join("\n")
  document.head.appendChild style

  sampleMenuParsed = require "../samples/notepad-menu"
  {element} = MenuView sampleMenuParsed,
    new: (Action ->
      console.log 'New!'
    , "Ctrl+N")
    pageSetup: (Action ->
      console.log "settin up a page"
    , "Ctrl+Shift+P")
    print: ->
      p = document.createElement('p')
      p.innerText = "hello"
      modal.show p

  document.body.appendChild element

module.exports = {
  modal
  MenuView
  Style:
    modal: require "./style.modal"
}
