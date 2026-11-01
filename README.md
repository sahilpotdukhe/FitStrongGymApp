# FitStrong — Gym Manager

The owner's app for running a gym from a phone: members, plans, renewals,
billing, attendance and daily follow-ups.

It is the main app of a three-part system. Members are added here and given a
QR check-in code; the front desk scans that code with a second app; both apps
read the same rules from a shared package, so they can never disagree about
who is allowed in.

| Repo | What it is |
| --- | --- |
| **FitStrong — Gym Manager** (this one) | The owner's app: members, money, reports |
| [FitStrong Check-In](https://github.com/sahilpotdukhe/FitStrong-Check-In) | The front desk scanner that reads member QR codes |
| [fitstrong_core](https://github.com/sahilpotdukhe/fitstrong_core) | Shared rules and record shapes both apps depend on |

---

## What it does

**Members**
- Add a member with their photo, measurements, plan and assigned trainer.
- Every member gets a QR check-in code, shareable straight to WhatsApp as a
  printed-style card. A lost or passed-around code can be revoked and reissued.
- Deleted members go to a recycle bin rather than vanishing, and can be
  restored. Emptying the bin also clears their photos from storage.
- Export the whole member list to CSV.

**Plans and renewals**
- Create plans in months, days, or both, with a fee.
- A plan nobody is on can be deleted. A plan in use cannot — it is hidden
  instead, so members on it and their past invoices keep the right name.
- Renewals can be **backdated**, which is the normal case when a member kept
  training and paid later: they are charged from the day their last term
  ended. The app warns if a backdated term would still end in the past.

**Payment due window**
- A member whose plan has run out is still let in for 7 days while they settle
  up, shown as **Payment due** rather than Expired. After that the scanner
  turns them away. The window lives in
  [`CheckinRules.paymentGraceDays`](https://github.com/sahilpotdukhe/fitstrong_core).

**Billing**
- Every payment raises a numbered invoice (`INV-0001`, `INV-0002`, …) from a
  counter kept in a transaction, so two bills can never share a number.
- Invoices are saved, not just printed: they survive a member being edited or
  deleted, and reprint identically months later.
- Print as PDF or send on WhatsApp. UPI QR code shown at the till for online
  payment.
- Revenue screen with all-time, this-year and this-month totals, filterable by
  month and searchable by member.

**Attendance**
- Arrivals recorded by the scanner app show up here, with per-member history
  and insights on quiet and busy times.

**Daily follow-ups**
- A reminders screen and a morning notification covering birthdays,
  memberships about to run out, and ones that just lapsed — each with a
  ready-written WhatsApp message.

**Also** — trainers, BMI calculator, member search, light and dark themes, and
a gym profile with logo and signature that appear on invoices.

---

## Requirements

- Flutter **3.47.7** or newer (stable), Dart SDK `>=3.2.6 <4.0.0`
- A Firebase project (Auth + Firestore)
- A Supabase project (member photo storage)
- Android Studio or Xcode for device builds

---

## Setup

```bash
git clone https://github.com/sahilpotdukhe/FitStrongGymApp.git && cd FitStrongGymApp
```

```bash
cp env/dev.json.example env/dev.json
```

Then open `env/dev.json` and put in your real Supabase URL and anon key. This
file is gitignored and the app refuses to start without it.

```bash
flutter pub get
```

Firebase config (`android/app/google-services.json`) is already committed, so
there is nothing to generate. The app is registered in the **fitstrong-gym**
Firebase project as `com.fitstrong.app`.

---

## Everyday commands

Every run and build needs `--dart-define-from-file=env/dev.json`. Without it
the app stops at startup with a message saying exactly that.

| Task | Command |
| --- | --- |
| Run on a connected device | `flutter run --dart-define-from-file=env/dev.json` |
| Run all tests | `flutter test` |
| Run one test file | `flutter test test/member_model_test.dart` |
| Static analysis | `flutter analyze lib test` |
| Format | `dart format lib test` |
| Refresh dependencies | `flutter pub get` |
| Clear a bad build | `flutter clean && flutter pub get` |
| List connected devices | `flutter devices` |

Run the app on a device:

```bash
flutter run --dart-define-from-file=env/dev.json
```

Run the full test suite:

```bash
flutter test
```

Check for analyzer problems:

```bash
flutter analyze lib test
```

---

## Release builds

### One-time: signing key — not optional

Release builds here are deliberately **not** debug-signed, and a release build
**stops** if no key is set up:

```
No signing key, so this release would be unsigned and could not be installed
on any device.
```

That guard is there because Android on its own does not stop. It writes
unsigned APKs, Flutter prints its ticks, and the problem only shows up when
somebody tries to install one — by which time the build has been sent out.

Debug builds need no key and are unaffected.

Create the key once (keep the file somewhere safe and backed up — losing it
means you can never update the app on Play again):

```bash
keytool -genkey -v -keystore ~/fitstrong-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Then create `android/key.properties` (gitignored):

```properties
storePassword=yourStorePassword
keyPassword=yourKeyPassword
keyAlias=upload
storeFile=/Users/you/fitstrong-upload.jks
```

**Use this same keystore for the scanner app too.** One key signs both: they
have different package names, so they never collide, and it is one file to
back up instead of two. The scanner needs its own `android/key.properties`
pointing at the same `.jks`.

### Check a build really is signed

Worth running after any release build, because an unsigned one looks fine
until somebody tries to install it:

```bash
$(ls ~/Library/Android/sdk/build-tools/*/apksigner | tail -1) verify --print-certs build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

A signed APK prints its certificate. An unsigned one says `DOES NOT VERIFY`.

### APK split per ABI (recommended for direct sharing)

One APK per phone architecture, each carrying native code for one chip
family instead of all three. That makes each one meaningfully smaller than a
universal APK — on the scanner app, which builds from the same setup, it is
36 MB universal against 26 MB for arm64.

```bash
flutter build apk --release --split-per-abi --dart-define-from-file=env/dev.json
```

Output lands in `build/app/outputs/flutter-apk/`:

| File | Install on |
| --- | --- |
| `app-arm64-v8a-release.apk` | Almost every phone from 2016 onward — **send this one** |
| `app-armeabi-v7a-release.apk` | Older 32-bit phones |
| `app-x86_64-release.apk` | Emulators and a few Intel tablets |

If you are not sure what someone has, send `arm64-v8a` first; it covers
virtually all real devices today.

### Universal APK (one file that installs anywhere)

Bigger, but you never have to ask what phone they have:

```bash
flutter build apk --release --dart-define-from-file=env/dev.json
```

### Play Store bundle

Google Play wants an `.aab`, not an APK — it does the per-device splitting
itself:

```bash
flutter build appbundle --release --dart-define-from-file=env/dev.json
```

### iOS — not set up

The app is Android-only today. The iOS folder still carries Flutter's
template bundle identifier (`com.example.fitstrongGym`), and the Firebase
project has no iOS app registered for it, so an iOS build would start without
a usable Firebase configuration.

To add iOS later: set a real bundle identifier in Xcode, register that
identifier as an iOS app in the **fitstrong-gym** Firebase project, and drop
the `GoogleService-Info.plist` it gives you into `ios/Runner/`.

### Bumping the version

Edit `version:` in `pubspec.yaml` — `2.1.0+3` means version name `2.1.0`,
build number `3`. Play rejects an upload whose build number is not higher
than the last one.

---

## Installing on a phone

A release APK built as above installs normally. Two things are worth knowing:

**Uninstall any older build first.** Android refuses to install an APK signed
with a different key over one already on the phone. Debug builds (anything
from `flutter run`) are signed with the shared Android debug key, release
builds with the upload key, so the first release install on any phone you
have ever developed on will be rejected. Over USB the reason is explicit:

```
INSTALL_FAILED_UPDATE_INCOMPATIBLE: Existing package com.fitstrong.app
signatures do not match newer version; ignoring!
```

Through Firebase App Distribution or a file manager you get only a blunt
*"App not installed"*, with nothing saying why.

**The trap is that the old build can be invisible.** Android keeps the package
record and its signature even after the app has been removed for your user, so
it is gone from the launcher and from the app list while still blocking the
install. `adb shell dumpsys package com.fitstrong.app` shows it as
`installed=false` with a `DEBUGGABLE` flag and a `codePath` still on disk.

Clearing it takes one command, and loses nothing — such a record has no app
data behind it (`dataDir=null`), and the real data lives in Firestore:

```bash
adb uninstall com.fitstrong.app
```

Then install normally. This is a one-time step per phone; once everything
is on the same key, release updates install straight over the top.

**Play Protect may ask once.** Any app installed outside the Play Store can
raise a *"scan this app?"* or *"unknown developer"* prompt, because Google has
never seen the signing key before. That is sideloading itself, not a fault in
the build — signing properly is what keeps it to a prompt rather than a block.
Allowing it once is enough, and nothing needs to be switched off. Publishing
through Play is the only way to remove the prompt entirely.

Both apps are built against the current Android SDK (`targetSdk 36`) and run
on Android 7.0 and newer (`minSdk 24`), so neither hits the "built for an
older version of Android" refusal.

## How the data is stored

Everything hangs off the signed-in owner's user document, so one Firebase
project can hold many gyms without them ever seeing each other:

```
Users/{uid}
├── lastInvoiceNumber        the invoice counter
├── members/{memberId}
├── recyclebin/{memberId}    deleted members, restorable
├── gymPlans/{planId}
├── invoices/{invoiceId}     every payment ever taken
├── trainers/{trainerId}
└── attendance/{recordId}    written by the scanner app
```

Member photos live in Supabase storage, not Firestore.

---

## Project layout

```
lib/
├── models/        member, plan, invoice, trainer
├── provider/      state and all Firestore reads and writes
├── resources/     PDFs, CSV, QR cards, reminders, notifications
├── screens/       one folder per area of the app
├── widgets/       shared UI pieces
└── theme/         light and dark themes
test/              plain Dart tests for the logic that matters
```

Business rules that both apps must agree on do **not** live here — they live
in [fitstrong_core](https://github.com/sahilpotdukhe/fitstrong_core).

---

## Working on the shared package

`pubspec.yaml` pins `fitstrong_core` to a git tag so updates are deliberate.
`pubspec_overrides.yaml` points at `../packages/fitstrong_core` locally, so
edits to the package are picked up immediately without retagging.

If you change the shared package, tag and push it **before** committing the
pubspec change here, or a fresh clone will not build. See that repo's README
for the exact steps.
