# Thumal Quest — Privacy & Child-Safety Data Inventory

**Version:** 0.10.0 / Phase 4A  
**Scope:** Current local-first app and planned V1  
**Status:** Product/engineering draft; legal review required before store launch

## 1. Default position

Thumal Quest is guest-first, offline-first and ads-free through V1. Data chu
zirna thawk thei tûr chauh khawn; child public identity, precise location,
contacts, advertising identifier or open communication a mamawh lo.

## 2. Current prototype inventory

| Data | Location | Purpose | Leaves device? | Delete path |
|---|---|---|:---:|---|
| XP | SharedPreferences | Progress | No | App data removal; in-app reset needed |
| Streak | SharedPreferences | Habit display | No | Same |
| Completed lesson/game IDs | SharedPreferences | Path/progress | No | Same |
| Daily progress | SharedPreferences | Daily goal | No | Same |
| Learning track | SharedPreferences | Content presentation | No | Same |
| Best score | SharedPreferences | Personal best | No | Same |
| TQ mastery/review schedule | SQLite/SharedPreferences fallback | Adaptive learning | No | Reset Local Progress |
| Content issue ID + predefined reason | SQLite/SharedPreferences fallback | Local editorial queue | No | Reset Local Progress |
| Mizo seed content | App bundle | Learning | No | App update/removal |
| Reviewed audio pack | App bundle/local files | Pronunciation learning | No | App update/removal |
| Anonymous learner test outcomes | Private field-work CSV | Usability/accessibility evidence | No automatic transfer | Delete after approved evidence-retention period |
| Journey node/collection IDs | SharedPreferences | Local story progression and rewards | No | Reset Local Progress |
| Daily action counters/streak grace | SharedPreferences | Gentle engagement and quest progress | No | Reset Local Progress |
| Culture-card/quest-claim IDs | SQLite/SharedPreferences fallback | Collection and duplicate-claim prevention | No | Reset Local Progress |
| Trail Marks/avatar style | SQLite/SharedPreferences fallback | Optional local visual identity | No | Reset Local Progress |
| Four-week cohort outcomes | Private field-work CSV | Engagement and age-fit validation | No automatic transfer | Delete after approved evidence-retention period |
| Gentle-engagement preference | SQLite/SharedPreferences fallback | Hide streak pressure and keep quests optional | No | Reset Local Progress |
| Reviewer/pilot evidence IDs | Repository validation files | Audit release readiness without names | No automatic transfer | Project evidence-retention policy |

Current source contains no account, remote analytics, ad SDK, microphone,
camera, location, contact or public chat feature. Audio is playback-only.
Platform projects generated later must be audited to confirm permissions and
privacy manifests.

Phase 2C learner rows use opaque session IDs and yes/no outcomes only. Names,
contact details, exact birth dates, participant voice/video and signed consent
documents must not be stored in the public project repository.

Phase 3A journey records are local counters and content IDs only. They do not
contain a learner's story choices, free text, location, contacts or social
activity. Comeback and streak-grace decisions are computed entirely on device.

Phase 3B keeps Trail Marks non-spendable and local. Cohort rows use opaque
participant IDs and aggregate yes/no outcomes; names, contacts, exact ages,
recordings and precise locations are excluded from the project.

Phase 3C adds only an on-device gentle-mode boolean. Reviewer and pilot-owner
identifiers in source must be opaque; the identity register, signed consent and
contact details stay in controlled organisational storage outside the project.

Update 2026-10-01: the Editorial Studio and its database are retired. Content
is edited in a Google Sheet owned by the project's content account and
published as a static content pack on GitHub Pages; there is no project server
or staff database any more. The paragraph below is kept for history.

Phase 4A adds an internal Editorial Studio database containing staff email,
password digest, minimum role, active status, content authorship/review records,
request IDs and append-only audit metadata. This operational data is not learner
data. The public content API exposes published content packs only. Phase 4A does
not collect learner accounts, progress, answers, voice, device identifiers or
analytics, and Flutter remains usable without the backend.

## 3. Planned V1 data

| Data | Required? | Default location | Retention proposal | Child treatment |
|---|:---:|---|---|---|
| Broad age band | Yes | Local DB | Until profile reset | No exact DOB |
| Proficiency/goal | Yes | Local DB | Until reset | Not public |
| Attempts/mastery | Yes | Local DB | Until reset/account delete | No raw free text export by default |
| Settings/accessibility | Yes | Local DB | Until reset | Local |
| Session snapshot | Temporary | Local DB | Delete after terminal + short recovery period | Encrypted by platform protections |
| Audio pack | Optional | Local files | Until user removes/pack retires | Content, not personal |
| Voice recording | Optional/later | Local only by default | Immediate/user-controlled deletion | Explicit contextual consent |
| Account email | Optional/later | Rails | Account life + policy period | Guardian/adult only for child sync |
| Sync pseudonymous ID | Optional/later | Local + Rails | Account life | Not public |
| Support report | Optional | Rails/local queue | Defined SLA then limited archive | Predefined category; contact not required |
| Aggregate analytics | Optional | Local first | Shortest useful period | No ad ID/free-form/voice |

## 4. Explicitly excluded for V1

