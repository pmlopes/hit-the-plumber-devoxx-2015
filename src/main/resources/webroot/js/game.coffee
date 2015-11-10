Config.title = ['MEMLEAK', "HUNT"]

eb = new EventBus("http://#{window.location.host}/eventbus")

eb.onopen = ->
  eb.send 'memleak-hunt', {action: 'join', playerId: playerId}

window.begin = ->
  new Player()

class Player extends Actor
  update: ->
    @pos.setValue Mouse.pos

    if Mouse.isPressing
      eb.send 'memleak-hunt',{action: 'shoot', playerId: playerId, x: @pos.x, y: @pos.y}
