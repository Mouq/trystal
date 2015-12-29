width = 1000
height = 600
filldist = Math.sqrt(width*width + height*height)/2
mindist = Math.min(width, height)
renderer = new PIXI.autoDetectRenderer width, height, antialias: on
stage = new PIXI.Container!
stage.position
  ..x = width/2
  ..y = height/2
mass = new PIXI.Graphics!
#mass.position
#  ..x = width/2
#  ..y = height/2
bullseye = new PIXI.Graphics!
bullseye.position = mass.position
stage.addChild bullseye
stage.addChild mass

tempPoint1 = new PIXI.Point 0, 0
tempPoint2 = new PIXI.Point 0, 0
square = [-1,-1,-1,1,1,1,1,-1]

# For easier manipulation
window.Tristal =
  rad: 10
  precision: 5
  mass: mass
  # List of falling objects
  # (is hash since we expect to be removing random elements)
  falling: {}
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
    graphics.beginFill 0xCC700B, 1
    (graphics.right-edges ||= []).push cx + 2*rad, cy
    (graphics.left-edges  ||= []).push cx - 2*rad, cy
    (graphics.up-edges    ||= []).push cx, cy + 2*rad
    (graphics.down-edges  ||= []).push cx, cy - 2*rad
  # We may want to remove edges that are also centers
  simplifyEdges: (graphics) ->
    centers = graphics.centers
    for dir in ["right","left","up","down"]
      edges = graphics[dir+"Edges"]
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
      graphics[dir+"Edges"] = newedges
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
    for dw from Math.ceil(filldist/rad)*rad to 3*rad by -2*rad
      bullseye.beginFill (if !=alt then 0x222222 else 0x333333), 1
      if mindist/2 - rad <= dw < mindist/2 + rad
        bullseye.beginFill 0x552222, 1
      bullseye.drawPolygon -dw, -dw, -dw, dw, dw, dw, dw, -dw
      bullseye.endFill!
    mass
  newFalling: ->
    obj = new PIXI.Graphics!
    rad = @rad
    stage.addChild obj
    obj.lineStyle 1, 0xAACCBB, 1
    m = 2 * Math.round(Math.random!) - 1
    if Math.random! < 0.5
      obj.direction = if m < 0 then "down" else "up"
      obj.position
        ..x = 0
        ..y = m * (height/2 + rad)
      obj.velocity = new PIXI.Point 0, -m*2
    else
      obj.direction = if m < 0 then "left" else "right"
      obj.position
        ..y = 0
        ..x = m * (width/2 + rad)
      obj.velocity = new PIXI.Point -m*2, 0


    # Display box
    obj.beginFill 0x700BCC, 1
    @unitTrist obj, 0, 0
    obj
  dropFalling: ->
    mass = @mass
    rad = @rad
    pre = @precision
    for k,obj of @falling
      pos = obj.position
      vel = obj.velocity
      # Find out if the obj has hit an edge of the center mass
      # if so, stick it to the man - er, the mass
      stuck = false
      stuck-at = 0
      edges = mass.[obj.direction + "Edges"]
      centers = obj.centers
      for ,ei in edges by 2
        tempPoint1.x = edges[ei]
        tempPoint1.y = edges[ei+1]
        # Make sure we're in the right original reference:
        mass.updateTransform!
        mass.worldTransform.apply(tempPoint1, tempPoint1)
        # But we ultimately want to talk in the falling obj's terms:
        obj.updateTransform!
        obj.worldTransform.applyInverse(tempPoint1, tempPoint1)
        for ,ci in centers by 2
          if Math.abs(tempPoint1.x - centers[ci]) < rad/pre \
              and Math.abs(tempPoint1.y - centers[ci+1]) < rad/pre
            stuck = true
            stuck-at = ei
            break
        break if stuck
      if stuck
        stage.removeChild obj
        @unitTrist mass, edges[ei], edges[ei+1]
        if Math.abs(edges[ei]) >= width/2 - 2*rad or Math.abs(edges[ei+1]) >= height/2 - 2*rad
          throw "You lost!! Ha!"
        @simplifyEdges mass
        #mass.addChild obj
        delete @falling[k]
      else
        stage.worldTransform.apply(pos, tempPoint1)
        x-err = width % rad
        if tempPoint1.x < -width - rad
          pos.x = vel.x + width/2 + x-err
        if tempPoint1.x > width + rad
          pos.x = vel.x - width/2 - x-err
        else
          pos.x += vel.x
        y-err = height % rad
        if tempPoint1.y < -height - rad
          pos.y = vel.y + height/2 + y-err
        if tempPoint1.y > height + rad
          pos.y = vel.y - height/2 - y-err
        else
          pos.y += vel.y
        #stage.worldTransform.applyInverse(tempPoint1, pos)
  shiftFalling: (dir)->
    rad = @rad
    for ,obj of @falling
      vel = obj.velocity
      pos = obj.position
      if vel.x < 0
        pos.y += 2*rad*dir
      if vel.x > 0
        pos.y -= 2*rad*dir
      if vel.y < 0
        pos.x -= 2*rad*dir
      if vel.y > 0
        pos.x += 2*rad*dir

document.onkeydown = (e) !->
  e = e || window.event;
  switch e.which || e.keyCode
  case 37, 65 # left
    Tristal.shiftFalling -1
  #case 38, 87 # up
  case 39, 68 # right
    Tristal.shiftFalling 1
  #case 40, 83 # down
  e.preventDefault

Tristal.initBullseye!
Tristal.initMass!
fall-id = 0
Tristal.falling[fall-id++] = Tristal.newFalling!
animate = (timestamp) ->
  stage.rotation += 0.001
  #mass.rotation -= 0.01
  #Tristal.rad = 60 + 20 * Math.sin timestamp/4000*6.28
  Tristal.dropFalling!
  renderer.render stage
  requestAnimationFrame animate

#onAssetsLoaded = ->
#  animate!
#PIXI.loader
#  .load onAssetsLoaded
animate!
setInterval (!-> Tristal.falling[fall-id++] = Tristal.newFalling!), 1000

#document.onload = ->
document.body.appendChild renderer.view
