// Generated by LiveScript 1.3.1
(function(){
  var fs, levn, readEachLine, hindi_to_english, english_to_hindi, seen_newline, all_lines, i$, ref$, len$, line, parsed, english, pos, hindi, slice$ = [].slice;
  fs = require('fs');
  levn = require('levn');
  readEachLine = require('read-each-line');
  hindi_to_english = {};
  english_to_hindi = {};
  seen_newline = true;
  all_lines = fs.readFileSync('shabdanjali.utf8', 'utf8');
  for (i$ = 0, len$ = (ref$ = all_lines.split('\n')).length; i$ < len$; ++i$) {
    line = ref$[i$];
    line = line.trim();
    if (seen_newline) {
      parsed = levn.parse('[String]', line);
      english = parsed[0], pos = parsed[1], hindi = parsed[2];
      if (hindi == null || pos == null || english == null) {
        continue;
      }
      if ([hindi[0], hindi[1]].join('') === '1.') {
        hindi = slice$.call(hindi, 2).join('');
      }
      if (pos === 'N') {
        hindi_to_english[hindi] = english;
        english_to_hindi[english] = hindi;
      }
      seen_newline = false;
    }
    if (line === '') {
      seen_newline = true;
    }
  }
  fs.writeFileSync('hindi_to_english.json', JSON.stringify(hindi_to_english));
  fs.writeFileSync('english_to_hindi.json', JSON.stringify(english_to_hindi));
}).call(this);
