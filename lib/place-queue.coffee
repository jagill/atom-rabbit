
abs = (x) ->
  if isNaN(x) or !x?
    throw Error("Must abs a number, not #{x}")
  return x if x >= 0
  return -1 * x

placeToString = (place) ->
  return 'null' unless place?
  filename = place.filepath.split('/').pop()
  "#{filename}::#{place.position.row}:#{place.position.column}"


defaults =
  maxDepth: 20
  threshold: 2


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
    @previousIndex = null
    @maxDepth = options.maxDepth || defaults.maxDepth
    @threshold = options.threshold ? defaults.threshold

  toString: ->
    return '' + (placeToString(p) for p in @positionStack)

  ###
  We want to ignore changes that (within a single file):
    1. Only move a couple columns
    2. Only move a couple rows
    3. Move from the end of one row to the beginning of the next row
      (check index)
    4. Move up a row to the end of the next row, if the starting column is
      greater than the end column of the new row.

    We'll cheat and only consider filepath and row, even though the column
    change might be significant.
  ###
  areEqual: (oldPlace, newPlace) ->
    return false unless oldPlace? and newPlace?
    return false if oldPlace.filepath != newPlace.filepath
    return abs(oldPlace.position.row - newPlace.position.row) <= @threshold

  down: ->
    if @currentIndex == @positionStack.length - 1
      console.log "Already at bottom of stack, can't go down any more."
      return false
    else
      @previousIndex = @currentIndex
      @currentIndex++
      console.log "Going down to #{@currentIndex} #{placeToString(@positionStack[@currentIndex])}"
      return true

  up: ->
    if @currentIndex == 0
      console.log "Already at top of stack, can't go up any more."
      return false
    else
      @previousIndex = @currentIndex
      @currentIndex--
      console.log "Going up to #{@currentIndex} #{placeToString(@positionStack[@currentIndex])}"
      return true

  currentPlace: ->
    return @positionStack[@currentIndex]

  previousPlace: ->
    return @positionStack[@previousIndex]

  ###
  @param position (obj) {filepath:, position: Point}
  ###
  push: (place) ->
    unless place?
      throw Error("Must not push null or undefined position.")

    if @areEqual(place, @currentPlace()) or @areEqual(place, @previousPlace())
      console.log "#{placeToString(place)} is equal to current or previous."
      return

    console.log "PUSH #{placeToString(place)}"

    # if @currentIndex != 0
    #   @positionStack.splice(0, @currentIndex)
    #   @currentIndex = 0

    # We're actually 'pushing' to the front of the queue, for ease of computation.
    @positionStack.unshift place
    if @positionStack.length > @maxDepth
      @positionStack.splice(@maxDepth)


module.exports = PlaceQueue
