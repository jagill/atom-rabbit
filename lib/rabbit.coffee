# RabbitView = require './rabbit-view'
PlaceQueue = require './place-queue'
{CompositeDisposable} = require 'atom'

placeEqual = (a, b) ->
  return false unless a? and b?
  return a.filepath == b.filepath and
    a.position.row == b.position.row and
    a.position.column == b.position.column

placeToString = (place) ->
  filename = place.filepath.split('/').pop()
  "#{filename}::#{place.position.row}:#{place.position.column}"

makePlace = (filepath, point) ->
  return filepath: filepath, position: {row: point.row, column: point.column}

module.exports = Rabbit =
  rabbitView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    console.log 'Activating Rabbit'
    @queue = new PlaceQueue()

    # @rabbitView = new RabbitView(state.rabbitViewState)
    # @modalPanel = atom.workspace.addModalPanel(item: @rabbitView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'rabbit:toggle': => @toggle()
    @subscriptions.add atom.commands.add 'atom-workspace', 'rabbit:up': => @up()
    @subscriptions.add atom.commands.add 'atom-workspace', 'rabbit:down': => @down()
    @subscriptions.add atom.workspace.observeTextEditors (editor) =>
      console.log 'Observing editor', editor.getPath()
      editor.onDidChangeCursorPosition (data) =>
        return if data.textChanged
        oldPlace = makePlace editor.getPath(), data.oldBufferPosition
        newPlace = makePlace editor.getPath(), data.newBufferPosition
        @push oldPlace
        @push newPlace



  deactivate: ->
    # @modalPanel.destroy()
    @subscriptions.dispose()
    # @rabbitView.destroy()

  serialize: ->
    rabbitViewState: @rabbitView.serialize()

  go: (place) ->
    console.log 'GO', placeToString(place)
    atom.workspace.open(place.filepath, {activatePane: true})
    atom.workspace.getActiveTextEditor().setCursorBufferPosition place.position

  down: ->
    @queue.down()
    @go @queue.currentPlace()

  up: ->
    @queue.up()
    @go @queue.currentPlace()

  push: (position) ->
    console.log 'Push', placeToString(position)
    @queue.push position
    @toggle()

  toggle: ->
    console.log @queue.toString()
