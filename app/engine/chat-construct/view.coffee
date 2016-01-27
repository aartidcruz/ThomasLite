SlideView = require("views/slide")

class ChatConstructView extends SlideView
  template: require("./template")

  events: ->
    "iostap .btn-next": "next"
    "iostap .btn-exit": "exit"

  onRefresh: ->
    super

    @resetChat(true)

  show: ->
    @resetChat()

  hide: ->
    @setState(false, "show-msg")

  resetChat: (isRefresh) ->
    @setState("prompt")
    @setState(false, "show-msg")

    for el in @getEl "answers"
      el.classList.remove("active", "no-delay")

    window.clearTimeout @timeout
    @timeout = window.setTimeout (=>
      @setState(true, "show-msg")
    ), if isRefresh then 0 else 2100

module.exports = ChatConstructView
