Action = require "./action"
Modal = require "./modal"
MenuBarView = require "./views/menu-bar"
MenuItemView = require "./views/menu-item"
MenuView = require "./views/menu"
ProgressView = require "./views/progress"
Observable = require "observable"
ContextMenuView = require "./views/context-menu"
WindowView = require "./views/window"

FormSampleTemplate = require "./samples/test-form"

if PACKAGE.name is "ROOT"
  style = document.createElement "style"
  style.innerHTML = """
    main
    loader
    menu
    modal
    window
  """.split("\n").map (stylePath) ->
    require "./style/#{stylePath}"
  .join("\n")
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
      form: ->
        Modal.form FormSampleTemplate()
        .then console.log
      progress: ->
        progressView = ProgressView
          value: 0

        Modal.show progressView.element,
          cancellable: false

        intervalId = setInterval ->
          newValue = progressView.value() + 1/60
          progressView.value(newValue)
          if newValue > 1
            clearInterval intervalId
            Modal.hide()
        , 15
      newWindow: ->
        windowView = WindowView
          yolo: {}
        document.body.appendChild windowView.element

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
  ContextMenu: ContextMenuView
  Modal
  MenuItemView
  Style:
    modal: require "./style/modal"
}
