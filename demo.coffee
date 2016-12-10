{ContextMenu, MenuBar, Modal, Progress, Style, Window} = require "./export"

FormSampleTemplate = require "./samples/test-form"

style = document.createElement "style"
style.innerHTML = Style.all
document.head.appendChild style

sampleMenuParsed = require "../samples/demo"
{element} = MenuBar
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
      progressView = Progress
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
      windowView = Window
        yolo: {}
      document.body.appendChild windowView.element

document.body.appendChild element

contextMenu = ContextMenu
  items: sampleMenuParsed[1][1]
  handlers: {}

document.addEventListener "contextmenu", (e) ->
  if e.target is document.body
    e.preventDefault()

    contextMenu.display
      inElement: document.body
      x: e.pageX
      y: e.pageY
