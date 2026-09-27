# Pilot Content Review Packet

**Source:** `pilot_candidates.csv` (100 words) and `pilot_sentences.csv` (40 sentences)
**Purpose:** Give a language reviewer and a culture reviewer a prioritized,
grouped worklist instead of 140 flat CSV rows. Every item below still needs
`language_review` and (where marked) `learning_review`/culture sign-off per
`docs/CONTENT_EDITORIAL_GUIDE.md`; nothing here is pre-approved.

**How to use this packet:** work group by group. Fill in "Reviewer decision"
(approve / change / reject) and "Approved form / sense" for each row. A
`reject` or `change` requires a note per the editorial guide (§Reviewer
decisions) — draft authors cannot self-approve.

68 of the 140 pilot items (47 words, 21 sentences) carry an explicit reviewer
flag and are listed here. The remaining 72 items (53 words, 19 sentences) have
no flag but are still unreviewed drafts — see `pilot_candidates.csv` /
`pilot_sentences.csv` directly for those.

---

## Words (47 flagged)

### A. Diacritics / display-spelling confirmation only (14)
No sense ambiguity — just confirm the canonical display form and accepted
input variants (with/without diacritics).

| ID | Form | TQ | Note | Reviewer decision | Approved form |
|---|---|---|---|---|---|
| word.chhungkua | Chhûngkua | TQ1 | Confirm preferred diacritics/display spelling | | |
| word.thian | Ṭhian | TQ0 | Confirm accepted input without diacritic | | |
| word.zirtirtu | Zirtîrtu | TQ1 | Confirm display spelling | | |
| word.chhanna | Chhânna | TQ1 | Confirm display spelling | | |
| word.kel | Kêl | TQ0 | Confirm display spelling | | |
| word.tlang | Tlâng | TQ0 | Confirm display spelling | | |
| word.par | Pâr | TQ0 | Confirm display spelling | | |
| word.tlan | Tlân | TQ0 | Confirm display spelling | | |
| word.tha | Ṭha | TQ0 | Confirm accepted input variant | | |
| word.naktuk | Naktûk | TQ0 | Confirm display spelling | | |
| word.zing | Zîng | TQ0 | Confirm display spelling | | |
| word.tlai | Tlâi | TQ0 | Confirm display spelling | | |
| word.zan | Zân | TQ0 | Confirm display spelling | | |
| word.zanin | Zanina | TQ1 | Canonical form decision: zanin/zanina | | |

### B. Spelling + sense together (2)
Both the display form and the intended sense need confirming.

| ID | Form | TQ | Note | Reviewer decision | Approved form | Approved sense |
|---|---|---|---|---|---|---|
| word.van | Vân | TQ1 | Confirm display spelling and sense | | | |
| word.chhun | Chhûn | TQ0 | Confirm display spelling and sense | | | |

### C. Sense / polysemy disambiguation (20)
These need a reviewer to pick and record the exact intended sense so the
gloss, examples and games don't mix meanings. Paired entries (`In`, `Ni`,
etc.) share a form with another pilot word — resolve both together.

| ID | Form | TQ | Note | Reviewer decision | Approved sense |
|---|---|---|---|---|---|
| word.in.house | In | TQ0 | Sense: house; distinguish from drink | | |
| word.in.drink | In | TQ0 | Sense: drink; distinguish from house | | |
| word.upa | Upa | TQ1 | Polysemy/title context | | |
| word.tawng | Tawng | TQ1 | Sense and part of speech review | | |
| word.ni.sun | Ni | TQ0 | Sense: sun; distinguish from day | | |
| word.thla.moon | Thla | TQ0 | Sense: moon; distinguish from month | | |
| word.ram | Ram | TQ0 | Multiple senses; define selected sense | | |
| word.thing | Thing | TQ0 | Sense: tree/wood; split if necessary | | |
| word.lo.come | Lo | TQ0 | Sense: come; distinguish from field/particle | | |
| word.ding | Ding | TQ0 | Polysemy review | | |
| word.tho.rise | Tho | TQ0 | Sense: rise/wake; distinguish senses | | |
| word.en | En | TQ0 | Sense selection required | | |
| word.la | La | TQ0 | Highly polysemous; context required | | |
| word.te.small | Tê | TQ0 | Sense: small; distinguish particle/plural marker | | |
| word.sang.high | Sâng | TQ1 | Sense: high/tall; review | | |
| word.chak | Chak | TQ0 | Polysemy review | | |
| word.chaw | Chaw | TQ0 | Sense: cooked rice/meal; review | | |
| word.sa.meat | Sa | TQ0 | Sense: meat; distinguish other senses | | |
| word.thingpui | Thingpui | TQ0 | Sense/register review | | |
| word.buh | Buh | TQ1 | Paddy/rice sense review | | |

### D. Grammatical form / inflection handling (2)
How the base form and inflected/imperative forms should be represented.

| ID | Form | TQ | Note | Reviewer decision | Approved form |
|---|---|---|---|---|---|
| word.ngaithla | Ngaithla | TQ1 | Imperative/base-form handling review | | |
| word.hria | Hria | TQ1 | Inflection/base-form handling review | | |

