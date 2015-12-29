width = 600
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
mass.position
  ..x = width/2
  ..y = height/2
bullseye = new PIXI.Graphics!
bullseye.position = mass.position
stage.addChild bullseye
stage.addChild mass

tempPoint1 = new PIXI.Point 0, 0
tempPoint2 = new PIXI.Point 0, 0
square = [-1,-1,-1,1,1,1,1,-1]

# For easier manipulation
window.Tristal =
  rad: 20
  precision: 5
  mass: mass
  # Draw a 'unit' square, plus some extras
  unitTrist: (graphics, cx, cy) ->
    rad = @rad
    pre = @precision
    mass.beginFill 0x700BCC, 1
    graphics.drawRect cx - rad, cy - rad, 2*rad, 2*rad
    # Metadata
    centers = graphics.centers ||= []
    centers.push cx, cy
    graphics.beginFill 0x70CC0B, 1
    graphics.drawCircle cx, cy, rad/pre
    graphics.beginFill 0xCC700B, 1
    gedges = graphics.edges ||= []
    newedges =
      cx + 2*rad, cy
      cx - 2*rad, cy
      cx, cy + 2*rad
      cx, cy - 2*rad
    for ,i in newedges by 2
      graphics.drawCircle newedges[i], newedges[i+1], rad/pre
      gedges.push newedges[i], newedges[i+1]
  # We may want to remove edges that are also centers
  simplifyEdges: (graphics) ->
    centers = graphics.centers
    edges = graphics.edges
    newedges = []
    rad = @rad
    pre = @precision
    for ,i in edges by 2
      is-center = false
      for ,j in centers by 2
        if edges[i] == centers[j] and edges[i+1] == centers[j+1]
          is-center = true
          break
      unless is-center
        newedges.push edges[i], edges[i+1]
    graphics.edges = newedges
  # Initialize mass and bullseye
  initMass: ->
    mass = @mass
    rad = @rad
    mass.clear!
    mass.lineStyle 1, 0xAACCBB, 1
    @unitTrist mass, 0, 0
    mass
  initBullseye: ->
    rad = @rad
    bullseye.clear!
    alt = true
    for dw from filldist to 3*rad by -2*rad
      bullseye.beginFill (if !=alt then 0x222222 else 0x333333), 1
      bullseye.drawPolygon -dw, -dw, -dw, dw, dw, dw, dw, -dw
      bullseye.endFill!
    mass
  falling: []
  newFalling: ->
    obj = new PIXI.Graphics!
    rad = @rad
    stage.addChild obj
    obj.lineStyle 1, 0xAACCBB, 1
    obj.position
      ..x = width/2
      ..y = -rad
    obj.velocity = new PIXI.Point 0, 2
    obj.beginFill 0x700BCC, 1

    # Display box
    @unitTrist obj, 0, 0
    obj
  dropFalling: ->
    mass = @mass
    rad = @rad
    pre = @precision
    for obj,i in @falling
      pos = obj.position
      vel = obj.velocity
      # Find out if the obj has hit an edge of the center mass
      # if so, stick it to the man - er, the mass
      stuck = false
      stuck-at = 0
      edges = mass.edges
      centers = obj.centers
      for ,ei in edges by 2
        tempPoint1.x = edges[ei]
        tempPoint1.y = edges[ei+1]
        # Make sure we're in the right original reference:
        mass.updateTransform!
        mass.worldTransform.apply(tempPoint1, tempPoint1)
        # But we ultimately want to talk in the falling obj's terms:
        obj.updateTransform!
        obj.worldTransform.applyInverse(tempPoint1, tempPoint2)
        for ,ci in centers by 2
          if Math.abs(tempPoint2.x - centers[ci]) < rad/pre \
              and Math.abs(tempPoint2.y - centers[ci+1]) < rad/pre
            stuck = true
            stuck-at = ei
            break
        break if stuck
      if stuck
        if Math.abs(edges[ei]) >= width/2 - rad or Math.abs(edges[ei+1]) >= height/2 - rad
          throw "You lost!! Ha!"
        stage.removeChild obj
        @unitTrist mass, edges[ei], edges[ei+1]
        @simplifyEdges mass
        #mass.addChild obj
        @falling[i] = @newFalling!
      else
        pos.x = (pos.x + vel.x + rad) % (filldist*2+2*rad) - rad
        pos.y = (pos.y + vel.y + rad) % (filldist*2+2*rad) - rad
  drawFalling: ->
    for obj in @falling
      shape = obj.myshape
      obj.drawShape shape

Tristal.initBullseye!
Tristal.initMass!
Tristal.falling.push Tristal.newFalling!
animate = (timestamp) ->
  stage.rotation += 0.001
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
