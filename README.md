# PromptForge

A local-first Flutter application for advanced prompt engineering, context pack management, and multi-LLM output comparison.

## Overview

PromptForge is designed to support the entire prompt engineering workflow entirely on your local machine. From capturing raw ideas in the inbox, to managing dynamic variables and metadata, compiling prompts with context packs, and finally comparing outputs from multiple LLMs, PromptForge provides a cohesive local-first experience.

### Local-First Design
All data is stored locally on your device. There is no mandatory cloud synchronization, ensuring your prompts, sensitive context, and API configurations remain private.

## Core Features

- **Prompt Library**: Full CRUD operations with tags, favorites, searching, filtering, and sorting.
- **Prompt Inbox**: Quickly capture prompt ideas and later convert them into full prompts.
- **Context Packs**: Manage reusable contextual knowledge that can be injected into any prompt.
- **Prompt Variables & Metadata**: Define dynamic variables inside your prompts and attach structured metadata.
- **Prompt Compiler**: Combine prompts with context packs and variable substitutions to generate the final output.
- **Prompt Examples**: Save and manage test cases and examples for specific prompts.
- **Multi-LLM Output Comparison**: Compare generated outputs side-by-side using different LLM models.
- **Import/Export v0**: Export your entire vault data to a JSON file or import it to sync between local instances.

## Validation and Supported Platforms

- **Linux Desktop**: Actively validated and supported.
- **Other Platforms (Android, iOS, Windows, macOS)**: Architecturally compatible but pending explicit device/emulator validation.

## Known Limitations

Please see [KNOWN_LIMITATIONS.md](docs/KNOWN_LIMITATIONS.md) for details on current missing features or design limitations.

## Getting Started

### Prerequisites
- Flutter SDK (latest stable)
- Dart SDK
- Linux build requirements (if running on Linux)

### Setup Commands

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### Validation Commands

```bash
flutter analyze
flutter test
flutter run -d linux
```

## Roadmap

Upcoming features include prompt and context pack version history, polished file-based import/export, exported comparisons, saved filter views, and AI-assisted prompt improvement.
