Code runs after the DOM loaded event

    $ ->

Create the references for a few jquery variables that will be used later

      $win = $(window)
      $drawArea = $(".draw-area")
      $fileUpload = $('[type="file"]')

Create the string template for the controls DOM

      controlsHTML = """
      <div class='controls'>
        <a onmousedown='
        $(this).parent().parent().remove();window.event.stopPropagation()
        '><i class='icon-trash'></i></a>
        <a onmousedown='
        $(this).parent().parent().insertBefore($(this).parent().parent().prev());window.event.stopPropagation()
        '><i class='icon-arrow-up moveup'></i></a>
        <a onmousedown='$(this).parent().parent().insertAfter($(this).parent().parent().next());window.event.stopPropagation()'><i class='icon-arrow-down movedown'></i></a>
      </div>
      """

Creates a utility function that returns an empty jQuery wrapped div 

      emptyDiv = -> $("<div></div>")

Create a function that makes the draw area expand to fill the full height of the screen and attach it to the window 'resize' handler

      drawAreafillHeight = -> $drawArea.css 'height', $win.height() - $drawArea.offset().top - 30
      drawAreafillHeight()
      $win.on 'resize', drawAreafillHeight

References to the current item and a list of all the items

      currentItem = null
      allItems = []


      makeUnselectable = ->
        for item in allItems
          item.css 
            pointerEvents: "none"

      makeSelectable = ->
        for item in allItems
          item.css 
            pointerEvents: "all"

      makeSelected = (item) -> 
        for i in allItems
          i.removeClass 'selected'
        $(item).addClass 'selected'

      dragging = false
      dragOffset = {x: 0, y: 0}
      dragItem = null
      startDrag = (e, el) ->
        dragging = true
        dragOffset.x = e.offsetX
        dragOffset.y = e.offsetY 
        dragItem = $(el)
        makeUnselectable()
        
      drawMode = null
      buttons = $('a.btn')
      window.setMode = (mode, el) -> 
        drawMode = mode
        buttons.removeClass "active"
        $(el).addClass "active"

      startPos = null
      endPos = null

      $drawArea.on 'mousedown', (e) ->
        startPos = x: e.offsetX, y: e.offsetY
        currentItem = emptyDiv()
        element = currentItem[0]

        dragging = false
        dragItem = null
        $('.selected').removeClass 'selected'
        makeSelectable()
        makeUnselectable()

        currentItem.css
          pointerEvents: "none"
          position: "absolute"
          width: 0
          height: 0
          border: "2px solid black"

        element.style['-webkit-transform'] = "translate(#{startPos.x}px, #{startPos.y}px)"

        currentItem.appendTo $drawArea

      $drawArea.on 'mousemove', (e) ->
        pos = x: e.offsetX, y: e.offsetY
        if dragging
          dragItem[0].style['-webkit-transform'] = "translate(#{pos.x - dragOffset.x}px, #{pos.y - dragOffset.y}px)"
          return

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
        if dragging
          dragging = false
          dragItem = null
          makeSelectable()
          return

        if currentItem
          if currentItem.width() < 10 and currentItem.height() < 10 
            currentItem.remove()
            currentItem = null
            makeSelectable()
            return

          currentItem.mousedown (e) ->
            if $(this).is('.selected')
              startDrag(e, this)
            else
              startDrag(e, this)
              makeSelected(this)
            e.stopPropagation()

          currentItem.addClass 'draw-item'
          $(controlsHTML).appendTo currentItem

          allItems.push currentItem
          currentItem = null
          makeSelectable()

      $drawArea.on 'mouseup', cancelDrag

      imageSource = null
      $fileUpload.on 'change', (e) ->
        reader = new FileReader()
        reader.onload = (ev) ->
          imageSource = $("<img></img>")
            .attr("src", ev.target.result)
            .css
              position: "absolute"
              pointerEvents: "none"
            .appendTo $drawArea
          window.imageSource = imageSource
        reader.readAsDataURL(e.target.files[0])
        $(".upload-area").hide()