# 
# jQuery EX Slides
# http://toniho.com
# Version: 0.2 (20-SEPT-2013)
# Available under the MIT license
# http://www.opensource.org/licenses/mit-license.php
# Requires: jQuery v1.7.2 or later
# 
$ = jQuery

$.fn.exslides = (options) ->

  opts = $.extend( {}, $.fn.exslides.defaults, options );

  return @.each ->
    $this = $(@)
    $slides = $elements = $(@).children()
    # $elements = $slides.get()
    busy = false
    if($slides.length < 2) 
      $slides.addClass 'active'
      return false

    slWrap = 'r-slides-container'
    $(@).wrapInner("<div class=\"#{slWrap}\" />")
    $slideWrap =  $( $this.children(0) )
    $slideWidth = $slideWidthIni = $($elements[0]).width()
    $slideWidthIni = parseInt $($elements[0]).css('max-width')
    $offset = ($this.width() - $slideWidth) / 2
    activeSlide = 0


    # Check for 3d transform support https://gist.github.com/lorenzopolidori/3794226
    has3d = ->
      el = document.createElement('p')
      transforms = 
        webkitTransform : '-webkit-transform'
        OTransform : '-o-transform'
        msTransform : '-ms-transform'
        MozTransform : '-moz-transform'
        transform : 'transform'

      document.body.insertBefore(el,null)
      for t in transforms
        if el.style[t] not undefined
          el.style[t] = 'translate3d(1px,1px,1px)'
          has3d = window.getComputedStyle(el).getPropertyValue(transforms[t])

      document.body.removeChild(el)
      (has3d not undefined and has3d.length > 0 and has3d not "none")

    getSlidePosition = (dactiveSlide) ->
      if $this.width() <= $slideWidth
        $slideWidth = $this.width()
        $offset = 0
        $slidePosition = dactiveSlide * $this.width()
      else
        $offset = parseInt ($this.width() - $slideWidth) / 2
        $slidePosition = dactiveSlide * $slideWidth  
        $slideWidth = $slideWidthIni      
      return $offset - ($slideWidth*2) - $slidePosition

    calculatePositionWidth=  ->
      thisWidth = $this.width()
      if thisWidth <= $slideWidth
        $slides.width(thisWidth) 
        $slideWidth = thisWidth
        $offset = 0
        $slidePosition = activeSlide * thisWidth
      else
        $offset = parseInt (thisWidth - $slideWidth) / 2
        $slidePosition = activeSlide * $slideWidth  
        $slideWidth = $slideWidthIni
      
      slidePosition = getSlidePosition(activeSlide)
      if has3d
        $slideWrap
          .css('-webkit-transform',"translate3d(#{slidePosition}px,0,0)")    
          .css('transform',"translate3d(#{slidePosition}px,0,0)")    
      else
        $slideWrap.css('margin-left',$offset-($slideWidth*2) - $slidePosition)    

    doSlide = (direction='next') ->
      return false if busy 
      busy = true
      if direction == 'next'
        activeSlide++
        dirSign = '-'
      else if direction == 'prev'
        activeSlide--
        dirSign = '+'
      $($slides).removeClass 'active'
      
      positionAfter=0
      slideAfter = activeSlide
      if activeSlide >= $elements.length
        $($slides[$elements.length+2]).addClass 'active'
        positionAfter = $offset-($slideWidth*2)
        slideAfter = 0
      else if activeSlide < 0
        slideAfter = $elements.length-1
        $($slides[ 1 ]).addClass 'active'
        positionAfter = $offset-($slideWidth*($elements.length+1))      
      else  
        positionAfter = 0

      slidePosition = getSlidePosition(activeSlide)
      if has3d
        $slideWrap
          .css('-webkit-transition',"#{opts.speed}ms" )
          .css('transition',"#{opts.speed}ms")
          .css('-webkit-transform',"translate3d(#{slidePosition}px,0,0)")
          .css('transform',"translate3d(#{slidePosition}px,0,0)")
        setTimeout(->
          calculatePositionWidth()
          $slideWrap
            .css('-webkit-transition',"0ms")
            .css('transition',"0ms")
          if positionAfter
            $slideWrap
              .css('-webkit-transform',"translate3d(#{positionAfter}px,0,0)")
              .css 'transform',"translate3d(#{positionAfter}px,0,0)"
          busy = false
        ,opts.speed+50)
      else  
        $slideWrap.animate('margin-left':"#{slidePosition}px",opts.speed,opts.easing)
        setTimeout(->
          calculatePositionWidth()
          if positionAfter 
            $slideWrap.css("margin-left":"#{positionAfter}px")
          busy = false
        ,opts.speed+50)
      activeSlide = slideAfter
      $($elements[ activeSlide ]).addClass 'active'
        

    $slideWrap
      .prepend($($elements[ $elements.length - 1 ]).clone())
      .prepend($($elements[ $elements.length - 2 ]).clone())
      .append($($elements[ 0 ]).clone())
      .append($($elements[ 1 ]).clone())
    $slides = $slideWrap.children()
    $slideWrap.width($slideWidthIni * $($slides).length)
    
    if opts.showNav
      $this.append  "<div class=\"exslide-nav-wrap\"><div class=\"exslide-nav\"><span class=\"prev\">Prev</span><span class=\"next\">Next</span></div></div>"
      $('.exslide-nav .prev').bind('click', ->
        clearInterval(slideInterval)
        doSlide('prev')
      )
      $('.exslide-nav .next').bind('click', ->
        clearInterval(slideInterval)
        doSlide()
      )   
    # add swipe functionality
    if($.fn.swipe)   
      $($this).swipe(
        swipe:(event, direction, distance, duration, fingerCount) ->
          if direction == 'right'
            clearInterval(slideInterval)
            doSlide('prev')
          if direction == 'left'
            clearInterval(slideInterval)
            doSlide()
      )      
    
    $($elements[ 0 ]).addClass('active')
    slideInterval = setInterval(->
      doSlide()
    ,opts.timeout)
    calculatePositionWidth()

    $(window).resize =>
      calculatePositionWidth()

$.fn.exslides.defaults = 
  speed:800
  timeout:5000
  easing:'swing'
  showNav: true
