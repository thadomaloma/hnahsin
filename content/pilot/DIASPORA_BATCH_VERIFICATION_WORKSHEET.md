# Diaspora Batch — Native Speaker Verification Worksheet

**Source:** `diaspora_expansion_candidates.csv` (83 AI-drafted words, 2026-09-16)
**Purpose:** Give one native Mizo speaker a focused, sit-down worksheet to (A)
confirm/correct the 17 flagged draft words, and (B) elicit the next ~70-120
words needed to reach the project's 250-300 dataset target — without any more
AI guessing. Expect **45-75 minutes** total for one speaker working through
both sections.

**What happens after:** Corrected/added words still go through the normal
two-reviewer pipeline in `docs/CONTENT_EDITORIAL_GUIDE.md` (language reviewer
+ culture reviewer where noted) before anything here is release-ready. This
worksheet does not skip that gate — it just gives the reviewers accurate raw
material instead of unverified AI guesses.

**How to fill this in:** Write directly in this file (or a copy of it), or
call it in as a screen-share/voice conversation and have someone else
transcribe the answers into this file's blank columns. Either works.

---

## Section A — Confirm or correct the 17 flagged words

For each row: is the Mizo word correct as written? If not, what's the right
word/spelling? Is the English meaning right?

### A1. Numbers (confirm exact spoken/written form)

| Draft form | Meant to mean | Question | Correct form (if different) | Notes |
|---|---|---|---|---|
| Sawmkhat | Eleven (11) | Is this how 11 is actually said/written, or is it usually just described as "sawm leh khat" (ten and one)? | | |
| Sawmhnih | Twenty (20) | Is this the right compound, or "sawm hnih" as two words? | | |
| Za | One hundred (100) | Does "za" stand alone for 100, or does it need a number before it (e.g. "za khat")? | | |

### A2. Colors

| Draft form | Meant to mean | Question | Correct form (if different) | Notes |
|---|---|---|---|---|
| Hring | Green | Is "hring" natural for the color green, or does it read as "raw/unripe/alive" to a listener? What word would a Mizo speaker actually use for green? | | |
| Lieng | Blue | Is this the right word/spelling for blue? | | |
| Eng | Yellow | This one is likely wrong — "eng" usually means light/shine. What's the actual word for yellow? | | |

### A3. Body

| Draft form | Meant to mean | Question | Correct form (if different) | Notes |
|---|---|---|---|---|
| Kam | Mouth | Is this the standard word for mouth? | | |

### A4. Feelings

| Draft form | Meant to mean | Question | Correct form (if different) | Notes |
|---|---|---|---|---|
| Thinur | Angry | Is the spelling right? Is this the word a parent/kid would actually use, or too formal/literary? | | |
| Chau | Tired | Is this the standard word for physically tired? | | |

### A5. Family

| Draft form | Meant to mean | Question | Correct form (if different) | Notes |
|---|---|---|---|---|
| U | Older sibling | Is "u" ever used standalone as a headword, or only attached (e.g. "u-pa", "ka u")? How should this display/search in an app? | | |
| Tu | Grandchild | Is this right, or does "tu" only make sense as part of a longer word? What's the clean standalone word for grandchild? | | |
| Makpa | Son-in-law | Is this the correct term? | | |
| Monu | Daughter-in-law | Is this the correct term? | | |

### A6. Time / nature / animals / home

| Draft form | Meant to mean | Question | Correct form (if different) | Notes |
|---|---|---|---|---|
| Kar | Week / interval | Does "kar" mean "week," or is it a more generic "gap/interval" that needs another word for a 7-day week? | | |
| Vur | Cloud | Is the spelling right? | | |
| Sakawr | Horse | Is the spelling right? | | |
| Dar | Clock / bell | Does "dar" alone mean clock, or bell, or a generic word for metal/instrument that needs a qualifier? | | |

---

## Section B — Fill in more words (closing the gap toward 250-300)

No need to translate anything from English — just write down the Mizo words
your family/community actually uses for each prompt, plus a short English
meaning. Skip any row that doesn't feel natural; better to leave it blank
than force a word.

### B1. Days of the week (deliberately skipped in the AI draft — genuine gap)

| Mizo day name | English day | Notes (is this actually used in daily speech, or mostly English day names?) |
|---|---|---|
| | Sunday | |
| | Monday | |
| | Tuesday | |
| | Wednesday | |
| | Thursday | |
| | Friday | |
| | Saturday | |

### B2. Months (if there are traditional Mizo month names still in common use)

| Mizo month name | Roughly which month | Still commonly used? |
|---|---|---|
| | | |
| | | |
| | | |

### B3. More household objects / clothing

| Mizo word | English meaning | Category note |
|---|---|---|
| | | |
| | | |
| | | |
| | | |
| | | |

### B4. More food / dishes (beyond bekang, sawhchiar, vawksa, arsa, hmarcha)

| Mizo word | English meaning | Notes |
|---|---|---|
| | | |
| | | |
| | | |
| | | |

### B5. More greetings / everyday phrases (single words or short set phrases)

| Mizo word/phrase | English meaning | When is it used? |
|---|---|---|
| | | |
| | | |
| | | |

### B6. More feelings

| Mizo word | English meaning | |
|---|---|---|
| | | |
| | | |
| | | |

### B7. Extended family terms (aunts/uncles/cousins — Mizo kinship terms are often more specific than English)

| Mizo word | English meaning (as close as possible) | |
|---|---|---|
| | | |
| | | |
| | | |
| | | |

### B8. Common everyday verbs not yet covered

| Mizo word | English meaning | |
|---|---|---|
| | | |
| | | |
| | | |
| | | |

### B9. One or two short Tawng Upa (proverbs/sayings) suitable for kids — for the Tawng Upa game

| Mizo proverb | Rough meaning | Age-appropriate? |
|---|---|---|
| | | |
| | | |

---

## After this worksheet is filled in

1. Whoever collects the answers adds them to `content/pilot/pilot_candidates.csv`
   (or a new batch file) in the same format: `candidate_id, canonical_form,
   seed_category, tq_level, status=draft, language_review=pending,
   learning_review=pending, audio_status=planned, notes`.
2. Flag `bekang`, `sawhchiar`, `puan`, and `Mizo` (identity term) for the
   **culture reviewer** specifically, not just the language reviewer, per
   `docs/CONTENT_EDITORIAL_GUIDE.md`.
3. Normal two-reviewer sign-off proceeds exactly as it does for the existing
   100-word pilot set — nothing here is release-ready until that happens.
