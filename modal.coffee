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

{formDataToObject, handle} = require "./util"

PromptTemplate = require "./templates/modal/prompt"
ModalTemplate = require "./templates/modal"

modal = ModalTemplate()

cancellable = true
modal.onclick = (e) ->
  if e.target is modal and cancellable
    Modal.hide()

document.addEventListener "keydown", (e) ->
  unless e.defaultPrevented
    if e.key is "Escape" and cancellable
      e.preventDefault()
      Modal.hide()

document.body.appendChild modal

closeHandler = null

prompt = (params) ->
  new Promise (resolve) ->
    element = PromptTemplate params

    Modal.show element,
      cancellable: false
      closeHandler: resolve
    element.querySelector(params.focus)?.focus()

module.exports = Modal =
  show: (element, options) ->
    if typeof options is "function"
      closeHandler = options
    else
      closeHandler = options?.closeHandler
      if options?.cancellable?
        cancellable = options.cancellable

    empty(modal).appendChild(element)
    modal.classList.add "active"

  hide: (dataForHandler) ->
    closeHandler?(dataForHandler)
    modal.classList.remove "active"
    cancellable = true
    empty(modal)

  alert: (message) ->
    prompt
      title: "Alert"
      message: message
      focus: "button"
      confirm: handle ->
        Modal.hide()

  prompt: (message, defaultValue="") ->
    prompt
      title: "Prompt"
      message: message
      focus: "input"
      defaultValue: defaultValue
      cancel: handle ->
        Modal.hide(null)
      confirm: handle ->
        Modal.hide modal.querySelector("input").value

  confirm: (message) ->
    prompt
      title: "Confirm"
      message: message
      focus: "button"
      cancel: handle ->
        Modal.hide(false)
      confirm: handle ->
        Modal.hide(true)

  form: (formElement) ->
    new Promise (resolve) ->
      submitHandler = handle (e) ->
        formData = new FormData(formElement)
        result = formDataToObject(formData)
        Modal.hide(result)

      formElement.addEventListener "submit", submitHandler

      Modal.show formElement, (result) ->
        formElement.removeEventListener "submit", submitHandler
        resolve(result)

empty = (node) ->
  while node.hasChildNodes()
    node.removeChild(node.lastChild)

  return node
