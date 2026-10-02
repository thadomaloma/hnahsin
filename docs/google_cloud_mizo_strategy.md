# Google Cloud and Mizo content strategy

Checked against official Google Cloud documentation on 13 September 2026.

## Verified platform support

- Cloud Translation Neural Machine Translation lists **Mizo** with code
  **`lus`**.
- Cloud Speech-to-Text does not currently list Mizo in its supported-language
  table.
- Cloud Text-to-Speech does not currently list a Mizo voice.

Sources:

- https://docs.cloud.google.com/translate/docs/languages
- https://docs.cloud.google.com/speech-to-text/docs/speech-to-text-supported-languages
- https://docs.cloud.google.com/text-to-speech/docs/list-voices-and-types

## Safe architecture

Cloud Translation is an API, not a downloadable authoritative Mizo dictionary.
Hnahsin therefore keeps canonical spelling, meaning, example, age level,
and cultural notes in a reviewed offline corpus.

```text
Flutter app -> authenticated app backend -> Cloud Translation (`lus`)
                                      |
                                      -> unapproved gloss suggestion
Human Mizo reviewer -> approve/edit -> versioned published content
```

The mobile client must never contain a service-account credential or an
unrestricted Google Cloud API key. Translation suggestions should be rate
limited, logged for editorial review, and treated as untrusted until approved.

## Content review states

- `prototypeChecked`: common seed wording judged suitable for prototyping, but
  not yet signed off by an appointed language reviewer.
- `reviewRequired`: culturally specific, older, polysemous, or otherwise
  sensitive content that needs educator approval before a public release.

For launch, even the `prototypeChecked` seed set should receive final sign-off from at
least two fluent Mizo reviewers, with one experienced in teaching children.
