# unbound

Translator that directly implies removing limits, borders, and barriers.

## Overview

`unbound` is a small Flutter app that provides translation functionality with an emphasis on removing language barriers and making translations accessible and local-first where possible.

## Features

- On-device and cloud translation (depends on configured services)
- Language selector and history of recent translations
- Simple, accessible UI targeting mobile and desktop platforms supported by Flutter

## Prerequisites

- Flutter SDK (stable) — see https://flutter.dev/docs/get-started/install
- A connected device or emulator

## Getting started

1. Clone the repo:

```bash
git clone <your-repo-url>
cd unbound
```

2. Install dependencies:

```bash
flutter pub get
```

3. Run the app (on a connected device or emulator):

```bash
flutter run
```

4. Build a release (Android example):

```bash
flutter build apk --release
```

## Project structure

- `lib/` — application source code
- `android/`, `ios/`, `windows/`, `linux/`, `macos/`, `web/` — platform folders
- `test/` — widget and unit tests

## Contributing

Contributions are welcome. Please follow these steps:

1. Fork the repository and create a feature branch.
2. Add tests for new functionality where appropriate.
3. Open a pull request with a clear description of your changes.

## License

This project does not include a LICENSE file by default. Add a license (for example, MIT) to make the terms explicit before publishing.

---

If you'd like, I can also add a `LICENSE` file, CI workflow, or badges (build, coverage). Tell me which you'd prefer next.

