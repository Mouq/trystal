width = 400
height = 400
filldist = Math.sqrt(width*width + height*height)/2
renderer = new PIXI.autoDetectRenderer width, height, antialias: on
stage = new PIXI.Container!
stage.pivot
  ..x = width/2
  ..y = height/2
stage.position
  ..x = width/2
  ..y = height/2
mass = new PIXI.Graphics!
stage.addChild mass
mass.position
  ..x = width/2
  ..y = height/2
bullseye = new PIXI.Graphics!
stage.addChild bullseye
bullseye.position = mass.position

tempPoint = new PIXI.Point 0, 0
square = [-1,-1,-1,1,1,1,1,-1]

# For easier manipulation
window.Tristal =
  rad: 20
  precision: 10
  mass: mass
  bullseye: bullseye
  collidePoints: []
  # Initialize mass and bullseye
  drawMass: ->
    mass = @mass
    rad = @rad
    mass.clear!
    mass.lineStyle 2, 0xAACCBB, 1
    mass.beginFill 0x700BCC, 1
    mass.drawPolygon -rad, -rad, -rad, rad, rad, rad, rad, -rad
    @collidePoints =
      new PIXI.Point 0, 2*rad
      new PIXI.Point 2*rad, 0
      new PIXI.Point 0, -2*rad
      new PIXI.Point -2*rad, 0
    for p in @collidePoints
      mass.drawCircle p.x, p.y, rad/10
    mass
  drawBullseye: ->
    bullseye = @bullseye
    rad = @rad
    bullseye.clear!
    bullseye.lineStyle 2, 0xAACCBB, 1
    for dw from 3*rad to filldist by 2*rad
      bullseye.drawPolygon -dw, -dw, -dw, dw, dw, dw, dw, -dw
    mass
  falling: []
  newFalling: ->
    obj = new PIXI.Graphics!
    rad = @rad
    stage.addChild obj
    obj.lineStyle 2, 0xAACCBB, 1
    obj.position
      ..x = width/2
      ..y = -rad
    obj.velocity = new PIXI.Point 0, 2
    obj.beginFill 0x700BCC, 1

    # Display box
    obj.drawPolygon [-rad, -rad, -rad, rad, rad, rad, rad, -rad]

    # Center/collision boxes
    precision = @precision
    obj.drawPolygon [x*rad/precision for x in square]
    obj.endFill!
    obj
  dropFalling: ->
    mass = @mass
    rad = @rad
    for obj,i in @falling
      pos = obj.position
      vel = obj.velocity
      col = false
      for p in @collidePoints
        mass.worldTransform.apply(p, tempPoint)
        obj.worldTransform.applyInverse(tempPoint, tempPoint)
        if obj.graphicsData[1].shape.contains(tempPoint.x, tempPoint.y)
          col = true
          break
      if col
        stage.removeChild obj
        pos.x -= width/2
        pos.y -= height/2
        #mass.addChild obj
        @falling[i] = @newFalling!
      else
        pos.x = (pos.x + vel.x + rad) % (filldist*2+2*rad) - rad
        pos.y = (pos.y + vel.y + rad) % (filldist*2+2*rad) - rad
  drawFalling: ->
    for obj in @falling
      shape = obj.myshape
      obj.drawShape shape

Tristal.drawMass!
Tristal.drawBullseye!
Tristal.falling.push Tristal.newFalling!
animate = (timestamp) ->
  #stage.rotation += 0.001
  #mass.rotation += 0.01
  #Tristal.rad = 60 + 20 * Math.sin timestamp/4000*6.28
  Tristal.dropFalling!
  renderer.render stage
  requestAnimationFrame animate

#onAssetsLoaded = ->
#  animate!
#PIXI.loader
#  .load onAssetsLoaded
animate!

#document.onload = ->
document.body.appendChild renderer.view