### E. Register / cultural note / child-safety (5)
Needs a language *and* culture reviewer, or an age-safety check.

| ID | Form | TQ | Note | Reviewer decision | Approved note |
|---|---|---|---|---|---|
| word.tlangval | Tlangval | TQ1 | Register/cultural note may be needed | | |
| word.nula | Nula | TQ1 | Definition/register needs careful review | | |
| word.sebong | Sebong | TQ0 | Meaning/register review | | |
| word.sual | Sual | TQ1 | Age-safe examples only | | |
| word.bai | Bai | TQ1 | Cultural description required | | |

### F. English gloss accuracy (1)

| ID | Form | TQ | Note | Reviewer decision | Approved gloss |
|---|---|---|---|---|---|
| word.bal | Bal | TQ1 | Exact English gloss review | | |

### G. Mandatory cultural/source review (3)
TQ2–TQ3 culture-category words — culture reviewer sign-off is required, not
optional, per `required_review_kinds` for this content type.

| ID | Form | TQ | Note | Reviewer decision | Approved note |
|---|---|---|---|---|---|
| word.tlawmngaihna | Tlawmngaihna | TQ3 | Cultural review mandatory | | |
| word.zawlbuk | Zawlbûk | TQ3 | Cultural/source review mandatory | | |
| word.thufing | Thufing | TQ2 | Source and definition review mandatory | | |

---

## Sentences (21 flagged)

### H. Content gap — linked word not yet in the pilot word list (11)
These sentences use a word form that has no matching entry in
`pilot_candidates.csv` under that form. Verified by cross-checking
`linked_candidate_ids` against the 100-word list — none of these 11 forms
exist there under any candidate ID. **Action needed before language review:**
either add the missing word as a new pilot candidate, or rewrite the sentence
to use only words already in the pilot set.

| Sentence ID | Text | Missing word | Note |
|---|---|---|---|
| sentence.004 | Naupang chu a nui. | nui | Candidate nui not yet in pilot list |
| sentence.008 | Mikhual chu inah a thleng. | thleng | Candidate thleng not yet in pilot list |
| sentence.011 | Lehkhabuah i hming ziak rawh. | hming | Candidate hming not yet in pilot list |
| sentence.015 | I chhânna chu a dik e. | dik | Candidate dik not yet in pilot list |
| sentence.019 | Sangha chu tuiah a awm. | awm | Candidate awm not yet in pilot list |
| sentence.020 | Sakei chu ramsa chak tak a ni. | ramsa | Candidate ramsa not yet in pilot list |
| sentence.021 | Ni chu a eng. | eng | Candidate eng not yet in pilot list |
| sentence.024 | Tlâng aṭangin lui kan hmu. | hmu | Candidate hmu not yet in pilot list |
| sentence.031 | I duh zâwng thlang rawh. | thlang | Candidate thlang not yet in pilot list |
| sentence.032 | He thil hi hmang rawh. | thil | Candidate thil not yet in pilot list |
| sentence.034 | Lehkhabu hi hetah dah rawh. | hetah | Candidate hetah not yet in pilot list |

### I. Linguistic / naturalness / grammar review (9)

| Sentence ID | Text | Note | Reviewer decision | Approved text |
|---|---|---|---|---|
| sentence.007 | Ka ṭhian nên kan zir dûn. | Confirm dûn spelling and naturalness | | |
| sentence.010 | Zirlaiin lehkhabu a chhiar. | Case/spacing review | | |
| sentence.014 | Zawhna hi chhâng rawh. | Verb form and linked sense review | | |
| sentence.018 | Sava chu thingah a thut. | Postposition/naturalness review | | |
| sentence.023 | Vânah arsi a awm. | Locative and singular/plural review | | |
| sentence.027 | Tho la, sikul kal rawh. | Tone/imperative naturalness review | | |
| sentence.030 | Ka thu sawi ngaithla rawh. | Naturalness review | | |
| sentence.038 | Thingpui leh chaw kan ei. | Verb choice/natural English support review | | |
| sentence.040 | Thufing hi chhiar la, a awmzia sawi rawh. | Grammar and terminology review | | |

### J. Mandatory cultural review (1)

| Sentence ID | Text | Note | Reviewer decision | Approved text |
|---|---|---|---|---|
| sentence.039 | Tlawmngaihna chu kan nunphung hlu tak a ni. | Cultural review and nuanced translation mandatory | | |

---

## Summary counts

| Group | Count |
|---|---|
| A — spelling only | 14 |
| B — spelling + sense | 2 |
| C — sense/polysemy | 20 |
| D — grammatical form | 2 |
| E — register/cultural note/safety | 5 |
| F — gloss accuracy | 1 |
| G — mandatory cultural/source | 3 |
| **Words total** | **47** |
| H — content gap (missing word) | 11 |
| I — linguistic/naturalness/grammar | 9 |
| J — mandatory cultural review | 1 |
| **Sentences total** | **21** |
| **Packet total** | **68** |

Unflagged remainder (72 items: 53 words + 19 sentences) still needs ordinary
`language_review`, but has no specific reviewer note attached.
