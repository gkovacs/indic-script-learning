J = $.jade

root = exports ? this

alphabets = {
  latin: ([\a to \z] ++ [\A to \Z]).join('')
}

banned_letters = {
  hindi: [\a to \z] ++ [\A to \Z] ++ [\0 to \9] ++ <[ . , / - _ ? , . ^ ( ) : [ ] ' " { } ~ ` ]>
}

synthesize_word = (word) ->
  video_tag = $('video')
  if video_tag.length == 0
    video_tag = J('video').css({display: 'none'})
    $('body').append video_tag
  video_tag.attr 'src', 'http://speechsynth.herokuapp.com/speechsynth?' + $.param({lang: 'hi', word})
  video_tag[0].currentTime = 0
  video_tag[0].play()

set_target_word = (target_word) ->
  root.target_word = target_word
  $('#topword').text root.target_word
  root.current_word = []
  $('#inputarea').text ''
  $('#english_translation').text '(word meaning: ' + root.hindi_to_english[target_word] + ')'

switch_word = ->
  set_target_word pick_word()
  highlight_next()

pick_word = ->
  word_idx = Math.random() * root.hindi_words.length |> Math.floor
  return root.hindi_words[word_idx]

root.current_word = []

get_next_letter = ->
  num_typed = root.current_word.length
  remaining = root.target_word[num_typed to]
  return remaining[0]

addLetter = (letter) ->
  #console.log letter
  if letter != get_next_letter()
    hide_all_letters()
    show_word_and_distractors()
    return
  root.current_word.push letter
  partial_word = root.current_word.join('')
  $('#inputarea').text partial_word
  console.log partial_word
  synthesize_word letter
  setTimeout ->
    synthesize_word partial_word
  , 600
  highlight_next()

hide_all_letters = ->
  for x in $('.button')
    #$(x).text ''
    $(x).css 'visibility', 'hidden'

show_letter = (letter) ->
  button = $('#let' + letter)
  #button.text button.attr('txt')
  button.css 'visibility', 'visible'

get_distractor = (orig_letter) ->
  letters = Object.keys root.letter_frequencies
  while true
    letter_idx = Math.random() * letters.length |> Math.floor
    letter = letters[letter_idx]
    if letter != orig_letter
      return letter

highlight_letter = (letter) ->
  $('.highlighted').removeClass('highlighted')
  $('#let' + next_letter).addClass('highlighted')

show_word_and_distractors = ->
  next_letter = get_next_letter()
  #hide_all_letters()
  if not next_letter?
    switch_word()
    return
  show_letter next_letter
  show_letter get_distractor(next_letter)

highlight_next = ->
  show_word_and_distractors()

new_word = ->
  hide_all_letters()
  console.log 'new word!'
  word = pick_word()
  #console.log Object.keys letter_frequencies
  letters = Object.keys letter_frequencies
  letters = (letters.sort (a, b) ->
    letter_frequencies[a] - letter_frequencies[b]).reverse()
  #console.log letters
  highlight_next()

strip_comments = (line) ->
  hash_idx = line.indexOf '#'
  if hash_idx == -1
    return line
  return line.substring 0, hash_idx

split_by_space = (line) ->
  return line.split(' ').filter((c) -> c != ' ' and c != '')

get_letters = ->
  return root.hindi_letters

add_line_of_letters = (letters) ->
  curline = J('.keyline')
  for let letter in letters
    curline.append J('.button').text(letter).attr('txt', letter).attr('id', 'let' + letter).click ->
      addLetter letter
  $('#keyboard').append curline

create_keyboard = (callback) ->
  $.get '/inscript_keyboard.txt', (data) ->
    lines = data.split('\n')
    lines = lines.map strip_comments
    root.hindi_letters = []
    for line in lines
      letters = split_by_space line
      root.hindi_letters = root.hindi_letters ++ letters
      add_line_of_letters letters
    callback()

$(document).ready ->
  #$('#content').text 'hello world 2'
  #console.log 'foobar'
  /*
  $.get '/devanagari_letters.yaml', (yamldata) ->
    hindi_letters_to_english = jsyaml.safeLoad yamldata
    hindi_letters = Object.keys hindi_letters_to_english
    console.log hindi_letters
    for letter in hindi_letters
      $('#keyboard').append J('.button').text(letter)
  */

  #$.get '/english_to_hindi_basic.json', (english_to_hindi) ->
  create_keyboard ->
    $.get '/english_to_hindi.json', (english_to_hindi) ->
      #console.log english_to_hindi
      root.english_to_hindi = english_to_hindi
      root.hindi_words = hindi_words = []
      root.english_words = english_words = []
      root.letter_frequencies = letter_frequencies = {}
      root.hindi_to_english = hindi_to_english = {}
      for english,hindi of english_to_hindi
        skip_word = false
        for letter in hindi
          if banned_letters.hindi.indexOf(letter) != -1
            skip_word = true
        if skip_word
          continue
        english_words.push english
        hindi_words.push hindi
        for letter in hindi
          if not letter_frequencies[letter]?
            letter_frequencies[letter] = 0
          letter_frequencies[letter] += 1
        if not hindi_to_english[hindi]?
          hindi_to_english[hindi] = english
      #set_target_word 'हिन्दी'
      set_target_word 'बिल्ली'
      new_word()_
    #for letter in alphabets.latin
      #$('#content').append J('.button').text letter
