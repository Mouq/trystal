PIXI.Matrix.prototype.applyFlat = (points) ->
  newPoints = []
  for ,i in points by 2
    x = points[i]
    y = points[i+1]
    newPoints[i]   = @a * x + @c * y + @tx
    newPoints[i+1] = @b * x + @d * y + @ty
  newPoints

PIXI.Matrix.prototype.applyInverseFlat = (points) ->
  newPoints = []
  id = 1 / (@a * @d + @c * -@b)
  for ,i in points by 2
    x = points[i]
    y = points[i+1]
    newPoints[i]   = @d * id * x + -@c * id * y + (@ty * @c - @tx * @d) * id
    newPoints[i+1] = @a * id * y + -@b * id * x + (-@ty * @a + @tx * @b) * id
  newPoints
