# Phase 2C Field Playbook

## Non-negotiable rule

No fabricated evidence. A missing recording, consent, review or learner session
stays `PENDING`; it is never replaced by AI voice, assumed approval or a sample
row presented as a real participant.

## A. Native-speaker audio production

### Roles

- Recording coordinator: schedules speakers and controls asset IDs
- Native Mizo speaker: records approved text only
- Language reviewer: checks pronunciation against the locked transcript
- Audio reviewer: checks clarity, noise, pace and file mapping
- Publisher: verifies consent, licence, both reviews and checksums

The speaker, language reviewer and audio reviewer should not all be the same
person. A minor speaker requires guardian approval before recording.

### Workflow

1. Language reviewers approve and lock the ten transcripts.
2. Create a private consent record; put only its opaque ID in the manifest.
3. Record separate normal and natural slow takes as mono PCM WAV, 48 kHz,
   16-bit or 24-bit.
4. Name files exactly as listed in
   `content/audio/phase2c_audio_manifest.json`.
5. Copy approved candidates into `assets/audio/core_tq0/`.
6. Calculate SHA-256 values and update the manifest.
7. Record language and audio reviews with different reviewer IDs where
   practical.
8. Run the strict audio gate.
9. Only after it passes, update the Flutter clip records and add the audio
   directory to `pubspec.yaml`.

```bash
python3 scripts/audio_release_gate.py
python3 scripts/audio_release_gate.py --strict
```

The first command reports progress and remains usable while production is
pending. The strict command blocks release until every requirement passes.

## B. Learner validation

### Priority segments

Use at least ten completed sessions in each group:

- `early_5_7`: ages 5–7 with guardian consent
- `young_8_13_diaspora`: ages 8–13, including diaspora beginners
- `heritage_teen_adult`: teen/adult heritage or returning learners

The CSV stores no name, email, voice, birthday or device identifier. Use an
opaque session ID such as `L26-001`. Guardian consent is required for `early`
and `young` age bands.

### One session

1. Explain that the app—not the learner—is being tested.
2. Confirm consent and the right to stop.
3. Ask the learner to find and start the first lesson without help.
4. Observe one correct and one incorrect-feedback path.
5. Play Listen & Pick with normal audio, slow replay and transcript.
6. Complete one Sentence Builder round.
7. Close and resume a saved session.
8. Ask the learner to find a safe exit/back action.
9. In designated sessions, test VoiceOver and 200% text.
10. Record yes/no outcomes only in
    `validation/phase2c/learner_sessions.csv`.

### Pass thresholds

- Ten valid sessions per segment: 30 total minimum
- First lesson found unassisted: at least 80%
- Next action found after feedback: at least 90%
- Safe exit: 100%
- Listen & Pick and Sentence Builder completion: at least 80% each
- No critical usability, accessibility or child-safety blocker
- Two VoiceOver and two 200%-text evidence sessions per segment

```bash
python3 scripts/learner_validation_gate.py
python3 scripts/learner_validation_gate.py --strict
```

## C. Phase exit

Run the complete technical gate on the Mac:

```bash
./run_mac.command check
```

Phase 2C can be marked complete only when Mac check, strict audio gate and
strict learner gate all pass, and the product owner records the reviewer names,
date and remaining non-blocking observations.
