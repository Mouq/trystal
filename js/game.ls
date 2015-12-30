width = 1000
height = 600
renderer = new PIXI.autoDetectRenderer width, height, antialias: on
stage = new PIXI.Container!
window.trystal = new Trystal width, height
stage.addChild trystal.container

document.onkeydown = (e) !->
  e = e || window.event;
  switch e.which || e.keyCode
  case 37, 65 # left
    trystal.shiftFalling -1
  case 38, 87 # up
    trystal.rotate 1
  case 39, 68 # right
    trystal.shiftFalling 1
  case 40, 83 # down
    trystal.rotate -1
  e.preventDefault

trystal.newFalling!
#trystalbox.rotation += Math.PI/16*17
animate = (timestamp) ->
  trystal.container.rotation = (trystal.container.rotation + 0.001) % (Math.PI/4)
  #mass.rotation += 0.01
  #Trystal.rad = 60 + 20 * Math.sin timestamp/4000*6.28
  trystal.dropFalling!
  renderer.render stage
  requestAnimationFrame animate

#onAssetsLoaded = ->
#  animate!
#PIXI.loader
#  .load onAssetsLoaded
animate!
setInterval (!-> trystal.newFalling!), 500

#document.onload = ->
document.body.appendChild renderer.view