- Advertising ID/IDFA/AAID
- Precise or background location
- Contacts/address book
- Public real name/photo/profile
- Public chat or free-form child posting
- Personalized advertising
- Sale/sharing of learner data for marketing
- Background microphone/camera
- Biometric or health data

## 5. Permissions

| Permission | V1 | Rule |
|---|:---:|---|
| Network | Yes | Content update/optional sync; core offline |
| Microphone | Later/optional | Ask only when learner taps Record |
| Camera | No | Reconsider only with separate privacy case |
| Photos/files | Avoid | System picker only for explicit adult export if needed |
| Precise location | No | No product need |
| Contacts | No | No product need |
| Notifications | Optional | Ask after value shown; quiet/guardian controls |
| Tracking/ad ID | No | Not requested |

## 6. Age experience and parental gate

- Ask broad experience band, not exact date of birth, unless legal/store review
  establishes a need.
- Mixed audience path must apply child-safe behavior to child/unknown users.
- External links, optional account, purchase and data export/delete in child
  experience require adult area/parental gate.
- Parental gate is not automatically legal parental consent; consent flow must
  be separately designed where personal data collection requires it.
- Child cannot be encouraged to lie about age.

## 7. SDK inventory gate

Before adding any package/SDK, record:

- Name, version and owner
- Purpose and whether essential
- Data collected/transmitted, endpoints and retention
- Child-directed service terms/eligibility
- Tracking/advertising behavior
- iOS privacy manifest and Android Data safety implications
- Disable/delete configuration
- Security/maintenance status
- Reviewer and review date

Current external runtime dependencies include `shared_preferences` and
`sqflite` for local device storage, plus `just_audio` for playback of reviewed
bundled assets. No recording API or analytics SDK is included. The resolved
Flutter/platform dependency tree must be generated and audited on a Mac before
final assessment.

## 8. Analytics proposal

Phase 0/1 default is local debug and aggregate counters. A third-party analytics
SDK is not added until privacy review.

Allowed event properties after review:

- app/content/game version
- broad experience/TQ level
- session terminal reason
- item ID/revision and correctness only if necessary
- hint use and duration bucket
- device platform/OS major where non-identifying

Never include:

- Free-form answer text from a child
- Raw audio recording
- Name, email or exact birthday
- Precise timestamp + device fingerprint combination beyond operational need
- Advertising identifier

## 9. Data lifecycle

### Local guest

- Create profile locally
- Write attempt/mastery transactionally
- Allow Reset Progress / Delete Local Profile
- Deletion clears DB, snapshots, downloaded personal settings and local IDs

### Optional account

- Adult/guardian creates account and chooses sync
- Explain what leaves device before upload
- Export and delete available
- Delete request removes active data and backups according to published schedule
- Local copy choice is explicit

### Support/content report

- Default predefined reason + content/session reference
- Optional text/contact in adult/guardian flow
- Status confirmation without exposing other reports
- Retain only as needed for correction/security record

## 10. Security controls

- TLS for network operations
- Platform secure storage for auth token
- No secrets/API keys in Flutter bundle
- Role-based Editorial Studio with MFA recommendation
- Audit content approvals and admin data actions
- Rate limit account/report endpoints
- Signed/checksummed content pack
- Backups encrypted and restore-tested
- Incident response owner and user notification process

## 11. Store and legal checklist

- [ ] Target audiences accurately declared in Google Play
- [ ] Google Play Families/data practices reviewed
- [ ] Apple Kids Category vs mixed-audience choice recorded
- [ ] App privacy details match SDK/runtime behavior
- [ ] COPPA applicability reviewed for U.S. under-13 users
- [ ] Japan APPI and other launch-market requirements reviewed
- [ ] Plain-English privacy policy and Mizo summary published
- [ ] Parent/guardian consent mechanism reviewed where required
- [ ] Account export/delete tested
- [ ] Support contact and incident route active

## 12. Current gaps

### Phase 4B audio and delivery data

- Editorial audio metadata stores a pseudonymous speaker code, dialect, recording date, consent-record reference and licence. It does not store a speaker name, contact details or the consent document itself.
- Audio bytes live in controlled disk/object storage and become public only through an approved immutable pack. Unpublished preview requires Editorial Studio authentication.
- Content/audio sync sends pack ETags and download requests only. It sends no learner name, age, answer, XP, progress, device identifier or raw learner recording.
- Removing already published audio requires an incident response and rollback; cached copies and retention obligations must be covered by the consent and deletion policy before a pilot.

### Phase 4C staging evidence

- Repository evidence uses pseudonymous operator, speaker, consent and review-decision references only; real names, emails, passwords, audio bytes and consent documents are prohibited.
- The public live smoke reads only health status and already-published immutable packs. It does not authenticate a learner or upload device/progress data.
- Live-smoke reports retain staging origin, pack versions/checksums, aggregate counts and UTC execution time for at most the operational evidence period.
- Deliberate corruption is staging-only, supervised and immediately restored; it must never target production or a bucket shared with learners.

- No platform manifest/permission audit because platform folders are generated
  on Mac
- No selected analytics/crash SDK; this is intentionally pending
- Editorial staff/audit retention schedule and access-review owner not yet approved
- No legal review or appointed data owner
- No tested parental gate
- Local content reports do not sync to an editorial service yet

These gaps block public child-targeted release, not local prototype use.
