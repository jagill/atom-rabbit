# RabbitView = require './rabbit-view'
PlaceQueue = require './place-queue'
{CompositeDisposable, TextEditor} = require 'atom'

makePlace = (path, point) ->
  return {
    filepath: path
    position: {row: point.row, column: point.column}
  }

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
        if !@queue.areEqual(oldPlace, newPlace)
          @push oldPlace
          @push newPlace

    @subscriptions.add atom.workspace.observePanes (pane) =>
      @subscriptions.add pane.onDidChangeActiveItem (item) =>
        # This can be undefined if the pane closes.
        return unless item and item instanceof TextEditor
        editor = atom.workspace.getActiveTextEditor()
        return unless editor
        pos = editor.getCursorBufferPosition()
        console.log "Active pane changed, now in #{editor.getPath()}::#{pos}"
        @push makePlace editor.getPath(), pos

  deactivate: ->
    # @modalPanel.destroy()
    @subscriptions.dispose()
    # @rabbitView.destroy()

  serialize: ->
    rabbitViewState: @rabbitView.serialize()

  go: (place) ->
    return unless place
    atom.workspace.open place.filepath,
      activatePane: true
      initialLine: place.position.row
      initialColumn: place.position.column

  down: ->
    @queue.down()
    @go @queue.currentPlace()

  up: ->
    @queue.up()
    @go @queue.currentPlace()

  push: (position) ->
    @queue.push position
    # @toggle()

  toggle: ->
    console.log @queue.toString()
