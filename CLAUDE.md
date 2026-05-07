# GuessRank — Claude Code Guide

## Documentation Structure
- Avoid duplication across docs files; each piece of information lives in exactly one place
- Organize docs at feature-level granularity, not by document type
- When scaffolding new docs, propose the structure first before creating files

## App Store Compliance
- Privacy policy must enumerate: data types collected, retention policy, third-party SDKs, contact info, children's data handling
- Generic templates fail Apple review — write project-specific copy reflecting actual app behavior
- Cross-check `docs/support.html` and the privacy policy whenever data collection or third-party integrations change
