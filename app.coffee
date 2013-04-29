$ ->
  $win = $(window)
  $drawArea = $(".draw-area")

  emptyDiv = -> $("<div></div>")
  drawAreafillHeight = -> $drawArea.css 'height', $win.height() - $drawArea.offset().top - 30
  drawAreafillHeight()
  $win.on 'resize', drawAreafillHeight

  currentItem = null
  allItems = []

  makeUnselectable = ->
    for item in allItems
      item.css 
        pointerEvents: "none"
        cursor: ""

  makeSelectable = ->
    for item in allItems
      item.css 
        pointerEvents: "all"
        cursor: "pointer"

  makeSelected = (item) -> 
    for i in allItems
      i.removeClass 'selected'

    $(item).addClass 'selected'

  startPos = null
  endPos = null

  $drawArea.on 'mousedown', (e) ->
    startPos = x: e.offsetX, y: e.offsetY
    currentItem = emptyDiv()
    element = currentItem[0]

    makeUnselectable()

    currentItem.css
      cursor: "default"
      pointerEvents: "none"
      position: "absolute"
      width: 0
      height: 0
      border: "2px solid black"

    element.style['-webkit-transform'] = "translate(#{startPos.x}px, #{startPos.y}px)"

    currentItem.appendTo $drawArea

  $drawArea.on 'mousemove', (e) ->
    pos = x: e.offsetX, y: e.offsetY
    if currentItem
      element = currentItem[0]
      left = Math.min(pos.x, startPos.x)
      width = Math.max(pos.x, startPos.x) - left

      top = Math.min(pos.y, startPos.y)
      height = Math.max(pos.y, startPos.y) - top

      element.style['-webkit-transform'] = "translate(#{left}px, #{top}px)"

      currentItem.css      
        width: width
        height: height
        
  cancelDrag = (e) -> 
    if currentItem
      if currentItem.width() < 10 and currentItem.height() < 10 
        currentItem.remove()
        currentItem = null
        return

      currentItem.mousedown (e) ->
        makeSelected(this)
        e.stopPropagation()

      currentItem.addClass 'draw-item'


      allItems.push currentItem
      currentItem = null
      makeSelectable()


  # $drawArea.on 'mousee', cancelDrag
  $drawArea.on 'mouseup', cancelDrag