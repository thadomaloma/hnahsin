# Phase 3A Story and Culture Review

Use `content/journey/phase3a_journey_manifest.json` as the release record. Do
not approve content from machine translation alone.

## Review roles

- **Language reviewer 1:** natural contemporary Mizo, spelling and grammar
- **Language reviewer 2:** learner clarity, diaspora accessibility and age fit
- **Culture reviewer:** context, representation and respectful explanation
- **Publisher:** confirms every required decision before changing pack status

One person may fill more than one role only when the project governance policy
explicitly permits it. Reviewers must record a stable reviewer ID and ISO-8601
date; private names/contact details stay outside the public repository.

## Story checklist

- Mizo dialogue sounds natural when read aloud
- English support preserves meaning instead of replacing Mizo structure
- Wrong replies are clearly wrong but never humiliating
- Target word IDs exist in the reviewed word corpus
- Culture note is factual, concise and understandable to diaspora learners
- Child reward is playful without being babyish
- Adult reward is dignified and not merely a renamed child badge
- No story makes payment, streak, currency or sharing necessary for learning
- Learner can stop safely after one story with progress saved

## Evidence rule

Set both review records to `approved` only after the review actually happened.
Then run:

```bash
python3 scripts/journey_release_gate.py --strict
```

The strict command must remain blocked while any reviewer, date or approval is
missing. A passing structural validator is not content approval.
