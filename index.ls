J = $.jade

root = exports ? this

alphabets = {
  latin: ([\a to \z] ++ [\A to \Z]).join('')
}

pick_word = ->
  word_idx = Math.random() * root.hindi_words.length |> Math.floor
  return root.hindi_words[word_idx]

new_word = ->
  console.log 'new word!'
  word = pick_word()
  console.log letter_frequencies

$(document).ready ->
  #$('#content').text 'hello world 2'
  #console.log 'foobar'
  $.get '/english_to_hindi_basic.json', (english_to_hindi) ->
    #console.log english_to_hindi
    root.hindi_words = hindi_words = []
    root.english_words = english_words = []
    root.letter_frequencies = letter_frequencies = {}
    root.hindi_to_english = hindi_to_english = {}
    for english,hindi of english_to_hindi
      english_words.push english
      hindi_words.push hindi
      for letter in hindi
        if not letter_frequencies[letter]?
          letter_frequencies[letter] = 0
        letter_frequencies[letter] += 1
      hindi_to_english[hindi] = english
    new_word()
  #for letter in alphabets.latin
    #$('#content').append J('.button').text letter
