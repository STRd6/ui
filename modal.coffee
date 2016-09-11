modal = document.createElement "div"
modal.id = "modal"

modal.onclick = (e) ->
  if e.target is modal
    Modal.hide()

document.addEventListener "keydown", (e) ->
  unless e.defaultPrevented
    if e.key is "Escape"
      Modal.hide()

document.body.appendChild modal

module.exports = Modal =
  show: (element) ->
    empty(modal).appendChild(element)
    modal.classList.add "active"

  hide: ->
    modal.classList.remove "active"

empty = (node) ->
  while node.hasChildNodes()
    node.removeChild(node.lastChild)

  return node
