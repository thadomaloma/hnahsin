# Phase 3B Four-Week Engagement Playbook

## No fabricated evidence

Do not prefill successful outcomes, duplicate one learner under several IDs or
convert assumptions into evidence. Empty evidence must remain visibly pending.

## Cohort

Recruit at least five participants in each segment:

- `early_5_7` — guardian consent required
- `diaspora_8_17` — guardian consent required for this study contract
- `adult_heritage` — adults learning or refreshing Mizo

Use opaque participant IDs. Do not store names, email, phone, exact birth date,
voice/video, account ID or precise location in the CSV. Signed consent stays in
private organisational storage.

## Procedure

Create four weekly rows for every enrolled participant, including a zero-session
row if they did not return. This avoids silently removing dropouts. Weeks 1–3
record whether the learner returned the following week; week 4 uses `na`.

Each active week, record:

- session/story/culture-card counts
- whether repetition still felt acceptable
- whether the healthy stopping point was understood
- whether the reward felt suitable for the learner's age
- whether the learner felt pressure from streaks, quests or seasonal content
- whether core learning remained available without Trail Marks
- critical blockers and selected accessibility coverage

## Exit thresholds

- Five participants per segment; four weekly rows each (15 people / 60 rows)
- At least 60% voluntary next-week return
- At least 90% acceptable-repetition and healthy-stop results
- At least 80% age-fit reward results
- 100% no-pressure and core-learning-unblocked results among active rows
- Zero critical blockers
- Two screen-reader and two 200%-text evidence rows per segment

Run a non-blocking progress report while collecting evidence:

```bash
python3 scripts/engagement_validation_gate.py
```

Run the authoritative gate only for Phase 3 exit review:

```bash
python3 scripts/engagement_validation_gate.py --strict
```
