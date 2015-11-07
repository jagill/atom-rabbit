# RabbitView = require './rabbit-view'
PlaceQueue = require './place-queue'
{CompositeDisposable} = require 'atom'

placeEqual = (a, b) ->
  return false unless a? and b?
  return a.filepath == b.filepath and
    a.position.row == b.position.row and
    a.position.column == b.position.column

placeToString = (place) ->
  "#{place.filepath}::#{place.position.row}:#{place.position.column}"

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
        @push newPlace

  deactivate: ->
    # @modalPanel.destroy()
    @subscriptions.dispose()
    # @rabbitView.destroy()

  serialize: ->
    rabbitViewState: @rabbitView.serialize()

  go: (place) ->
    atom.workspace.open(place.filepath, {activatePane: true})
    atom.workspace.getActiveTextEditor().setCursorBufferPosition place.position

  down: ->
    @queue.down()
    @go @queue.currentPlace()

  up: ->
    @queue.up()
    @go @queue.currentPlace()

  push: (position) ->
    @queue.push position
    @toggle()

  toggle: ->
    console.log @queue.toString()
