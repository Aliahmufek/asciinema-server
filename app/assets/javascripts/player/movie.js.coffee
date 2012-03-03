class AsciiIo.Movie
  MIN_DELAY: 0.01
  SPEED: 1.0

  constructor: (@model) ->
    @frameNo = 0
    @dataIndex = 0
    @currentTime = 0
    @processedFramesTime = 0
    _.extend(this, Backbone.Events)

  isLoaded: ->
    @model.get('escaped_stdout_data') != undefined

  load: ->
    @model.fetch
      success: => @play()

  play: ->
    @nextFrame()

  pause: ->
    # TODO

  togglePlay: ->
    # TODO

  seek: (percent) ->
    # TODO

  timing: ->
    @model.get('stdout_timing_data')

  data: ->
    unless @_data
      d = @model.get('escaped_stdout_data')
      d = eval "'" + d + "'"
      d = ArchUtils.bz2.decode(d)
      @_data = d

    @_data

  nextFrame: () ->
    # return if @currentData.length > 100

    if frame = @timing()[@frameNo++] # @frameNo += 1
      [delay, count] = frame

      frameData = @data().slice(@dataIndex, @dataIndex + count)
      @dataIndex += count

      if delay <= @MIN_DELAY
        @triggerAndSchedule(frameData)
      else
        realDelay = delay * 1000 * (1.0 / @SPEED)
        setTimeout(
          =>
            @trigger('movie-awake')
            @triggerAndSchedule(frameData)
          realDelay
        )

      true
    else
      @trigger('movie-finished')
      # @terminal.stopCursorBlink()
      # console.log "finished in #{((new Date()).getTime() - @startTime) / 1000} seconds"

      false

  triggerAndSchedule: (data) ->
    @trigger('movie-frame', data)
    @nextFrame()

  # processFrame: (count) ->
  #   # return
  #   # @currentData += @data.slice(@dataIndex, @dataIndex + count)
  #   data = @data.slice(@dataIndex, @dataIndex + count)
  #   # console.log data
  #   @dataIndex += count
  #   @trigger('movie-frame', data)

    # @currentData = @interpreter.feed(@currentData)

    # if @currentData.length > 0
    #   @logStatus(count)

  # logStatus: (count) ->
  #   console.log 'rest: ' + Utf8.decode(@currentData)

  #   if @currentData.length > 100
  #     head = @currentData.slice(0, 100)
  #     hex = ("0x#{c.charCodeAt(0).toString(16)}" for c in head)
  #     console.log "failed matching: '" + Utf8.decode(head) + "' (" + hex.join() + ") [pos: " + (@dataIndex - count) + "]"
  #     return
