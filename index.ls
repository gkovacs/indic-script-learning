J = $.jade

root = exports ? this

alphabets = {
  latin: ([\a to \z] ++ [\A to \Z]).join('')
}

aux_letters = {
  hindi: <[ ौ ै ा ी ू ो े ् ि ु ॆ ं ँ ॊ ृ ॉ ॅ ्र र् ज्ञ त्र क्ष श्र ः ]>
}

banned_letters = {
  hindi: [\a to \z] ++ [\A to \Z] ++ [\0 to \9] ++ <[ . , / - _ ? , . ^ ( ) : [ ] ' " { } ~ ` ]>
}

export playword = ->
  synthesize_word root.target_word

synthesize_word = (word) ->
  synth_lang = root.lang
  if synth_lang == 'ipa'
    synth_lang = 'en'
  if root.lang == 'hi' and aux_letters.hindi.indexOf(word) != -1
    word = root.current_word[*-1] + word
  if root.lang == 'ipa'
    word = root.hindi_to_english[word]
    if not word?
      return
  video_tag = $('video')
  if video_tag.length == 0
    video_tag = J('video').css({display: 'none'})
    $('body').append video_tag
  video_tag.attr 'src', 'http://speechsynth.herokuapp.com/speechsynth?' + $.param({lang: synth_lang, word})
  video_tag[0].currentTime = 0
  video_tag[0].play()

root.mistake_made = false

set_target_word = (target_word) ->
  english_word = target_word
  root.mistake_made = false
  if root.lang == 'hi' or root.lang == 'ipa'
    english_word = root.hindi_to_english[target_word]
  root.target_word = target_word
  root.current_word = []
  $('#inputarea').text ''
  $('#topword').css 'color', 'white'
  $.get '/image?' + $.param({name: english_word}), (data) ->
    $('#topword').text root.target_word
    $('#topword').css 'color', 'black'
    if root.lang == 'hi'
      $('#english_translation').text '(word meaning: ' + root.hindi_to_english[target_word] + ')'
    #$('#english_translation').text '(picture goes here)'
    #console.log data
    $('#imgdisplay').attr 'src', data
    setTimeout ->
      synthesize_word target_word
    , 100

word_finished = (finished_word) ->
  if can_spell_word(finished_word)
    if not root.mistake_made
      root.learned_words[finished_word] = true
  for letter in finished_word
    root.letters_practiced[letter] = true

can_spell_word = (word) ->
  output = true
  for letter in word
    if not root.letters_practiced[letter]?
      output = false
  return output

switch_word = ->
  word_finished root.target_word
  setTimeout ->
    set_target_word pick_word()
    if can_spell_word(root.target_word)
      $('#topword').css('visibility', 'hidden')
    else
      $('#topword').css('visibility', 'visible')
    highlight_next()
  , 1000

#pick_word = ->
#  word_idx = Math.random() * root.all_words.length |> Math.floor
#  return root.all_words[word_idx]

root.learned_words = {}

pick_word = ->
  for word in get_words_by_easiness()
    if not root.learned_words[word]?
      return word

root.current_word = []
root.letters_practiced = {}

get_next_letter = ->
  num_typed = root.current_word.length
  remaining = root.target_word[num_typed to]
  return remaining[0]

addLetter = (letter) ->
  #console.log letter
  if letter != get_next_letter()
  #  hide_all_letters()
  #  show_word_and_distractors()
    root.mistake_made = true
    $('#topword').css('visibility', 'visible')
    synthesize_word letter
    setTimeout ->
      highlight_letter get_next_letter()
    , 800
    return
  synthesize_word letter
  root.current_word.push letter
  partial_word = root.current_word.join('')
  $('#inputarea').text partial_word
  console.log partial_word
  if partial_word != letter
    setTimeout ->
      synthesize_word partial_word
    , 800
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
  #letters = Object.keys root.letter_frequencies
  letters = root.letters
  while true
    letter_idx = Math.random() * letters.length |> Math.floor
    letter = letters[letter_idx]
    if letter != orig_letter
      return letter

unhighlight_letters = ->
  $('.highlighted').removeClass('highlighted')

highlight_letter = (letter) ->
  unhighlight_letters()
  $('#let' + letter).addClass('highlighted')

show_word_and_distractors = ->
  next_letter = get_next_letter()
  #hide_all_letters()
  if not next_letter?
    switch_word()
    return
  show_letter next_letter
  unhighlight_letters()
  if not root.letters_practiced[next_letter]?
    highlight_letter next_letter
  #show_letter get_distractor(next_letter)

highlight_next = ->
  show_word_and_distractors()

new_word = ->
  hide_all_letters()
  console.log 'new word!'
  word = pick_word()
  #console.log Object.keys letter_frequencies
  #letters = Object.keys letter_frequencies
  #letters = (letters.sort (a, b) ->
  #  letter_frequencies[a] - letter_frequencies[b]).reverse()
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
  #return root.hindi_letters
  return root.letters

add_line_of_letters = (letters) ->
  curline = J('.keyline')
  for let letter in letters
    curline.append J('.button').text(letter).attr('txt', letter).attr('id', 'let' + letter).click ->
      addLetter letter
  $('#keyboard').append curline

#root.lang = 'hi'
root.lang = 'en'
#root.lang = 'ipa'

export getIPA = (word) ->
  ipa = ipadict_en[word.trim().toLowerCase()]
  if not ipa?
    if word.indexOf('-') != -1
      return [getIPA(x) for x in word.split('-')].join('-')
    return word
  return ipa

export getUrlParameters = ->
  url = window.location.href
  hash = url.lastIndexOf('#')
  if hash != -1
    url = url.slice(0, hash)
  map = {}
  parts = url.replace(/[?&]+([^=&]+)=([^&]*)/gi, (m,key,value) ->
    #map[key] = decodeURI(value).split('+').join(' ').split('%2C').join(',') # for whatever reason this seems necessary?
    map[key] = decodeURIComponent(value).split('+').join(' ') # for whatever reason this seems necessary?
  )
  return map

create_keyboard_ipa = (callback) ->
  ipadict_file = '/ipadict_en.json'
  if root.condition == '1'
    ipadict_file = '/ipadict_en_obf1.json'
  if root.condition == '2'
    ipadict_file = '/ipadict_en_obf2.json'
  $.getJSON ipadict_file, (data) ->
    root.ipadict_en = data
    root.letters = []
    letter_set = {}
    for k,v of data
      for letter in v
        if not letter_set[letter]?
          root.letters.push letter
          letter_set[letter] = true
    add_line_of_letters root.letters
    callback()


create_keyboard = (callback) ->
  #$.get '/inscript_keyboard.txt', (data) ->
  keyboard_file = '/inscript_keyboard.txt'
  if root.lang == 'en'
    keyboard_file = '/qwerty_keyboard.txt'
  if root.lang == 'ipa'
    return create_keyboard_ipa(callback)
  $.get keyboard_file, (data) ->
    lines = data.split('\n')
    lines = lines.map strip_comments
    #root.hindi_letters = []
    root.letters = []
    for line in lines
      letters = split_by_space line
      #root.hindi_letters = root.hindi_letters ++ letters
      root.letters = root.letters ++ letters
      add_line_of_letters letters
    callback()

get_hardness = (word) ->
  hardness = 0
  new_letters = {}
  for letter in word
    if not root.letters_practiced[letter]? and not new_letters[letter]?
      hardness += 1
      new_letters[letter] = true
  return hardness

get_words_by_easiness = ->
  words_by_easiness = root.all_words.sort (a, b) ->
    return get_hardness(a) - get_hardness(b)
  return words_by_easiness

root.condition = 0

$(document).ready ->
  params = getUrlParameters()
  if params.lang?
    root.lang = params.lang
    if params.lang == 'ipa1'
      root.lang = 'ipa'
      root.condition = '1'
    if params.lang == 'ipa2'
      root.lang = 'ipa'
      root.condition = '2'
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
    #$.get '/english_to_hindi.json', (english_to_hindi) ->
    $.get '/english_to_hindi_basic.json', (english_to_hindi) ->
      #console.log english_to_hindi
      root.english_to_hindi = english_to_hindi
      #root.hindi_words = hindi_words = []
      #root.english_words = english_words = []
      root.all_words = all_words = []
      root.letter_frequencies = letter_frequencies = {}
      root.hindi_to_english = hindi_to_english = {}
      for english,hindi of english_to_hindi
        if root.lang == 'ipa'
          hindi = getIPA(english)
        skip_word = false
        if root.lang == 'hi' or root.lang == 'ipa'
          for letter in hindi
            if root.letters.indexOf(letter) == -1
              skip_word = true
            #if banned_letters.hindi.indexOf(letter) != -1
            #  skip_word = true
          if skip_word
            continue
        #english_words.push english
        #hindi_words.push hindi
        if root.lang == 'hi' or root.lang == 'ipa'
          all_words.push hindi
        else
          all_words.push english
        for letter in hindi
          if not letter_frequencies[letter]?
            letter_frequencies[letter] = 0
          letter_frequencies[letter] += 1
        if not hindi_to_english[hindi]?
          hindi_to_english[hindi] = english
      #set_target_word 'हिन्दी'
      if root.lang == 'hi'
        #set_target_word 'बिल्ली'
        set_target_word pick_word()
      else
        set_target_word pick_word()
      #else
      #  set_target_word 'cat'
      new_word()
    #for letter in alphabets.latin
      #$('#content').append J('.button').text letter
