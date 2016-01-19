SlideView = require("views/slide")
Draggy = require("views/components/draggy")

class CategoriseView extends SlideView
  template: require("./template")

  serialize: ->
    data = super
    data.categories = _.shuffle data.categories
    data

  events: ->
    "iostap .btn-done": "showAnswer"
    "iostap .btn-exit": "exit"

  afterShow: ->
    @setEl @el.querySelector(".draggy"), "draggy"
    @setEl @el.querySelectorAll(".droppy"), "droppies"
    @createDraggy()

  # Create a new "draggy" , and listen to it's drag and drop events.
  createDraggy: ->
    parent = @getEl("draggy").parentNode
    height = parent.offsetHeight / 2

    @draggy = new Draggy
      el: @getEl("draggy")
      minY: -height
      maxY: height
      lock: "x"

    @listenTo @draggy, "drag", @onDrag
    @listenTo @draggy, "drop", @onDrop

  onDrag: (draggy, isInitialDrag) ->
    draggy.el.classList.remove "starting-pos"

    index = if draggy.y < -draggy.el.offsetHeight / 2 then 0 else 1

    for droppy, i in @getEl "droppies"
      droppy.classList.toggle "active", i is index

    @transformEl draggy.el,
      x: "-50%"
      y: draggy.y
      scale: 1.05
      transition: if isInitialDrag then "all 300ms" else "none"

  onDrop: (draggy, isReset) ->
    if isReset
      @transformEl draggy.el,
        x: "-50%"
        y: draggy.y
        transition: "all 300ms"

    else
      index = if draggy.y < -draggy.el.offsetHeight / 2 then 0 else 1

      @currentDroppy = @getEl("droppies")[index]
      currentDroppyCenterY = @currentDroppy.offsetHeight / 2

      if draggy.y < -draggy.el.offsetHeight / 2
        currentDroppyCenterY = -currentDroppyCenterY

      currentDroppyCenterY -= draggy.offset.height / 2


      draggy.reset x: 0, y: currentDroppyCenterY

    @setState "touched"


  isCorrect: ->
    @currentDroppy.dataset.correct? is true


module.exports = CategoriseView
