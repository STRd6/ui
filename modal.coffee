modal = document.createElement "div"
modal.id = "modal"

modal.onclick = (e) ->
  if e.target is modal
    Modal.hide()

document.addEventListener "keydown", (e) ->
  unless e.defaultPrevented
    if e.key is "Escape"
      e.preventDefault()
      Modal.hide()

document.body.appendChild modal

closeHandler = null

module.exports = Modal =
  show: (element, _closeHandler) ->
    closeHandler = _closeHandler
    empty(modal).appendChild(element)
    modal.classList.add "active"

  hide: (dataForHandler) ->
    closeHandler?(dataForHandler)
    modal.classList.remove "active"
    empty(modal)

empty = (node) ->
  while node.hasChildNodes()
    node.removeChild(node.lastChild)

  return node
