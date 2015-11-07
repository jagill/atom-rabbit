
abs = (x) ->
  if isNaN(x) or !x?
    throw Error("Must abs a number, not #{x}")
  return x if x >= 0
  return -1 * x

placeToString = (place) ->
  "#{place.filepath}::#{place.position.row}:#{place.position.column}"

defaults =
  maxDepth: 20
  rowThreshold: 2
  columnThreshold: 2


###
        oldPlace =
          position: data.oldBufferPosition
          filepath: editor.getPath()
        newPlace =
          position: data.newBufferPosition
          filepath: editor.getPath()
        console.log 'Changed position from', placeToString(oldPlace), 'to', placeToString(newPlace)
        # cursor, oldBufferPosition, textChanged
        if abs(oldPlace.position.row - newPlace.position.row) > @rowThreshold or \
            abs(oldPlace.position.column - newPlace.position.column) < @columnThreshold
          console.log 'Pushing changed position'

###

class PlaceQueue
  constructor: (options={})->
    @positionStack = []
    @currentIndex = 0
    @maxDepth = options.maxDepth || defaults.maxDepth
    @rowThreshold = options.rowThreshold ? defaults.rowThreshold
    @columnThreshold = options.columnThreshold ? defaults.columnThreshold

  toString: ->
    return '' + (placeToString(p) for p in @positionStack)

  down: ->
    if @currentIndex == @positionStack.length - 1
      console.log "Already at bottom of stack, can't go down any more."
      return false
    else
      @currentIndex++
      console.log 'Going down to', @currentIndex, @positionStack[@currentIndex]
      return true

  up: ->
    if @currentIndex == 0
      console.log "Already at top of stack, can't go up any more."
      return false
    else
      @currentIndex--
      console.log 'Going up to', @currentIndex, @positionStack[@currentIndex]
      return true

  currentPlace: ->
    return @positionStack[@currentIndex]

  ###
  @param position (obj) {filepath:, position: Point}
  ###
  push: (place) ->
    unless place?
      throw Error("Must not push null or undefined position.")
    currentPos = @currentPlace()

    unless !currentPos? or \
        place.filepath != currentPos.filepath or \
        abs(place.position.row - currentPos.position.row) > @rowThreshold or \
        abs(place.position.column - currentPos.position.column) > @columnThreshold
      return


    if @currentIndex != 0
      @positionStack.splice(0, @currentIndex)
      @currentIndex = 0
    # We're actually 'pushing' to the front of the queue, for ease of computation.
    @positionStack.unshift place
    if @positionStack.length > @maxDepth
      @positionStack.splice(@maxDepth)


module.exports = PlaceQueue
