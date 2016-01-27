SlideView = require("views/slide")
Draggy = require("views/components/draggy")

class Categorise2View extends SlideView
  template: require("./template")

  serialize: ->
    data = super
    maxTextLength = if data.width > 900 then 30 else 1
    data.buttonClass = if data.buttonText.length > maxTextLength then "btn-long" else ""
    data.categories = _.shuffle data.categories
    data

  events: ->
    "iostap .btn-done": "showAnswer"

  afterShow: ->
    @setEl @el.querySelector(".draggy"), "draggy"
    @setEl @el.querySelector(".draggy-btn"), "draggyBtn"
    @setEl @el.querySelector(".draggy-parent"), "draggyParent"
    @setEl @el.querySelectorAll(".droppy"), "droppies"
    @setEl @el.querySelectorAll(".droppy-child"), "droppyChild"
    @createDraggy()

  # Create a new "draggy" , and listen to it's drag and drop events.
  createDraggy: ->
    parent = @getEl("draggyParent")
    height = parent.offsetHeight

    @draggy = new Draggy
      el: @getEl("draggy")
      lock: "x"

    @listenTo @draggy, "drag", @onDrag
    @listenTo @draggy, "drop", @onDrop

    for el in @getEl "droppies"
      el.firstChild.style.height = ""
      el.classList.add("no-delay")

    @updateDraggyHeight()

    @draggy.el.classList.add("no-delay")


  onDrag: (draggy, isInitialDrag) ->
    @index = if draggy.y < 0 then 0 else 1

    for droppy, i in @getEl "droppies"
      droppy.classList.toggle "active", i is @index

    @transformEl draggy.el,
      y: draggy.y
      scale: 1.05
      transition: if isInitialDrag then "all 300ms" else "none"


  onDrop: (draggy, isReset) ->
    if isReset
      @transformEl draggy.el,
        y: draggy.y
        transition: "all 300ms"

    else
      @moveDroppies()

      @currentDroppy = @getEl("droppies")[@index]
      currentDroppyCenterY = (@currentDroppy.offsetHeight - @draggy.offset.height) / 2

      if draggy.y < 0
        currentDroppyCenterY = -currentDroppyCenterY
      else
        currentDroppyCenterY = currentDroppyCenterY + draggy.offset.height

      currentDroppyCenterY -= draggy.offset.height / 2
      draggy.reset x: 0, y: currentDroppyCenterY

    @setState "touched"

  moveDroppies: ->
    droppyUpdate = @draggy.offset.height / 2

    for droppy, i in @getEl "droppies"
      unless droppy.classList.contains("droppy-top")
        droppyUpdate = -droppyUpdate

      @transformEl droppy,
        y: droppyUpdate
        transition: "all 300ms"

  isCorrect: ->
    @currentDroppy.dataset.correct? is true

  onRefresh: ->
    @afterShow()

  updateDraggyHeight: (draggy) ->
    elements = _.toArray(@getEl("droppies")).concat(@getEl("draggy"))
    height   = _.reduce elements, (m, e) ->
      if m > e.offsetHeight then m else e.offsetHeight

    for droppy, i in @getEl "droppies"
      droppy.firstChild.style.height = height + "px"


module.exports = Categorise2View
