require! {
  fs
  'js-yaml'
}

#basic_english = fs.readFileSync 'basic_english_uppercase.txt', 'utf8'
basic_english = fs.readFileSync 'specific_english_nouns.txt', 'utf8'
english_to_hindi = fs.readFileSync('english_to_hindi.json', 'utf8') |> JSON.parse

english_to_hindi_basic = {}
for word in basic_english.split('\n')
  word = word.trim()
  word = word.toLowerCase()
  if word.indexOf('. ') != -1
    word = word.split('. ')[1]
  hindi = english_to_hindi[word]
  if hindi?
    if hindi.indexOf('/') != -1
      continue
    if hindi.indexOf('_') != -1
      continue
    if hindi.indexOf('[') != -1
      continue
    if hindi.indexOf('-') != -1
      continue
    english_to_hindi_basic[word] = hindi

fs.writeFileSync 'english_to_hindi_basic.yaml', js-yaml.safeDump(english_to_hindi_basic)
fs.writeFileSync 'english_to_hindi_basic.json', JSON.stringify(english_to_hindi_basic)
