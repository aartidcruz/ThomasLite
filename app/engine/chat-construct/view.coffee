SlideView = require("views/slide")

class ChatConstructView extends SlideView
  template: require("./template")

  events: ->
    "iostap .btn-next": "next"
    "iostap .btn-exit": "exit"



module.exports = ChatConstructView
