Config.title = ['MEMLEAK', "PLUMBER"]

eb = new EventBus("http://#{window.location.host}/eventbus")
players = {}

eb.onopen = ->
  eb.registerHandler 'memleak-hunt', (err, msg) ->
    switch msg.body.action
      when 'join'
        p = new Player()
        p.playerId = msg.body.playerId
        players[msg.body.playerId] = p

      when 'shoot'
        p = players[msg.body.playerId]
        if p
          p.decay = 5
          p.pos.x = msg.body.x
          p.pos.y = msg.body.y
          p.drawing
          .setColor Color.white
          .addRect 0.05

window.initialize = ->
  Sound.setSeed 1234
  @drums = []
  @drums.push Game.newSound().setDrum().setDrumPattern() for i in [1..4]

window.begin = ->
  drum.playPattern() for drum in @drums
  new Leak for i in [1..30]

window.update = ->
  Actor.scroll Leak, 0, 0.002, 0, 0, 0, 1

class Player extends Actor
  initialize: ->
    Player.destroySe = @newSound().setVolume(3).setDrum()
  update: ->
    if not --@decay
      @drawing.clear()

    if @onCollision Leak
      @newParticle()
      .setColor Color.red
      .setNumber 5

      @drawing.clear()
      Player.destroySe.playNow()
      eb.send 'memleak-hunt-score', {action: 'hit', playerId: @playerId}


class Leak extends Actor
  initialize: ->
    @setDisplayPriority 0.5
  begin: ->
    @drawing
    .setColor Color.yellow
    .addRect 0.05

    @pos.setXy (0.rr 1), (0.rr 1)
