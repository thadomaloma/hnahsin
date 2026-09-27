# -*- coding: utf-8 -*-
import csv, os

ROOT = os.path.expanduser("~/mnt/Thumal Quest")
INC = os.path.join(ROOT, "content/pilot/kumtluang/_deepen_2026-09")

sources = [
    ('Class I', 'class1_new_rows.csv'),
    ('Class II', 'class2_new_rows.csv'),
    ('Class III', 'class3_new_rows.csv'),
    ('Class IV', 'class4_new_rows.csv'),
    ('Class V', 'class5_new_rows.csv'),
    ('Class VI', 'class6_new_rows.csv'),
    ('Class VII', 'class7_new_rows.csv'),
    ('Vartian', 'vartian_candidates.csv'),
]

all_rows = []
for label, fn in sources:
    with open(os.path.join(INC, fn), encoding='utf-8') as f:
        for row in csv.DictReader(f):
            row['_grade_label'] = label
            all_rows.append(row)

def esc(s):
    return (s or '').replace('|', '\\|').replace('\n', ' ').strip()

culture = [r for r in all_rows if 'culture-sensitive' in (r.get('notes') or '').lower()]
other_verify = [r for r in all_rows if 'VERIFY' in (r.get('notes') or '') and r not in culture
                 and 'VERIFY possible duplicate' not in (r.get('notes') or '')
                 and 'VERIFY spelling-variant' not in (r.get('notes') or '')]
dedup_flags = [r for r in all_rows if 'VERIFY possible duplicate' in (r.get('notes') or '')
               or 'VERIFY spelling-variant' in (r.get('notes') or '')]

# pull the headhunting-reference row out to the very top, on its own
ral_lu_aih = [r for r in culture if 'ral_lu_aih' in r.get('candidate_id','') or 'ralluaih' in r.get('candidate_id','')]
culture_rest = [r for r in culture if r not in ral_lu_aih]

def table(rows, note_key='notes'):
    lines = ["| ID | Word | Grade | Gloss (draft) | Concern | Reviewer decision | Approved form/sense |",
             "|---|---|---|---|---|---|---|"]
    for r in rows:
        concern = esc(r.get(note_key,''))
        lines.append(f"| {esc(r['candidate_id'])} | {esc(r['canonical_form'])} | {esc(r['tq_level'])} | {esc(r['english_gloss'])} | {concern} | | |")
    return "\n".join(lines)

out = []
out.append("# Kumtluang deeper-extraction + Vartian: Review Packet Addendum")
out.append("_Generated 2026-09-18. Companion to `REVIEW_PACKET_KUMTLUANG_DIASPORA.md`, which "
            "covers the first-pass 2026-09-16 extraction. This addendum covers only the "
            "**net-new** rows added by the 2026-09-17/18 deeper re-read of all 7 Kumtluang "
            "grade books plus the new Vartian literacy-primer source — 718 new candidate rows "
            "total (876 extracted, 158 dropped as exact duplicates of already-catalogued words)._")
out.append("")
out.append("**How to use this packet:** same process as the other review packets — work group "
           "by group, fill in \"Reviewer decision\" (approve / change / reject) and \"Approved "
           "form/sense\" per `docs/CONTENT_EDITORIAL_GUIDE.md`. `meaning_mizo`/`example_mizo` "
           "are not shown here to keep tables scannable — check the source CSV for those.")
out.append("")
out.append("**Priority order:** the single flagged item right below this line first, then "
           "Section A (culture-sensitive) to a culture reviewer, then Sections B and C to a "
           "language reviewer in parallel.")
out.append("")
out.append("---")
out.append("")
out.append("## ⚠️ Highest-priority single item")
out.append("")
out.append("The Class VII deeper pass surfaced one term flagged by the extracting agent itself "
           "as **\"the single most sensitive item found\"**: a historical reference to "
           "headhunting / war-trophy celebration custom. It is catalogued here exactly like "
           "every other draft candidate — **not approved, not imported into gameplay, not "
           "reviewed** — but given the subject matter it deserves the reviewer's judgment before "
           "anything else in this packet, including a conscious decision on whether it belongs "
           "in a children's language-learning app at all (with careful historical framing) or "
           "should be rejected outright.")
out.append("")
out.append(table(ral_lu_aih))
out.append("")
out.append("---")
out.append("")
out.append(f"## A. Culture-sensitive terms ({len(culture_rest)})")
out.append("Traditional chieftainship, warrior/pasaltha culture, khuavang spirit-folklore, "
           "wrestling and zawlbûk customs, marriage/festival customs, musical instruments, and "
           "death/mourning-related terms. Route to a culture reviewer, not resolved by AI "
           "guesswork.")
out.append("")
out.append(table(culture_rest))
out.append("")
out.append(f"## B. Other VERIFY terms — uncertain spelling/sense ({len(other_verify)})")
out.append("Sense inferred from context rather than explicitly defined in the source book, or "
           "spelling uncertain from the scanned image. Language reviewer.")
out.append("")
out.append(table(other_verify))
out.append("")
out.append(f"## C. Possible-duplicate / spelling-variant flags ({len(dedup_flags)})")
out.append("Added automatically during the 2026-09-18 merge: each of these matched an "
           "**already-catalogued** word except for a diacritic (e.g. new `lam` vs. existing "
           "`lâm`), or matched **another new word from this same batch** except for a diacritic. "
           "Diacritics can distinguish genuinely different Mizo words, so these were kept as "
           "separate candidates rather than silently merged or dropped — a language reviewer "
           "needs to say, for each one, whether it's the same word (in which case the newer row "
           "should be rejected/merged) or a genuinely distinct word (approve both).")
out.append("")
out.append(table(dedup_flags))
out.append("")
out.append("## Everything else in this batch")
out.append(f"The remaining {len(all_rows) - len(culture) - len(other_verify) - len(dedup_flags)} "
           "of the 718 new rows carry no VERIFY flag and follow the same low-risk pattern as the "
           "rest of the pilot catalogue (concrete nouns, common verbs/adjectives, numbers, "
           "everyday vocabulary) — still draft status and still needs an ordinary language-review "
           "pass before shipping, just not flagged as needing special escalation.")
out.append("")
out.append("## Not covered by this packet")
out.append("- The first-pass 2026-09-16 Kumtluang extraction and the diaspora expansion list — "
           "see `REVIEW_PACKET_KUMTLUANG_DIASPORA.md`.")
out.append("- The original 100-word/40-sentence pilot set — see `REVIEW_PACKET.md`.")
out.append("- `content/pilot/thufing_candidates.csv` (10 proverbs) — still untouched, still "
           "needs both language AND culture review before any use in gameplay.")

with open(os.path.join(ROOT, "content/pilot/REVIEW_PACKET_DEEPEN_2026-09.md"), 'w', encoding='utf-8') as f:
    f.write("\n".join(out) + "\n")

print(f"Written. culture={len(culture)} (incl. {len(ral_lu_aih)} headhunting-term rows), other_verify={len(other_verify)}, dedup_flags={len(dedup_flags)}, total_rows={len(all_rows)}")
