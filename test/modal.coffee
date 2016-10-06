PACKAGE.name = "test"

{Modal} = require "../main"

describe "Modal", ->
  it "shoud be totally chill", ->
    element = document.createElement "p"

    called = false
    handler = (value) ->
      called = true
      assert.equal value, "yolo"

    Modal.show(element, handler)
    Modal.hide('yolo')

    assert called
