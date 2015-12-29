PIXI.Matrix.prototype.applyFlat = (points) ->
  newPoints = []
  for ,i in points by 2
    x = points[i]
    y = points[i+1]
    newPoints[i]   = @a * x + @c * y + @tx
    newPoints[i+1] = @b * x + @d * y + @ty;
  newPoints
