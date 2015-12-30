tempPoint1 = new PIXI.Point 0, 0
tempPoint2 = new PIXI.Point 0, 0

const DIRENUM = {left: 0, up: 1, right: 2, down: 3}
const ORDINALS = [ \nw, \ne, \se, \sw ]
# extendes PIXI.Graphics ?
export class Trystal
  # Create a PIXI container, initialize important items
  (@width, @height) ->
    @filldist = Math.sqrt(width*width + height*height)/2
    @mindist = Math.min(width, height)
    @container = container = new PIXI.Graphics!
    container.position
      ..x = width/2
      ..y = height/2
    container.addChild @bullseye = new PIXI.Graphics!
    @initBullseye!
    container.addChild @mass = new PIXI.Graphics!
    @initMass!
  rad: 10
  precision: 2
  # List of falling objects
  # (is hash since we expect to be removing random elements)
  falling: {}
  # Draw a 'unit' square, plus some extras
  unitTrist: (graphics, cx, cy) ->
    rad = @rad
    pre = @precision
    graphics.beginFill 0x700BCC, 1
    graphics.drawRect cx - rad, cy - rad, 2*rad, 2*rad
    # Metadata
    centers = graphics.centers ||= []
    centers.push cx, cy
    graphics.beginFill 0x70CC0B, 1
    graphics.beginFill 0xCC700B, 1
    (graphics.edges0 ||= []).push cx + 2*rad, cy
    (graphics.edges1 ||= []).push cx, cy + 2*rad
    (graphics.edges2 ||= []).push cx - 2*rad, cy
    (graphics.edges3 ||= []).push cx, cy - 2*rad
  # We may want to remove edges that are also centers
  simplifyEdges: (graphics) ->
    centers = graphics.centers
    for ,v of DIRENUM
      edges = graphics["edges"+v]
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
      graphics["edges"+v] = newedges
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
    bullseye = @bullseye
    bullseye.clear!
    alt = true
    for dw from Math.ceil(@filldist/rad)*rad to 3*rad by -2*rad
      bullseye.beginFill (if !=alt then 0x222222 else 0x333333), 1
      if @mindist/2 - rad <= dw < @mindist/2 + rad
        bullseye.beginFill 0x552222, 1
      bullseye.drawPolygon -dw, -dw, -dw, dw, dw, dw, dw, -dw
      bullseye.endFill!
    bullseye
  fall-id = 0
  newFalling: ->
    obj = new PIXI.Graphics!
    rad = @rad
    @container.addChild obj
    obj.lineStyle 1, 0xAACCBB, 1
    m = 2 * Math.round(Math.random!) - 1
    if Math.random! < 0.5
      obj.direction = if m < 0 then "down" else "up"
      obj.position
        ..x = 0
        ..y = m * @mindist/2
      obj.velocity = new PIXI.Point 0, -m*2
    else
      obj.direction = if m < 0 then "right" else "left"
      obj.position
        ..y = 0
        ..x = m * @mindist/2
      obj.velocity = new PIXI.Point -m*2, 0

    # Display box
    obj.beginFill 0x700BCC, 1
    @unitTrist obj, 0, 0
    @falling[fall-id++] = obj
  dropFalling: ->
    mass = @mass
    container = @container
    rad = @rad
    pre = @precision
    for k,obj of @falling
      pos = obj.position
      vel = obj.velocity
      dir = obj.direction
      # Find out if the obj has hit an edge of the center mass
      # if so, stick it to the man - er, the mass
      stuck = false
      stuck-at = 0
      # The mass may be rotated. Make sure we're getting the right edge
      theta = mass.rotation
      rot_num = Math.floor(Math.abs(theta)/Math.PI*2) % 4
      if theta < 0 then rot_num = 4 - rot_num
      corrected_dir = (DIRENUM[dir]-rot_num)%4
      if corrected_dir < 0 then corrected_dir = 4 + corrected_dir
      edges = mass["edges"+corrected_dir]
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
        container.removeChild obj
        @unitTrist mass, edges[ei], edges[ei+1]
        if Math.max(Math.abs(edges[ei]),Math.abs(edges[ei+1])) >= @mindist/2 - 2*rad
          throw "You lost!! Ha!"
        @simplifyEdges mass
        #mass.addChild obj
        delete @falling[k]
      else
        container.updateTransform!
        container.worldTransform.apply(pos, tempPoint1)
        width = @width
        height = @height
        x-dist = width/2 + 2*rad
        y-dist = height/2 + 2*rad
        theta = container.rotation
        # XXX: Naughty ;) _sr/_cr is not part of the public API
        sr = container._sr #Math.sin(theta)
        cr = container._cr #Math.cos(theta)
        tr = sr/cr
        # Pretend 0 <= theta < pi/4, and adjust before and after
        # otherwise the logic is too involved…
        rot_num = Math.floor(Math.abs(theta)/Math.PI*2) % 4
        if theta < 0 then rot_num = 4 - rot_num
        # fdir is the direction relative to the frame, toward the corners
        findex = DIRENUM[dir]
        fdir = ORDINALS[(findex + rot_num) % 4]
        # We also need to switrh around the coordinate axes to act like theta < pi/4
        if rot_num % 2 is not 0
          tx = pos.x
          ty = pos.y
          pos.x = ty
          pos.y = tx
        # TODO: Abstract/simplify
        switch fdir
        case \nw
          if tempPoint1.y < - 2*rad or tempPoint1.x < - 2*rad
            pos.x = Math.min \
              y-dist/sr - pos.y/tr,
              x-dist/cr + pos.y*tr,
        case \se
          if tempPoint1.y > height + 2*rad or tempPoint1.x > width + 2*rad
            pos.x = -Math.min \
              y-dist/sr + pos.y/tr,
              x-dist/cr - pos.y*tr,
        case \ne
          if tempPoint1.y < - 2*rad or tempPoint1.x > width + 2*rad
            pos.y = Math.min \
              y-dist/cr - pos.x*tr,
              x-dist/sr + pos.x/tr,
        case \sw
          if tempPoint1.y > height + 2*rad or tempPoint1.x < - 2*rad
            pos.y = -Math.min \
              y-dist/cr + pos.x*tr,
              x-dist/sr - pos.x/tr,
        # Undo any transformations
        if rot_num % 2 is not 0
          tx = pos.x
          ty = pos.y
          pos.x = ty
          pos.y = tx
        pos.x += vel.x
        pos.y += vel.y
  shiftFalling: (spin)->
    rad = @rad
    for ,obj of @falling
      dir = obj.direction
      pos = obj.position
      tx = pos.x
      ty = pos.y
      switch dir
      case \left
        ty += 2*rad*spin
        pos.y = if Math.abs(ty) >= @mindist/2 then -pos.y else ty
      case \right
        ty -= 2*rad*spin
        pos.y = if Math.abs(ty) >= @mindist/2 then -pos.y else ty
      case \up
        tx -= 2*rad*spin
        pos.x = if Math.abs(tx) >= @mindist/2 then -pos.x else tx
      case \down
        tx += 2*rad*spin
        pos.x = if Math.abs(tx) >= @mindist/2 then -pos.x else tx
  rotate: (spin)->
    @mass.rotation += spin*Math.PI/2
    for ,obj of @falling
      obj.rotation += spin*Math.PI/2
