# Phase 2C — Audio Production & Learner Validation

**Build:** 0.7.1+14  
**Date:** 13 September 2026  
**Status:** **OPERATIONAL TOOLKIT IMPLEMENTED — EVIDENCE COLLECTION PENDING**

## Outcome

The project now has a reproducible field-to-release path for authentic Mizo
audio and privacy-minimal learner testing. Structural checks can pass while
work is in progress, but strict release commands return failure until real
files and evidence satisfy every exit threshold.

## Delivered

| Capability | Implementation |
|---|---|
| Audio production manifest | Ten canonical TQ0/TQ1 clip rows with normal/slow paths, checksums, consent, licence and two review records |
| Technical audio QA | PCM WAV parsing, mono/48 kHz/16–24 bit/duration checks and SHA-256 verification |
| Release safety | Strict gate blocks missing files, metadata, consent, reviews, hashes or published status |
| Dart safety | Duplicate clip/content detection and publication-blocker report |
| Consent handoff | Private-record template with adult/minor and withdrawal fields |
| Review log | Separate language, audio and publisher decisions |
| Learner scorecard | Anonymous yes/no evidence contract; no names, contact, exact DOB or recordings |
| Learner exit gate | Segment sample size, completion, comprehension, safe exit and accessibility thresholds |
| Mac/CI integration | Phase 2C structural validator in standard verification flow |

## Evidence snapshot

| Gate | Current evidence | Status |
|---|---:|---|
| Reviewed native clips | 0/10 | Pending |
| Valid learner sessions | 0/30 minimum | Pending |
| VoiceOver sessions | 0/6 minimum | Pending |
| 200% text sessions | 0/6 minimum | Pending |
| Mac build 0.7.1+14 | Not run in preparation environment | Pending |

These are accurate zeros, not missing-value pass conditions.

## Commands

Progress reports that do not fail merely because field work is pending:

```bash
python3 scripts/audio_release_gate.py
python3 scripts/learner_validation_gate.py
```

Authoritative release blockers:

```bash
python3 scripts/audio_release_gate.py --strict
python3 scripts/learner_validation_gate.py --strict
./run_mac.command check
```

## Remaining human work

- Recruit native Mizo speaker(s) and two qualified reviewers
- Approve the locked transcripts before recording
- Complete consent outside the public repository
- Record and review ten normal plus ten slow clips
- Run at least thirty valid learner sessions across three priority segments
- Close every critical usability/accessibility finding
- Run Flutter analyze, tests and macOS native build on the verified Mac

Phase 3A may be designed in parallel, but Phase 2 cannot claim its release exit
gate until all three strict checks pass.
