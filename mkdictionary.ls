require! {
  fs
  levn
  'read-each-line'
}

hindi_to_english = {}
english_to_hindi = {}

seen_newline = true
all_lines = fs.readFileSync 'shabdanjali.utf8', 'utf8'
for line in all_lines.split('\n')
  line = line.trim()
  if seen_newline
    parsed = levn.parse '[String]', line
    [english,pos,hindi] = parsed
    if not hindi? or not pos? or not english?
      continue
    if hindi[0 to 1].join('') == '1.'
      hindi = hindi[2 to].join('')
    if pos == 'N'
      hindi_to_english[hindi] = english
      english_to_hindi[english] = hindi
    seen_newline = false
  if line == ''
    seen_newline = true

fs.writeFileSync 'hindi_to_english.json', JSON.stringify(hindi_to_english)
fs.writeFileSync 'english_to_hindi.json', JSON.stringify(english_to_hindi)

