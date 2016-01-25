SlideView = require("views/slide")

class ChatView extends SlideView
  template: require("./template")

  events: ->
    "iostap .selectable": "selectAnswer"
    "iostap .btn-done": "showAnswer"

  serialize: ->
    d = super
    d.allAnswers = _.shuffle(d.answers.incorrect.concat(d.answers.correct))
    d.allAnswers = d.allAnswers.map (a, i) ->
      text:      typogr.typogrify(a or "")
      isCorrect: a is d.answers.correct
      delay:     6 + i * 2
    d

  render: ->
    super

    @setEl @el.querySelectorAll(".selectable"), "answers"
    @setEl [], "selected"

  onRefresh: ->
    super

    @resetChat(true)

  resetChat: (isRefresh) ->
    @setState("prompt")
    @setState(false, "show-msg")

    for el in @getEl "answers"
      el.classList.remove("active", "no-delay")

    window.clearTimeout @timeout
    @timeout = window.setTimeout (=>
      @setState(true, "show-msg")
    ), if isRefresh then 0 else 2100

  show: ->
    @resetChat()

  hide: ->
    @setState(false, "show-msg")

  selectAnswer: (e) ->
    return if @currentState.state is "complete"

    el.classList.remove("active") for el in @getEl "answers"

    e.currentTarget.classList.add("active", "no-delay")

    @setEl(e.currentTarget, "selected")
    @setState("touched")

  isCorrect: ->
    @getEl("selected").classList?.contains("correct")


module.exports = ChatView
