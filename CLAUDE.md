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
- For Swift: verify Hashable/Equatable conformance when adding enums or structs used in Sets/Dicts
- Surface compilation errors proactively rather than waiting for the user to paste them
