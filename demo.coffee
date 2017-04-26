{ContextMenu, MenuBar, Modal, Observable, Util:{parseMenu}, Progress, Style, Table, Window} = require "./export"

{o} = require "./util"

notepadMenuText = require "./samples/notepad-menu"
notepadMenuParsed = parseMenu notepadMenuText

FormSampleTemplate = require "./samples/test-form"

style = document.createElement "style"
style.innerHTML = Style.all
document.head.appendChild style

sampleMenuParsed = parseMenu """
  [M]odal
    [A]lert
    [C]onfirm
    [P]rompt
    [F]orm
    P[r]ogress
  [T]est Nesting
    Test[1]
      Hello
      Wat
    Test[2]
      [N]ested
      -----
      [R]ad
        So Rad
        =====
        Hella
          Hecka
            Super Hecka
              Wicked
          ---
          -
          -
          ==
  [W]indow
    New [I]mage -> newImage
    New [P]ixel -> newPixel
    New [T]ext -> newText
    New [S]preadsheet -> newSheet
"""
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
    newImage: ->
      img = document.createElement "img"
      img.src = "https://s3.amazonaws.com/whimsyspace-databucket-1g3p6d9lcl6x1/danielx/data/pI1mvEvxcXJk4mNHNUW-kZsNJsrPDXcAtgguyYETRXQ"

      addWindow
        title: "Yoo"
        content: img
        iconEmoji: "💼"

    newPixel: ->
      frame = document.createElement "iframe"
      frame.src = "https://danielx.net/pixel-editor/embedded/"

      addWindow
        title: "Pixel"
        content: frame

    newText: ->
      textarea = document.createElement "textarea"

      addWindow
        title: "Notepad.exe"
        content: textarea

    newSheet: ->
      data = [0...5].map (i) ->
        id: i
        name: "yolo"
        color: "#FF0000"

      InputTemplate = require "./templates/input"
      RowElement = (datum) ->
        tr = document.createElement "tr"
        types = [
          "number"
          "text"
          "color"
        ]

        Object.keys(datum).forEach (key, i) ->
          td = document.createElement "td"
          td.appendChild InputTemplate
            value: o datum, key
            type: types[i]

          tr.appendChild td

        return tr

      {element} = tableView = Table {
        data
        RowElement
      }

      menuBar = MenuBar
        items: parseMenu """
          Insert
            Row -> insertRow
          Help
            About
        """
        handlers:
          about: ->
            Modal.alert "Spreadsheet v0.0.1 by Daniel X Moore"
          insertRow: ->
            data.push
              id: 50
              name: "new"
              color: "#FF00FF"

            tableView.render()

      addWindow
        title: "Spreadsheet [DEMO VERSION]"
        content: element
        menuBar: menuBar.element

document.body.appendChild element

desktop = document.createElement "desktop"
document.body.appendChild desktop

contextMenu = ContextMenu
  items: sampleMenuParsed[1][1]
  handlers: {}

desktop.addEventListener "contextmenu", (e) ->
  if e.target is desktop
    e.preventDefault()

    contextMenu.display
      inElement: document.body
      x: e.pageX
      y: e.pageY

addWindow = (params) ->
  windowView = Window params

  desktop.appendChild windowView.element

  return windowView
