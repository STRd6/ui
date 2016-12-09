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
        initialMessage = "Reticulating splines"
        progressView = ProgressView
          value: 0
          max: 2
          message: initialMessage

        Modal.show progressView.element,
          cancellable: false

        intervalId = setInterval ->
          newValue = progressView.value() + 1/60
          ellipsesCount = Math.floor(newValue * 4) % 4
          ellipses = [0...ellipsesCount].map ->
            "."
          .join("")
          progressView.value(newValue)
          progressView.message(initialMessage + ellipses)
          if newValue > 2
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
  Window: WindowView
}
