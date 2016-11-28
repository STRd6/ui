###
Modal

Display modal alerts or dialogs.

Modal has promise returning equivalents of the native browser:

- Alert
- Confirm
- Prompt

These accept the same arguments and return a promise fulfilled with
the same return value as the native methods.

You can display any element in the modal:

    modal.show myElement

###

{handle} = require "./util"

PromptTemplate = require "./templates/modal/prompt"
ModalTemplate = require "./templates/modal"

modal = ModalTemplate()

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

prompt = (params) ->
  new Promise (resolve) ->
    element = PromptTemplate params

    Modal.show element, resolve

module.exports = Modal =
  show: (element, _closeHandler) ->
    closeHandler = _closeHandler
    empty(modal).appendChild(element)
    modal.classList.add "active"

  hide: (dataForHandler) ->
    closeHandler?(dataForHandler)
    modal.classList.remove "active"
    empty(modal)

  alert: (message) ->
    prompt
      title: "Alert"
      message: message
      confirm: handle ->
        Modal.hide()

  prompt: (message, defaultValue="") ->
    prompt
      title: "Prompt"
      message: message
      defaultValue: defaultValue
      cancel: handle ->
        Modal.hide(null)
      confirm: handle ->
        Modal.hide modal.querySelector("input").value

  confirm: (message) ->
    prompt
      title: "Confirm"
      message: message
      cancel: handle ->
        Modal.hide(false)
      confirm: handle ->
        Modal.hide(true)

empty = (node) ->
  while node.hasChildNodes()
    node.removeChild(node.lastChild)

  return node
