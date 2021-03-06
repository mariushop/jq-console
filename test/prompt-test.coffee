{jqconsole, typer: {typeA, keyDown, type}} = jqconsoleSetup()

describe 'Prompt Interaction', ->
  describe '#Prompt', ->
    after ->
      jqconsole.AbortPrompt()

    it 'inits prompt and auto-focuses', ->
      counter = 0
      jqconsole.$input_source.focus ->
        counter++
      resultCb = ->
      jqconsole.Prompt true, resultCb
      equal jqconsole.GetState(), 'prompt'
      ok counter
      ok jqconsole.history_active
      strictEqual jqconsole.input_callback, resultCb
      equal jqconsole.$prompt.text().trim(), 'prompt_label'

  describe '#AbortPrompt', ->
    it 'aborts the prompt', ->
      jqconsole.Prompt true, ->
      jqconsole.AbortPrompt()
      equal jqconsole.$prompt.text().trim(), ''

    it 'restarts queued prompts', ->
      aCb = ->
      jqconsole.Prompt false, aCb
      bCb = ->
      jqconsole.Prompt true, bCb
      strictEqual jqconsole.input_callback, aCb
      strictEqual jqconsole.history_active, false
      jqconsole.AbortPrompt()
      strictEqual jqconsole.input_callback, bCb
      strictEqual jqconsole.history_active, true
      jqconsole.AbortPrompt()

  describe 'Typing', ->
    beforeEach -> jqconsole.Prompt true, ->
    afterEach -> jqconsole.AbortPrompt()

    it 'handles chars', ->
      str = ''
      test = (ch) ->
        str += ch
        e = $.Event('keypress')
        e.which = ch.charCodeAt(0)
        jqconsole.$input_source.trigger e
        equal jqconsole.$prompt.text().trim(), 'prompt_label' + str

      test 'a'
      test 'Z'
      test '$'
      test 'ƒ'

  describe '#GetPromptText', ->
    beforeEach -> jqconsole.Prompt true, ->
    afterEach -> jqconsole.AbortPrompt()

    it 'gets the current prompt text', ->
      type 'foo'
      equal jqconsole.$prompt.text().trim(), 'prompt_labelfoo'
      equal jqconsole.GetPromptText(), 'foo'

    it 'gets the current prompt text with the label', ->
      type 'foo'
      equal jqconsole.$prompt.text().trim(), 'prompt_labelfoo'
      equal jqconsole.GetPromptText(true), 'prompt_labelfoo'

  describe '#ClearPromptText', ->
    beforeEach -> jqconsole.Prompt true, ->
    afterEach -> jqconsole.AbortPrompt()

    it 'Clears the current prompt text', ->
      type 'foo'
      equal jqconsole.GetPromptText(), 'foo'
      jqconsole.ClearPromptText()
      equal jqconsole.GetPromptText(), ''

    it 'Clears prompt text with label', ->
      type 'foo'
      equal jqconsole.GetPromptText(), 'foo'
      jqconsole.ClearPromptText true
      equal jqconsole.GetPromptText(true), ''

  describe '#SetPromptText', ->
    beforeEach -> jqconsole.Prompt true, ->
    afterEach -> jqconsole.AbortPrompt()
    
    it 'sets the current prompt text', ->
      type 'bar'
      jqconsole.SetPromptText('foo')
      equal jqconsole.GetPromptText(), 'foo'

  describe 'Control Keys', ->
    beforeEach -> jqconsole.Prompt true, ->
    afterEach -> jqconsole.AbortPrompt()

    it 'handles enter', ->
      jqconsole.AbortPrompt()
      counter = 0
      jqconsole.Prompt true, -> counter++
      typeA()
      keyDown 13
      ok counter
      equal jqconsole.$console.find('.jqconsole-old-prompt').last().text().trim(), 'prompt_labela'
      # Restart the prompt for other tests.
      jqconsole.Prompt true, ->

    it 'handles shift+enter', ->
      keyDown 13, shiftKey: on
      equal jqconsole.$prompt.text().trim(), 'prompt_label \nprompt_continue'

    it 'handles tab', ->
      typeA()
      keyDown 9
      equal jqconsole.$prompt.text().trim(), 'prompt_label  a'

    it 'handles shift+tab', ->
      typeA()
      keyDown 9, shiftKey: on
      equal jqconsole.$prompt.text().trim(), 'prompt_labela'

    it 'backspace', ->
      typeA()
      keyDown 8
      equal jqconsole.$prompt.text().trim(), 'prompt_label'

    it 'cntrl+backspace', ->
      typeA()
      typeA()
      keyDown 8, metaKey: on
      equal jqconsole.$prompt.text().trim(), 'prompt_label'

  describe 'Moving', ->
    beforeEach -> jqconsole.Prompt true, ->
    afterEach -> jqconsole.AbortPrompt()

    it 'moves to the left', ->
      type 'xyz'
      keyDown 37
      equal jqconsole.$prompt_left.text().trim(), 'xy'
      keyDown 37
      equal jqconsole.$prompt_left.text().trim(), 'x'
      keyDown 37
      equal jqconsole.$prompt_left.text().trim(), ''
      keyDown 37
      equal jqconsole.$prompt_left.text().trim(), ''

    it 'moves to the right', ->
      type 'xyz'
      keyDown 37
      keyDown 37
      equal jqconsole.$prompt_left.text().trim(), 'x'
      keyDown 39
      equal jqconsole.$prompt_left.text().trim(), 'xy'
      keyDown 39
      equal jqconsole.$prompt_left.text().trim(), 'xyz'
      keyDown 39
      equal jqconsole.$prompt_left.text().trim(), 'xyz'

    it 'moves to the prev line when at the first char of the line moving left', ->
      type 'xyz'
      keyDown 13, shiftKey: on
      type 'abc'
      equal jqconsole.$prompt_left.text().trim(), 'abc'
      keyDown 37
      keyDown 37
      keyDown 37
      keyDown 37
      equal jqconsole.$prompt_left.text().trim(), 'xyz'

    it 'moves to the next line when at the last char of the line moving right', ->
      type 'xyz'
      keyDown 13, shiftKey: on
      type 'abc'
      equal jqconsole.$prompt_left.text().trim(), 'abc'
      keyDown 37
      keyDown 37
      keyDown 37
      keyDown 37
      equal jqconsole.$prompt_left.text().trim(), 'xyz'
      keyDown 39
      equal jqconsole.$prompt_right.text().trim(), 'abc'

    it 'moves to the start of the word', ->
      type 'xyz abc'
      keyDown 37, metaKey: on
      equal jqconsole.$prompt_right.text().trim(), 'abc'
      equal jqconsole.$prompt_left.text().trim(), 'xyz'

    it 'moves to the end of the word', ->
      type 'xyz abc'
      keyDown 37, metaKey: on
      keyDown 37, metaKey: on
      keyDown 39, metaKey: on
      equal jqconsole.$prompt_right.text().trim(), 'abc'
      equal jqconsole.$prompt_left.text().trim(), 'xyz'

    it 'moves to the end of the word', ->
      type 'xyz abc'
      keyDown 37, metaKey: on
      keyDown 37, metaKey: on
      keyDown 39, metaKey: on
      equal jqconsole.$prompt_right.text().trim(), 'abc'
      equal jqconsole.$prompt_left.text().trim(), 'xyz'

    it 'moves to the start of the line', ->
      type 'xyz abc'
      keyDown 36
      equal jqconsole.$prompt_right.text().trim(), 'xyz abc'

    it 'moves to the end of the line', ->
      type 'xyz abc'
      keyDown 36
      equal jqconsole.$prompt_right.text().trim(), 'xyz abc'
      keyDown 35
      equal jqconsole.$prompt_right.text().trim(), ''
      equal jqconsole.$prompt_left.text().trim(), 'xyz abc'

    it 'moves to the start of the prompt', ->
      type 'xyz abc'
      keyDown 13, shiftKey: on
      type 'hafm olim'
      keyDown 36, metaKey: on
      equal jqconsole.$prompt_right.text().trim(), 'xyz abc'
      equal jqconsole.$prompt_after.text().trim(), 'prompt_continuehafm olim'

    it 'moves to the end of the prompt', ->
      type 'xyz abc'
      keyDown 13, shiftKey: on
      type 'hafm olim'
      keyDown 36, metaKey: on
      equal jqconsole.$prompt_right.text().trim(), 'xyz abc'
      equal jqconsole.$prompt_after.text().trim(), 'prompt_continuehafm olim'
      keyDown 35, metaKey: on
      equal jqconsole.$prompt_left.text().trim(), 'hafm olim'
      equal jqconsole.$prompt_before.text().trim(), 'prompt_labelxyz abc'

    it 'moves up one line', ->
      type 'xyz'
      keyDown 13, shiftKey: on
      type 'a'
      keyDown 38, shiftKey: on
      equal jqconsole.$prompt_right.text().trim(), 'yz'

    it 'moves down one line', ->
      type 'xyz'
      keyDown 13, shiftKey: on
      type 'a'
      # Meta key also works.
      keyDown 38, metaKey: on
      equal jqconsole.$prompt_right.text().trim(), 'yz'
      keyDown 40, metaKey: on
      equal jqconsole.$prompt_right.text().trim(), ''

    it 'respects the column when moving vertically', ->
      type 'xyz'
      keyDown 13, shiftKey: on
      type 'ab'
      keyDown 38, shiftKey: on
      equal jqconsole.$prompt_right.text().trim(), 'z'
      keyDown 40, shiftKey: on
      keyDown 37
      keyDown 37
      equal jqconsole.$prompt_right.text().trim(), 'ab'
      keyDown 38, shiftKey: on
      equal jqconsole.$prompt_right.text().trim(), 'xyz'

    # We can't test this in control key because it needs to move the cursor.
    it 'deletes a char', ->
      type 'xyz'
      keyDown 37
      equal jqconsole.$prompt_right.text().trim(), 'z'
      keyDown 46
      equal jqconsole.$prompt_right.text().trim(), ''
    
    it 'deletes a word', ->
      type 'xyz abc'
      keyDown 37
      keyDown 37
      keyDown 37
      equal jqconsole.$prompt_right.text().trim(), 'abc'
      keyDown 46, metaKey: on
      equal jqconsole.$prompt_right.text().trim(), ''


