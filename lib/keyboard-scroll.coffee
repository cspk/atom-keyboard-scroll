{Point, CompositeDisposable} = require "atom"
{jQuery} = require 'atom-space-pen-views'

module.exports =
  config:
    linesToScrollSingle:
      type: "number"
      default: 3
      title: "Number of lines to scroll for a single hit"

    linesToScrollKeydown:
      type: "number"
      default: 2
      title: "Number of lines to scroll for key down"

    animate:
      type: "boolean"
      default: true
      title: "Animate scroll"

    animationDuration:
      type: "number"
      default: 150
      title: "Duration of animation in milliseconds"

  subscriptions: null

  activate: ->
    @subscriptions = new CompositeDisposable()

    @subscriptions.add atom.commands.add "atom-text-editor",
      "keyboard-scroll:scrollUpWithCursor": (e) =>
        @scrollUp(e.originalEvent.repeat, true)

    @subscriptions.add atom.commands.add "atom-text-editor",
      "keyboard-scroll:scrollDownWithCursor": (e) =>
        @scrollDown(e.originalEvent.repeat, true)

    @subscriptions.add atom.commands.add "atom-text-editor",
      "keyboard-scroll:scrollUp": (e) =>
        @scrollUp(e.originalEvent.repeat, false)

    @subscriptions.add atom.commands.add "atom-text-editor",
      "keyboard-scroll:scrollDown": (e) =>
        @scrollDown(e.originalEvent.repeat, false)

  deactivate: ->
    @subscriptions.dispose()

  animate: (from, to, editorElement) ->
    step = (currentStep) ->
      editorElement.setScrollTop(currentStep)

    done = ->
      animationRunning = false

    unless animationRunning
      animationRunning = true
      animationDuration = 1
      if atom.config.get('keyboard-scroll.animate')
        animationDuration = atom.config.get('keyboard-scroll.animationDuration')
      jQuery({top: from}).animate({top: to}, duration: animationDuration, easing: "swing", step: step, done: done)

  doScroll: (isKeydown, moveCursor, direction) ->
    doMoveCursor = ->
      if moveCursor
        if direction is 1
          editor.moveDown(linesToScroll)
        else
          editor.moveUp(linesToScroll)

    editor = atom.workspace.getActiveTextEditor()
    editorElement = atom.views.getView(editor)
    if isKeydown
      linesToScroll = atom.config.get('keyboard-scroll.linesToScrollKeydown')
      doMoveCursor()
      editorElement.setScrollTop(editorElement.getScrollTop() + (editor.getLineHeightInPixels() * linesToScroll * direction))
    else
      linesToScroll = atom.config.get('keyboard-scroll.linesToScrollSingle')
      @animate(editorElement.getScrollTop(), editorElement.getScrollTop() + (editor.getLineHeightInPixels() * linesToScroll * direction), editorElement)
      doMoveCursor()

  scrollUp: (isKeydown, moveCursor) ->
    @doScroll(isKeydown, moveCursor, -1)

  scrollDown: (isKeydown, moveCursor) ->
    @doScroll(isKeydown, moveCursor, 1)
