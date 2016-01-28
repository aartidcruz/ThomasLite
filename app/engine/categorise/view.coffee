SlideView = require("views/slide")
Draggy = require("views/components/draggy")

class CategoriseView extends SlideView
  template: require("./template")

  serialize: ->
    data = super
    maxTextLength = if data.width > 300 then 30 else 1
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

    @removeDelayTransitions()
    @updateDroppyHeight()


  # Transform draggy
  onDrag: (draggy, isInitialDrag) ->
    @index = if draggy.y < 0 then 0 else 1

    for droppy, i in @getEl "droppies"
      droppy.classList.toggle "active", i is @index

    @transformEl draggy.el,
      y: draggy.y
      scale: 1.05
      transition: if isInitialDrag then "all 300ms" else "none"


  # Place draggy in correct droppy
  onDrop: (draggy, isReset) ->
    if isReset
      @transformEl draggy.el,
        y: draggy.y
        transition: "all 300ms"

    else
      @draggy.el.classList.add("draggy-drop")

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


  # Move droppies closer together after first drag
  moveDroppies: ->
    droppyUpdate = @draggy.offset.height / 2

    for droppy, i in @getEl "droppies"
      unless droppy.classList.contains("droppy-top")
        droppyUpdate = -droppyUpdate

      @transformEl droppy,
        y: droppyUpdate
        transition: "all 300ms"

  # Update the Droppy height to contain the draggy height
  updateDroppyHeight: ->
    @draggy.getOffset()

    for el in @getEl "droppies"
      el.firstChild.style.height = ""

    height = _.reduce @getEl("droppies"), (m, e) ->
      if m > e.offsetHeight then m else e.offsetHeight
    , @getEl("draggy").offsetHeight

    for droppy, i in @getEl "droppies"
      droppy.firstChild.style.height = height + "px"

    @draggy.options.minY = -height - @draggy.offset.height / 2
    @draggy.options.maxY =  height + @draggy.offset.height / 2


  #Refresh transition delays
  resetTransitions: (isRefresh) ->
    for el in @getEl "droppies"
      el.classList.remove("no-delay")
    @draggy.el.classList.remove("no-delay")


  # Remove transition delays
  removeDelayTransitions: ->
    for el in @getEl "droppies"
      el.classList.add("no-delay")
    @draggy.el.classList.add("no-delay")

  isCorrect: ->
    @currentDroppy.dataset.correct? is true

  onRefresh: ->
    @afterShow()
    @resetTransitions(true)


module.exports = CategoriseView
