"""Builds assets/mizo_words.txt: Mizo words for checking what players type
(Word Chain), taken from the Mizo definitions of J.F. Laldailova's
English–Lushai dictionary. Only the words are kept, accents folded
(the dictionary seldom marks them); no definitions go into the app.

    python3 -m venv /tmp/v && /tmp/v/bin/pip install openpyxl
    /tmp/v/bin/python tool/mizo_lexicon.py ~/Downloads/JF_Laldailova_Dictionary.xlsx
"""
import collections
import re
import sys
import unicodedata

import openpyxl

POS = re.compile(r'\b(n|v|v\.t|v\.i|adj|adv|prep|conj|pron|int|interj|pl|sing|abbr|pp|pt|p\.p|p\.t|fig|lit|colloq|esp|etc)\.', re.I)
WORD = re.compile(r"[A-Za-zÂÊÎÔÛâêîôûṬṭ]+")
# The Mizo alphabet: no c (but ch), no g (but ng), no j, q, x or y.
NOT_MIZO = re.compile(r'[cgjqxy]')
ENGLISH = set('or and of nn the them then that this with from for as at be is are was it its to into not no see also one '
              'make her his out put on up so do per an by etc ie eg sb sth us we he she you me my our your him has had have '
              'were will would shall should may might can could but if than too very more most such other same like used use '
              'usu esp form part kind sort way thing'.split())
ENGLISH_ENDINGS = re.compile(r'(ness|ment|tion|most|ed|ly)$')
FOLD = str.maketrans('âêîôûṭ', 'aeiout')


def main(path):
    sheet = openpyxl.load_workbook(path, read_only=True)['JF Dictionary']
    rows = [(str(r[0]), str(r[1] or '')) for r in sheet.iter_rows(min_row=2, values_only=True) if r[0]]
    headwords = {unicodedata.normalize('NFC', english.lower()) for english, _ in rows}
    counts = collections.Counter()
    for _, definition in rows:
        text = unicodedata.normalize('NFC', definition)
        text = re.sub(r'\([^)]*\)', ' ', text)  # pronunciation and notes
        text = POS.sub(' ', text)
        counts.update(word.lower() for word in WORD.findall(text))
    words = set()
    for word, count in counts.items():
        if len(word) < 2 or count < 2 or word in ENGLISH:
            continue
        if NOT_MIZO.search(word.replace('ch', '').replace('ng', '')):
            continue
        # An English headword seldom used in the definitions is English.
        if word in headwords and count < 5:
            continue
        if len(word) >= 7 and (ENGLISH_ENDINGS.search(word) or word.endswith('ian')):
            continue
        words.add(word.translate(FOLD))
    with open('assets/mizo_words.txt', 'w', encoding='utf-8') as out:
        out.write('\n'.join(sorted(words)) + '\n')
    print(len(words), 'words')


if __name__ == '__main__':
    main(sys.argv[1])
