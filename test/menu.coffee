MenuView = require "../views/menu"
Observable = require "observable"

describe "Menu", ->
  # TODO: Make context root optional

  it "should work with plain ol' items", ->
    menu = MenuView
      items: [
        "Cool"
        "Rad"
      ]
      contextRoot:
        activeItem: Observable null
        handlers: {}

    assert.equal menu.items().length, 2

  it "should allow observable items", ->
    items = Observable [
      "Cool"
      ["Rad", ["2rad", "2Furious"]]
    ]

    menu = MenuView
      items: items
      contextRoot:
        activeItem: Observable null
        handlers: {}

    assert.equal menu.items().length, 2

    items [
      "New Stuff"
    ]

    assert.equal menu.items().length, 1
