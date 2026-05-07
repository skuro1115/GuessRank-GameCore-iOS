# GuessRank — Claude Code Guide

## Documentation Structure
- Avoid duplication across docs files; each piece of information lives in exactly one place
- Organize docs at feature-level granularity, not by document type
- When scaffolding new docs, propose the structure first before creating files

## App Store Compliance
- Privacy policy must enumerate: data types collected, retention policy, third-party SDKs, contact info, children's data handling
- Generic templates fail Apple review — write project-specific copy reflecting actual app behavior
- Cross-check `docs/support.html` and the privacy policy whenever data collection or third-party integrations change

## Build & Test Verification
- After Swift/TypeScript changes, run the build and report compile errors before declaring done
- After changes to Models/Services/ViewModels, run `swift test` from `GuessRank/` and report failures before declaring done
- For Swift: verify Hashable/Equatable conformance when adding enums or structs used in Sets/Dicts
- Surface compilation errors proactively rather than waiting for the user to paste them
- SwiftUI Views are not unit-tested — when changes touch Views, explicitly tell the user that manual UI verification is required (passing `swift test` does not cover View behavior)

## Domain Terminology
- Use **ターゲット** (target) for the player whose preference is being guessed; never **出題者**
- Use **予想者** (guesser) for the players making predictions; never **回答者**
- These terms appear in Models, ViewModels, Views, and `docs/`. Renaming was committed in `6180f1c` — do not reintroduce the old terms

## Architecture Boundaries (MVVM)
- Flow is one-directional: `View → ViewModel (@Observable) → Service / Model`
- Views must not call Services or mutate Models directly — go through a ViewModel method
- Services are pure-logic; side effects (I/O, persistence) are isolated in dedicated `*Store` classes
- Persistence stores (`GameHistoryStore`, `TopicHistoryStore`, `TopicFeedbackStore`) accept an injectable directory for tests — never hard-code `FileManager.default` paths in new stores

## Codable Backwards Compatibility
- Existing user save data must remain readable after schema changes
- New fields on `GameConfig` / `Topic` / `GameSession` etc. must be optional with a sensible fallback (e.g., `playMode` defaults to `.normal` for legacy JSON)
- When adding a field, add a test that decodes a JSON snapshot missing that field

## Commit & PR Conventions
- Separate `refactor:` (no behavior change) from `feat:` (new behavior) into different commits — never mix
- Extract dependent refactors first (e.g., extending a protocol) before the feature commit that uses them
- PR descriptions must include three sections: **Summary** (what), **アーキテクチャ判断 / Architecture decisions** (non-obvious choices), **スキップ判断 / Out of scope** (what was deliberately not done and why)
- PR Test plan checkboxes should be marked `[x]` only after a human has verified — do not pre-check them in generated PR bodies
