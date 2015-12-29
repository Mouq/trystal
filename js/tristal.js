// Generated by LiveScript 1.4.0
(function(){
  var width, height, filldist, mindist, renderer, stage, x$, mass, bullseye, tempPoint1, tempPoint2, square, fallId, animate;
  width = 1000;
  height = 600;
  filldist = Math.sqrt(width * width + height * height) / 2;
  mindist = Math.min(width, height);
  renderer = new PIXI.autoDetectRenderer(width, height, {
    antialias: true
  });
  stage = new PIXI.Container();
  x$ = stage.position;
  x$.x = width / 2;
  x$.y = height / 2;
  mass = new PIXI.Graphics();
  bullseye = new PIXI.Graphics();
  bullseye.position = mass.position;
  stage.addChild(bullseye);
  stage.addChild(mass);
  tempPoint1 = new PIXI.Point(0, 0);
  tempPoint2 = new PIXI.Point(0, 0);
  square = [-1, -1, -1, 1, 1, 1, 1, -1];
  window.Tristal = {
    rad: 10,
    precision: 5,
    mass: mass,
    falling: {},
    unitTrist: function(graphics, cx, cy){
      var rad, pre, centers;
      rad = this.rad;
      pre = this.precision;
      mass.beginFill(0x700BCC, 1);
      graphics.drawRect(cx - rad, cy - rad, 2 * rad, 2 * rad);
      centers = graphics.centers || (graphics.centers = []);
      centers.push(cx, cy);
      graphics.beginFill(0x70CC0B, 1);
      graphics.beginFill(0xCC700B, 1);
      (graphics.rightEdges || (graphics.rightEdges = [])).push(cx + 2 * rad, cy);
      (graphics.leftEdges || (graphics.leftEdges = [])).push(cx - 2 * rad, cy);
      (graphics.upEdges || (graphics.upEdges = [])).push(cx, cy + 2 * rad);
      return (graphics.downEdges || (graphics.downEdges = [])).push(cx, cy - 2 * rad);
    },
    simplifyEdges: function(graphics){
      var centers, i$, ref$, len$, dir, edges, newedges, rad, pre, j$, len1$, i, isCenter, k$, len2$, j, results$ = [];
      centers = graphics.centers;
      for (i$ = 0, len$ = (ref$ = ["right", "left", "up", "down"]).length; i$ < len$; ++i$) {
        dir = ref$[i$];
        edges = graphics[dir + "Edges"];
        newedges = [];
        rad = this.rad;
        pre = this.precision;
        for (j$ = 0, len1$ = edges.length; j$ < len1$; j$ += 2) {
          i = j$;
          isCenter = false;
          for (k$ = 0, len2$ = centers.length; k$ < len2$; k$ += 2) {
            j = k$;
            if (edges[i] === centers[j] && edges[i + 1] === centers[j + 1]) {
              isCenter = true;
              break;
            }
          }
          if (!isCenter) {
            newedges.push(edges[i], edges[i + 1]);
          }
        }
        results$.push(graphics[dir + "Edges"] = newedges);
      }
      return results$;
    },
    initMass: function(){
      var mass, rad;
      mass = this.mass;
      rad = this.rad;
      mass.clear();
      mass.lineStyle(1, 0xAACCBB, 1);
      this.unitTrist(mass, 0, 0);
      return mass;
    },
    initBullseye: function(){
      var rad, alt, i$, step$, to$, dw;
      rad = this.rad;
      bullseye.clear();
      alt = true;
      for (i$ = Math.ceil(filldist / rad) * rad, to$ = 3 * rad, step$ = -2 * rad; step$ < 0 ? i$ >= to$ : i$ <= to$; i$ += step$) {
        dw = i$;
        bullseye.beginFill((alt = !alt) ? 0x222222 : 0x333333, 1);
        if (mindist / 2 - rad <= dw && dw < mindist / 2 + rad) {
          bullseye.beginFill(0x552222, 1);
        }
        bullseye.drawPolygon(-dw, -dw, -dw, dw, dw, dw, dw, -dw);
        bullseye.endFill();
      }
      return mass;
    },
    newFalling: function(){
      var obj, rad, m, x$, y$;
      obj = new PIXI.Graphics();
      rad = this.rad;
      stage.addChild(obj);
      obj.lineStyle(1, 0xAACCBB, 1);
      m = 2 * Math.round(Math.random()) - 1;
      if (Math.random() < 0.5) {
        obj.direction = m < 0 ? "down" : "up";
        x$ = obj.position;
        x$.x = 0;
        x$.y = m * (height / 2 + rad);
        obj.velocity = new PIXI.Point(0, -m * 2);
      } else {
        obj.direction = m < 0 ? "left" : "right";
        y$ = obj.position;
        y$.y = 0;
        y$.x = m * (width / 2 + rad);
        obj.velocity = new PIXI.Point(-m * 2, 0);
      }
      obj.beginFill(0x700BCC, 1);
      this.unitTrist(obj, 0, 0);
      return obj;
    },
    dropFalling: function(){
      var mass, rad, pre, k, ref$, obj, pos, vel, stuck, stuckAt, edges, centers, i$, len$, ei, j$, len1$, ci, ref1$, ref2$, xErr, yErr, results$ = [];
      mass = this.mass;
      rad = this.rad;
      pre = this.precision;
      for (k in ref$ = this.falling) {
        obj = ref$[k];
        pos = obj.position;
        vel = obj.velocity;
        stuck = false;
        stuckAt = 0;
        edges = mass[obj.direction + "Edges"];
        centers = obj.centers;
        for (i$ = 0, len$ = edges.length; i$ < len$; i$ += 2) {
          ei = i$;
          tempPoint1.x = edges[ei];
          tempPoint1.y = edges[ei + 1];
          mass.updateTransform();
          mass.worldTransform.apply(tempPoint1, tempPoint1);
          obj.updateTransform();
          obj.worldTransform.applyInverse(tempPoint1, tempPoint1);
          for (j$ = 0, len1$ = centers.length; j$ < len1$; j$ += 2) {
            ci = j$;
            if (Math.abs(tempPoint1.x - centers[ci]) < rad / pre && Math.abs(tempPoint1.y - centers[ci + 1]) < rad / pre) {
              stuck = true;
              stuckAt = ei;
              break;
            }
          }
          if (stuck) {
            break;
          }
        }
        if (stuck) {
          stage.removeChild(obj);
          this.unitTrist(mass, edges[ei], edges[ei + 1]);
          if (Math.abs(edges[ei]) >= width / 2 - 2 * rad || Math.abs(edges[ei + 1]) >= height / 2 - 2 * rad) {
            throw "You lost!! Ha!";
          }
          this.simplifyEdges(mass);
          results$.push((ref2$ = (ref1$ = this.falling)[k], delete ref1$[k], ref2$));
        } else {
          stage.worldTransform.apply(pos, tempPoint1);
          xErr = width % rad;
          if (tempPoint1.x < -width - rad) {
            pos.x = vel.x + width / 2 + xErr;
          }
          if (tempPoint1.x > width + rad) {
            pos.x = vel.x - width / 2 - xErr;
          } else {
            pos.x += vel.x;
          }
          yErr = height % rad;
          if (tempPoint1.y < -height - rad) {
            pos.y = vel.y + height / 2 + yErr;
          }
          if (tempPoint1.y > height + rad) {
            results$.push(pos.y = vel.y - height / 2 - yErr);
          } else {
            results$.push(pos.y += vel.y);
          }
        }
      }
      return results$;
    },
    shiftFalling: function(dir){
      var rad, i$, ref$, obj, vel, pos, results$ = [];
      rad = this.rad;
      for (i$ in ref$ = this.falling) {
        obj = ref$[i$];
        vel = obj.velocity;
        pos = obj.position;
        if (vel.x < 0) {
          pos.y += 2 * rad * dir;
        }
        if (vel.x > 0) {
          pos.y -= 2 * rad * dir;
        }
        if (vel.y < 0) {
          pos.x -= 2 * rad * dir;
        }
        if (vel.y > 0) {
          results$.push(pos.x += 2 * rad * dir);
        }
      }
      return results$;
    }
  };
  document.onkeydown = function(e){
    e = e || window.event;
    switch (e.which || e.keyCode) {
    case 37:
    case 65:
      Tristal.shiftFalling(-1);
      break;
    case 39:
    case 68:
      Tristal.shiftFalling(1);
    }
    e.preventDefault;
  };
  Tristal.initBullseye();
  Tristal.initMass();
  fallId = 0;
  Tristal.falling[fallId++] = Tristal.newFalling();
  animate = function(timestamp){
    stage.rotation += 0.001;
    Tristal.dropFalling();
    renderer.render(stage);
    return requestAnimationFrame(animate);
  };
  animate();
  setInterval(function(){
    Tristal.falling[fallId++] = Tristal.newFalling();
  }, 1000);
  document.body.appendChild(renderer.view);
}).call(this);
