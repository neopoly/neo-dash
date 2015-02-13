class Dashing.GitterRoom extends Batman.Model
  @MESSAGES_TO_KEEP = 10

  @resourceName: "gitter_room"
  @hasMany 'messages', inverseOf: 'room', name: "GitterMessage"

  constructor: ->
    super
    @set("online", false)

  appendMessage: (message) =>
    messages = @get("messages")
    if messages.length >= @constructor.MESSAGES_TO_KEEP
      messages.remove(messages.toArray()[0])
    messages.add(message)

class Dashing.GitterMessage extends Batman.Model
  @resourceName: "gitter_message"
  @belongsTo 'room', inverseOf: 'message', name: "GitterRoom"

class Dashing.GitterFayeClientAuthExt
  constructor: (@token) ->
    #nothing specific yet

  outgoing: (message, callback) ->
    if message.channel == '/meta/handshake'
      message.ext = {} unless message.ext
      message.ext.token = @token

    callback(message)

  incoming: (message, callback) ->
    if message.channel == '/meta/handshake'
      if message.successful
        @log('Successfuly subscribed')
      else
        @log('Something went wrong: ', message.error)

    callback(message)

  log: (args...) ->
    console?.log?(args...)

class Dashing.GitterBinder
  constructor: (@room, @client) ->
    # nothing yet

  bind: () =>
    @client.on('transport:down', @onOffline)
    @client.on('transport:up', @onOnline)
    @client.subscribe(@messagesURL(), @onChatMessage, {})
    @client.subscribe(@eventsURL(), @onEvent, {})

  messagesURL: () =>
    "/api/v1/rooms/" + @room.get("room_id") + "/chatMessages"

  eventsURL: () =>
    "/api/v1/rooms/" + @room.get("room_id") + "/events"

  onChatMessage: (data) =>
    @log("chatMessage", data)
    if data.operation == "create" && data.model
      data.model.kind = "chat"
      @room.appendMessage(data.model)

  onEvent: (data) =>
    @log("event", data)
    if data.operation == "create" && data.model
      data.model.kind = "event"
      @room.appendMessage(data.model)

  onOffline: () =>
    @log("went offline")
    @room.set("online", false)

  onOnline: () =>
    @log("went online")
    @room.set("online", true)

  log: (args...) ->
    console?.log?(args...)

class Dashing.Gitter extends Dashing.Widget
  @TIMEOUT = 20000 #ms

  constructor: ->
    super
    @set "room", new Dashing.GitterRoom()

  ready: =>
    @ensureBinder()

  updateTimestamps: =>
    $(@node).find("[data-timestamp]").each ->
      $el = $(@)
      relative = moment($el.attr("data-timestamp")).relativeShort()
      $el.html(relative)
    window.setTimeout(@updateTimestamps, @constructor.TIMEOUT)

  onData: (data) =>
    @ensureBinder()
    $(@node).fadeOut().fadeIn()

  ensureBinder: =>
    @buildBinder() unless @binder

  buildBinder: =>
    if @hasConfig()
      @get("room").set("room_id", @room_id)
      client = new Faye.Client('https://ws.gitter.im/faye', {timeout: 60, retry: 5, interval: 1})
      client.addExtension(new Dashing.GitterFayeClientAuthExt(@access_token))
      @binder = new Dashing.GitterBinder(@get("room"), client)
      @binder.bind()
      @updateTimestamps()

  hasConfig: =>
    @access_token && @room_id