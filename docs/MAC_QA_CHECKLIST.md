# Phase 1C Mac QA Checklist

Use one row per Mac verification run. Do not mark Phase 1 complete from source
inspection alone.

## A. Automated gate

```bash
chmod +x run_mac.command scripts/collect_mac_diagnostics.sh
./run_mac.command check
```

| Check | Pass evidence |
|---|---|
| Flutter/Xcode/CocoaPods | No preflight `ERROR` |
| Host projects | `android/`, `ios/`, `macos/`, `web/` created |
| Content/architecture | All phase validators print `PASS` |
| Source parse | Dart formatter/parser exits successfully without rewriting files |
| Analyze | `No issues found` or successful analyzer exit |
| Tests | All Flutter tests pass |
| macOS native build | Debug `.app` build completes |
| Structured evidence | `validation/phase3c/mac_verification.json` records all checks passed |
| Final marker | `PHASE 3C TECHNICAL CHECK PASSED` |

Record:

```text
Date:
Mac model / chip:
macOS:
Flutter:
Xcode:
Result: PASS / FAIL
Failure marker, if any:
```

## B. Launch and persistence smoke test

Run `./run_mac.command`, complete onboarding, then test:

- Home, Learn, Games and Profile navigation
- Picture Match, Spelling, Word Search, Word Chain, Tawng Upa and Crossword
- Listen & Pick normal/slow/transcript paths and Sentence Builder
- Open Mizo Journey, complete Coming Home and verify its culture card/reward
- Confirm River Walk remains locked until its prerequisite and TQ level pass
- Force-close after a completed story and verify map/collection persistence
- Check daily quest progress, one-day streak grace and gentle comeback copy
- Confirm the story completion page provides a healthy stopping point
- Open Culture Trail, read/collect a TQ0 card and verify its daily quest
- Claim one completed quest twice and confirm Trail Marks increase once only
- Confirm TQ1/TQ2 Culture Cards remain locked at TQ0
- Open My Collection, select an unlocked avatar and restart the app
- Confirm Chapchar Kut Trail says `NO DEADLINE` and remains archive-accessible
- Toggle Gentle engagement and confirm streak numbers/pressure copy stay hidden
- Confirm optional quests say `NO PENALTY` and `NO DEADLINE` in gentle mode
- Relaxed, Standard and Timed mode at least once each
- Use a hint and confirm the reduced score behavior
- Leave each game mid-round, close/reopen the app and resume exact state
- Finish a game and confirm XP is awarded once only
- Reset Local Progress and confirm first-run state returns

## C. Accessibility gate

- macOS Settings → Accessibility → VoiceOver: complete onboarding and one game
- macOS Settings → Accessibility → Display → Text size: test the largest useful size
- Confirm every actionable control has an understandable spoken label
- Confirm no essential content is clipped and scrolling still works
- Confirm correct/incorrect feedback is not communicated by color alone
- Confirm Timed Mode is optional and Relaxed Mode remains fully usable

## D. Thirty-minute stability gate

During one continuous 30-minute session:

1. Play all eight games, including Listen & Pick and Sentence Builder.
2. Complete and replay each available Story Quest; confirm rewards do not duplicate.
3. Force-close once in every game after at least one interaction.
4. Resume and compare visible state, score, hearts, hint and timer.
5. Repeat a completed result flow and confirm XP is not duplicated.
6. Record any crash, freeze, lost state, clipped layout or unclear Mizo wording.

Pass requires zero blocker/crash/data-loss issue. Language issues enter the Mizo
review queue and must not be silently corrected from machine translation.

## E. Failure handoff

If any automated step fails:

```bash
./run_mac.command report
```

Send `hnahsin_diagnostics.txt` with the last visible `ERROR:` line. Review
the report first if the Mac's computer name should remain private.
