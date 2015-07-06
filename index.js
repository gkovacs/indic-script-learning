// Generated by LiveScript 1.3.1
(function(){
  var J, root, alphabets, aux_letters, banned_letters, playword, synthesize_word, set_target_word, word_finished, can_spell_word, switch_word, pick_word, get_next_letter, addLetter, hide_all_letters, show_letter, get_distractor, unhighlight_letters, highlight_letter, show_word_and_distractors, highlight_next, new_word, strip_comments, split_by_space, get_letters, add_line_of_letters, getIPA, getUrlParameters, create_keyboard_ipa, create_keyboard, get_hardness, get_words_by_easiness, out$ = typeof exports != 'undefined' && exports || this, slice$ = [].slice;
  J = $.jade;
  root = typeof exports != 'undefined' && exports !== null ? exports : this;
  alphabets = {
    latin: (["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"].concat(["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"])).join('')
  };
  aux_letters = {
    hindi: ['ौ', 'ै', 'ा', 'ी', 'ू', 'ो', 'े', '्', 'ि', 'ु', 'ॆ', 'ं', 'ँ', 'ॊ', 'ृ', 'ॉ', 'ॅ', '्र', 'र्', 'ज्ञ', 'त्र', 'क्ष', 'श्र', 'ः']
  };
  banned_letters = {
    hindi: ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"].concat(["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"], ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"], ['.', ',', '/', '-', '_', '?', ',', '.', '^', '(', ')', ':', '[', ']', '\'', '"', '{', '}', '~', '`'])
  };
  out$.playword = playword = function(){
    return synthesize_word(root.target_word);
  };
  synthesize_word = function(word){
    var synth_lang, ref$, video_tag;
    synth_lang = root.lang;
    if (synth_lang === 'ipa') {
      synth_lang = 'en';
    }
    if (root.lang === 'hi' && aux_letters.hindi.indexOf(word) !== -1) {
      word = (ref$ = root.current_word)[ref$.length - 1] + word;
    }
    if (root.lang === 'ipa') {
      word = root.hindi_to_english[word];
      if (word == null) {
        return;
      }
    }
    video_tag = $('video');
    if (video_tag.length === 0) {
      video_tag = J('video').css({
        display: 'none'
      });
      $('body').append(video_tag);
    }
    video_tag.attr('src', 'http://speechsynth.herokuapp.com/speechsynth?' + $.param({
      lang: synth_lang,
      word: word
    }));
    video_tag[0].currentTime = 0;
    return video_tag[0].play();
  };
  root.mistake_made = false;
  set_target_word = function(target_word){
    var english_word;
    english_word = target_word;
    root.mistake_made = false;
    if (root.lang === 'hi' || root.lang === 'ipa') {
      english_word = root.hindi_to_english[target_word];
    }
    root.target_word = target_word;
    root.current_word = [];
    $('#inputarea').text('');
    $('#topword').css('color', 'white');
    return $.get('/image?' + $.param({
      name: english_word
    }), function(data){
      $('#topword').text(root.target_word);
      $('#topword').css('color', 'black');
      if (root.lang === 'hi') {
        $('#english_translation').text('(word meaning: ' + root.hindi_to_english[target_word] + ')');
      }
      $('#imgdisplay').attr('src', data);
      return setTimeout(function(){
        return synthesize_word(target_word);
      }, 100);
    });
  };
  word_finished = function(finished_word){
    var i$, len$, letter, results$ = [];
    if (can_spell_word(finished_word)) {
      if (!root.mistake_made) {
        root.learned_words[finished_word] = true;
      }
    }
    for (i$ = 0, len$ = finished_word.length; i$ < len$; ++i$) {
      letter = finished_word[i$];
      results$.push(root.letters_practiced[letter] = true);
    }
    return results$;
  };
  can_spell_word = function(word){
    var i$, len$, letter;
    for (i$ = 0, len$ = word.length; i$ < len$; ++i$) {
      letter = word[i$];
      if (root.letters_practiced[letter] == null) {
        return false;
      }
    }
    return true;
  };
  switch_word = function(){
    word_finished(root.target_word);
    return setTimeout(function(){
      set_target_word(pick_word());
      if (can_spell_word(root.target_word)) {
        $('#topword').css('visibility', 'hidden');
      } else {
        $('#topword').css('visibility', 'visible');
      }
      return highlight_next();
    }, 1000);
  };
  root.learned_words = {};
  pick_word = function(){
    var params, i$, ref$, len$, word;
    params = getUrlParameters();
    if (params.word != null) {
      return params.word;
    }
    for (i$ = 0, len$ = (ref$ = get_words_by_easiness()).length; i$ < len$; ++i$) {
      word = ref$[i$];
      if (root.learned_words[word] == null) {
        return word;
      }
    }
  };
  root.current_word = [];
  root.letters_practiced = {};
  get_next_letter = function(){
    var num_typed, remaining;
    num_typed = root.current_word.length;
    remaining = slice$.call(root.target_word, num_typed);
    return remaining[0];
  };
  addLetter = function(letter){
    var partial_word;
    if (letter !== get_next_letter()) {
      root.mistake_made = true;
      $('#topword').css('visibility', 'visible');
      synthesize_word(letter);
      setTimeout(function(){
        return highlight_letter(get_next_letter());
      }, 800);
      return;
    }
    synthesize_word(letter);
    root.current_word.push(letter);
    partial_word = root.current_word.join('');
    $('#inputarea').text(partial_word);
    console.log(partial_word);
    if (partial_word !== letter) {
      setTimeout(function(){
        return synthesize_word(partial_word);
      }, 800);
    }
    return highlight_next();
  };
  hide_all_letters = function(){
    var i$, ref$, len$, x, results$ = [];
    for (i$ = 0, len$ = (ref$ = $('.button')).length; i$ < len$; ++i$) {
      x = ref$[i$];
      results$.push($(x).css('visibility', 'hidden'));
    }
    return results$;
  };
  show_letter = function(letter){
    var button;
    button = $('#let' + letter);
    return button.css('visibility', 'visible');
  };
  get_distractor = function(orig_letter){
    var letters, letter_idx, letter;
    letters = root.letters;
    for (;;) {
      letter_idx = Math.floor(
      Math.random() * letters.length);
      letter = letters[letter_idx];
      if (letter !== orig_letter) {
        return letter;
      }
    }
  };
  unhighlight_letters = function(){
    return $('.highlighted').removeClass('highlighted');
  };
  highlight_letter = function(letter){
    unhighlight_letters();
    return $('#let' + letter).addClass('highlighted');
  };
  show_word_and_distractors = function(){
    var next_letter;
    next_letter = get_next_letter();
    if (next_letter == null) {
      switch_word();
      return;
    }
    show_letter(next_letter);
    unhighlight_letters();
    if (root.letters_practiced[next_letter] == null) {
      return highlight_letter(next_letter);
    }
  };
  highlight_next = function(){
    return show_word_and_distractors();
  };
  new_word = function(){
    hide_all_letters();
    console.log('new word!');
    return highlight_next();
  };
  strip_comments = function(line){
    var hash_idx;
    hash_idx = line.indexOf('#');
    if (hash_idx === -1) {
      return line;
    }
    return line.substring(0, hash_idx);
  };
  split_by_space = function(line){
    return line.split(' ').filter(function(c){
      return c !== ' ' && c !== '';
    });
  };
  get_letters = function(){
    return root.letters;
  };
  add_line_of_letters = function(letters){
    var curline, i$, len$;
    curline = J('.keyline');
    for (i$ = 0, len$ = letters.length; i$ < len$; ++i$) {
      (fn$.call(this, letters[i$]));
    }
    return $('#keyboard').append(curline);
    function fn$(letter){
      curline.append(J('.button').text(letter).attr('txt', letter).attr('id', 'let' + letter).click(function(){
        return addLetter(letter);
      }));
    }
  };
  root.lang = 'en';
  out$.getIPA = getIPA = function(word){
    var ipa, x;
    ipa = ipadict_en[word.trim().toLowerCase()];
    if (ipa == null) {
      if (word.indexOf('-') !== -1) {
        return (function(){
          var i$, ref$, len$, results$ = [];
          for (i$ = 0, len$ = (ref$ = word.split('-')).length; i$ < len$; ++i$) {
            x = ref$[i$];
            results$.push(getIPA(x));
          }
          return results$;
        }()).join('-');
      }
      return word;
    }
    return ipa;
  };
  out$.getUrlParameters = getUrlParameters = function(){
    var url, hash, map, parts;
    url = window.location.href;
    hash = url.lastIndexOf('#');
    if (hash !== -1) {
      url = url.slice(0, hash);
    }
    map = {};
    parts = url.replace(/[?&]+([^=&]+)=([^&]*)/gi, function(m, key, value){
      return map[key] = decodeURIComponent(value).split('+').join(' ');
    });
    return map;
  };
  create_keyboard_ipa = function(callback){
    var ipadict_file;
    ipadict_file = '/ipadict_en.json';
    if (root.condition === '1') {
      ipadict_file = '/ipadict_en_obf1.json';
    }
    if (root.condition === '2') {
      ipadict_file = '/ipadict_en_obf2.json';
    }
    return $.getJSON(ipadict_file, function(data){
      var letter_set, k, v, i$, len$, letter;
      root.ipadict_en = data;
      root.letters = [];
      letter_set = {};
      for (k in data) {
        v = data[k];
        for (i$ = 0, len$ = v.length; i$ < len$; ++i$) {
          letter = v[i$];
          if (letter_set[letter] == null) {
            root.letters.push(letter);
            letter_set[letter] = true;
          }
        }
      }
      add_line_of_letters(root.letters);
      return callback();
    });
  };
  create_keyboard = function(callback){
    var keyboard_file;
    keyboard_file = '/inscript_keyboard.txt';
    if (root.lang === 'en') {
      keyboard_file = '/qwerty_keyboard.txt';
    }
    if (root.lang === 'ipa') {
      return create_keyboard_ipa(callback);
    }
    return $.get(keyboard_file, function(data){
      var lines, i$, len$, line, letters;
      lines = data.split('\n');
      lines = lines.map(strip_comments);
      root.letters = [];
      for (i$ = 0, len$ = lines.length; i$ < len$; ++i$) {
        line = lines[i$];
        letters = split_by_space(line);
        root.letters = root.letters.concat(letters);
        add_line_of_letters(letters);
      }
      return callback();
    });
  };
  get_hardness = function(word){
    var hardness, new_letters, i$, len$, letter;
    hardness = 0;
    new_letters = {};
    for (i$ = 0, len$ = word.length; i$ < len$; ++i$) {
      letter = word[i$];
      if (root.letters_practiced[letter] == null && new_letters[letter] == null) {
        hardness += 1;
        new_letters[letter] = true;
      }
    }
    return hardness;
  };
  get_words_by_easiness = function(){
    var words_by_easiness;
    words_by_easiness = root.all_words.sort(function(a, b){
      return get_hardness(a) - get_hardness(b);
    });
    return words_by_easiness;
  };
  root.condition = 0;
  $(document).ready(function(){
    var params;
    params = getUrlParameters();
    if (params.lang != null) {
      root.lang = params.lang;
      if (params.lang === 'ipa1') {
        root.lang = 'ipa';
        root.condition = '1';
      }
      if (params.lang === 'ipa2') {
        root.lang = 'ipa';
        root.condition = '2';
      }
    }
    /*
    $.get '/devanagari_letters.yaml', (yamldata) ->
      hindi_letters_to_english = jsyaml.safeLoad yamldata
      hindi_letters = Object.keys hindi_letters_to_english
      console.log hindi_letters
      for letter in hindi_letters
        $('#keyboard').append J('.button').text(letter)
    */
    return create_keyboard(function(){
      return $.get('/english_to_hindi_basic.json', function(english_to_hindi){
        var all_words, letter_frequencies, hindi_to_english, english, hindi, skip_word, i$, len$, letter;
        root.english_to_hindi = english_to_hindi;
        root.all_words = all_words = [];
        root.letter_frequencies = letter_frequencies = {};
        root.hindi_to_english = hindi_to_english = {};
        for (english in english_to_hindi) {
          hindi = english_to_hindi[english];
          if (root.lang === 'ipa') {
            hindi = getIPA(english);
          }
          if (root.lang === 'en') {
            hindi = english;
          }
          skip_word = false;
          if (root.lang === 'hi' || root.lang === 'ipa') {
            for (i$ = 0, len$ = hindi.length; i$ < len$; ++i$) {
              letter = hindi[i$];
              if (root.letters.indexOf(letter) === -1) {
                skip_word = true;
              }
            }
            if (skip_word) {
              continue;
            }
          }
          if (root.lang === 'hi' || root.lang === 'ipa') {
            all_words.push(hindi);
          } else {
            all_words.push(english);
          }
          for (i$ = 0, len$ = hindi.length; i$ < len$; ++i$) {
            letter = hindi[i$];
            if (letter_frequencies[letter] == null) {
              letter_frequencies[letter] = 0;
            }
            letter_frequencies[letter] += 1;
          }
          if (hindi_to_english[hindi] == null) {
            hindi_to_english[hindi] = english;
          }
        }
        if (params.word != null) {
          set_target_word(params.word);
        } else if (root.lang === 'hi') {
          set_target_word(pick_word());
        } else {
          set_target_word(pick_word());
        }
        return new_word();
      });
    });
  });
}).call(this);
