# Known Limitations

As of Stage 12, the following limitations exist in the PromptForge app:

## General
- **No Cloud Sync**: Data is strictly local. Syncing across devices requires manual JSON export/import.
- **No Built-in Authentication**: The app is designed for local single-user access without auth.
- **Cross-Platform Verification**: Only Linux Desktop has been visually validated. Mobile and Web targets may have layout issues that haven't been caught yet.

## Features
- **Version History**: There is no automatic versioning or history tracking for prompts or context packs. Overwriting a prompt is destructive.
- **API Key Management**: Integration with actual LLM endpoints is limited or mocked; a robust and secure API key manager is not yet implemented.
- **Import/Export**: The current JSON import/export is a v0 implementation. It does not handle conflict resolution intelligently (it may duplicate or aggressively overwrite data depending on implementation).
- **Search Capabilities**: Search is currently basic text matching and does not use semantic search or embeddings.

## AI Integrations
- **No AI Assistance**: Prompt optimization, auto-tagging, or AI-generated context packs are not yet part of the core product.
