# How the codebase works

This is a walkthrough of the app's code. After reading this, you could open any file and know why it's there and what it talks to.

Read the [README](README.md) first if you haven't — it covers *what the app does*. This file covers *how the code makes it do that*.

---

## Table of contents

1. [The mental model](#the-mental-model)
2. [A tour of the folders](#a-tour-of-the-folders)
3. [The four layers, from outside in](#the-four-layers-from-outside-in)
4. [The data: what we store and where](#the-data-what-we-store-and-where)
5. [State management: Provider + Firebase streams](#state-management-provider--firebase-streams)
6. [The UI layer: screens and shared widgets](#the-ui-layer-screens-and-shared-widgets)
7. [A worked example: what happens when you send a request](#a-worked-example-what-happens-when-you-send-a-request)
8. [The theme and design system](#the-theme-and-design-system)
9. [Token IDs, done properly](#token-ids-done-properly)
10. [How to add a feature](#how-to-add-a-feature)
11. [Tests: what's covered, what isn't](#tests-whats-covered-what-isnt)
12. [Things that caused bugs and how we fixed them](#things-that-caused-bugs-and-how-we-fixed-them)

---

## The mental model

Before we dive in, here's the shape of the app in one paragraph:

> Two people use the app. Alice registers as a **donor** — she fills a form and a `DonorToken` gets saved to Firebase. Bob needs blood for his mother, so he registers as a **receiver** — his `ReceiverToken` gets saved. Bob opens the search screen and sees Alice's token (filtered by blood group compatibility). He taps "Send request" — a `BloodRequest` document ties the two tokens together in Firebase Realtime Database. Alice sees the request in her Profile, taps Accept, and walks through four status stages until the blood is donated.

That's it. Four domain objects: **User**, **DonorToken**, **ReceiverToken**, **BloodRequest**. Everything the app does is CRUD on those plus a status state machine on the last one.

---

## A tour of the folders

```
lib/
├── main.dart          # app entry point — Firebase init + seed + Providers
├── app.dart           # MaterialApp + theme wiring
│
├── core/              # things with no UI, no state — pure support
│   ├── theme/         # colors, text styles, ThemeData
│   ├── constants/     # blood groups, Indian cities, cause options
│   └── utils/         # id_generator, blood_compatibility, password stuff, validators
│
├── data/              # everything about storage — models and Firebase access
│   ├── models/        # plain Dart classes for the 4 domain objects
│   ├── remote/        # RTDB seed data for the demo
│   └── repositories/  # the CRUD API — the one place screens talk to Firebase
│
├── state/             # Provider ChangeNotifiers that sit on top of repositories
│
├── features/          # one folder per feature, each with its screens
│   ├── splash/
│   ├── auth/          # login, signup, profile setup
│   ├── dashboard/     # home screen with role cards
│   ├── donor/         # register, incoming requests, status
│   ├── receiver/      # register, search donors, status
│   └── profile/       # welcome card + tabs + edit sheet
│
└── shared/widgets/    # reusable UI primitives used by multiple features
```

The logic: **core** has no dependencies on anything. **data** depends on core. **state** depends on data + core. **features** depend on everything. **shared/widgets** depends only on core. No circularity, no cross-feature coupling.

---

## The four layers, from outside in

### Layer 1: Screens (features/)

These are what the user sees. Each screen is a `StatefulWidget` or `StatelessWidget` that listens to state providers via `context.watch<>()`.

Screens never import Firebase directly. They don't know Firebase exists. They just ask a provider for data.

### Layer 2: Providers (state/)

Each provider is a `ChangeNotifier` that holds the latest list of domain objects for one concern: `AuthProvider`, `DonorProvider`, `ReceiverProvider`, `RequestProvider`.

Providers have two jobs:
1. Expose the current data to screens (just getters)
2. Listen to Firebase Realtime Database via `ref.onValue` streams so when any repository writes, the provider automatically re-reads and notifies subscribers

This is the magic that makes the UI feel live. If `RequestRepository` marks a request as accepted, `RequestProvider` picks it up from the RTDB stream within a tick. If that acceptance also closed a donor token, `DonorProvider` also notifies. Every screen watching those providers rebuilds automatically.

### Layer 3: Repositories (data/repositories/)

Four of them, one per domain object. Each has plain async methods — `create`, `byId`, `byOwner`, `updateStatus`, etc. — and that's the entire storage API the app knows about.

This is the seam. If the backend ever changes, only the insides of these four files change. Nothing else.

### Layer 4: Firebase (Realtime Database + Auth)

**Firebase Auth** handles user identity — sign up, login, logout, session persistence.

**Firebase Realtime Database (RTDB)** stores four collections:
- `users/{uid}` — user profiles
- `donors/{tokenId}` — donor tokens
- `receivers/{tokenId}` — receiver tokens
- `requests/{requestId}` — blood requests
- `counters/{prefix_YYYYMMDD}` — ID sequence counters
- `meta/` — seed data flags

All reads use `ref.onValue` streams (live updates). All writes use `ref.set()` or `ref.update()` with an 8-second timeout.

---

## The data: what we store and where

### `AppUser` — `users/{uid}`

```dart
{
  uid: 'firebase-uid-abc123',
  email: 'alice@example.com',
  name: 'Alice Ramanathan',
  phone: '9876543210',
  dob: '12/03/1992',
  location: 'Bengaluru, Karnataka',
  createdAt: '2026-04-21T06:15:00.000Z',
  profileComplete: true,
}
```

### `DonorToken` — `donors/DNR-YYYYMMDD-###`

```dart
{
  id: 'DNR-20260421-003',
  ownerEmail: 'alice@example.com',
  name: 'Alice Ramanathan',
  bloodGroup: 'O+',
  location: 'Bengaluru, Karnataka',
  phone: '9876543210',
  lastDonationDate: '10/01/2026',
  createdAt: '2026-04-21T06:15:00.000Z',
  closed: false,
  acceptedRequestId: null,
}
```

### `ReceiverToken` — `receivers/RCV-YYYYMMDD-###`

```dart
{
  id: 'RCV-20260421-001',
  ownerEmail: 'bob@example.com',
  name: 'Ranjan Kumar',
  bloodGroup: 'B+',
  location: 'Bengaluru, Karnataka',
  phone: '9876543211',
  cause: 'Surgery',
  causeOther: '',
  unitsNeeded: 2,
  createdAt: '...',
  closed: false,
}
```

### `BloodRequest` — `requests/REQ-YYYYMMDD-###`

```dart
{
  id: 'REQ-20260421-001',
  donorTokenId: 'DNR-20260421-003',
  receiverTokenId: 'RCV-20260421-001',
  senderEmail: 'bob@example.com',
  recipientEmail: 'alice@example.com',
  status: 'pending',
  createdAt: '...',
  updatedAt: '...',
}
```

---

## State management: Provider + Firebase streams

Here's the pattern in full, using `DonorProvider` as the example:

```dart
class DonorProvider extends ChangeNotifier {
  final DonorRepository _repo = DonorRepository();
  StreamSubscription<DatabaseEvent>? _sub;

  List<DonorToken> _all = const [];
  List<DonorToken> get available => _all.where((d) => !d.closed).toList();

  void init() {
    _sub = FirebaseDatabase.instance
        .ref('donors')
        .onValue
        .listen((event) {
      final value = event.snapshot.value;
      if (value is Map) {
        _all = (value).values
            .map((v) => DonorToken.fromMap(Map<String, dynamic>.from(v)))
            .toList();
        notifyListeners();
      }
    });
  }
}
```

Three things to notice:

1. **The provider subscribes to RTDB.** `ref.onValue` gives a `Stream<DatabaseEvent>` that fires every time Firebase data changes — from any device, anywhere.
2. **Mutation goes through the repository.** Screens call repository methods which write to RTDB. RTDB fires an event, the provider sees it, the UI rebuilds. Data flows in a circle.
3. **Cross-provider updates are automatic.** When `RequestRepository.updateStatus` accepts a request and closes a donor token in one atomic RTDB update, both `RequestProvider` and `DonorProvider` see their respective stream events and update independently.

### Real-time connectivity monitoring

`AuthProvider` also monitors network connectivity using `connectivity_plus`. When the device goes offline, `databaseReachable` becomes `false` and the dashboard shows an offline banner. When connection is restored, the banner disappears automatically.

---

## The UI layer: screens and shared widgets

### Screens

14 screens, organized by feature. Most are `StatefulWidget` because they hold form controllers or local `_saving` booleans. Navigation is imperative (`Navigator.push`) rather than declarative — keeps the dependency graph small.

**Pattern: every screen that submits a form**
- `TextEditingController`s defined in `initState`, disposed in `dispose`
- `GlobalKey<FormState>` for validation
- `bool _saving = false` to disable submit button during async ops
- Guards `context.mounted` after every `await`

**Pattern: every screen with a status tracker**
- Reads `BloodRequest` from the provider
- Computes `StatusStep` list based on current status
- Renders via `StatusTracker` widget
- Shows action button that advances the state machine

### Shared widgets

- **`AppButton`** — 5 variants: primary, onDark, outline, ghost, danger
- **`AppTextField`** — editorial underline-style input
- **`BloodDrop`** — hand-painted teardrop via `CustomPaint`
- **`StatusTracker`** — dot-and-line progress indicator
- **`TokenIdChip`** — monospace pill for token IDs
- **`CardShell`** — flat card, 1px hairline border, zero shadows
- **`LocationField`** — text + autocomplete + GPS button

---

## A worked example: what happens when you send a request

**1. Tap handler** (`search_donors_screen.dart`)

Checks for an existing active request between this donor-receiver pair, then calls `RequestProvider.send()`.

**2. Provider** (`request_provider.dart`)

Thin pass-through to `RequestRepository.create()`.

**3. Repository** (`request_repository.dart`)

```dart
Future<BloodRequest> create(...) async {
  final id = await IdGenerator.request(); // RTDB transaction
  final req = BloodRequest(id: id, status: pending, ...);
  await _db.ref('requests/${req.id}').set(req.toMap());
  return req;
}
```

**4. ID Generator** (`id_generator.dart`)

Uses an RTDB transaction on `counters/{prefix_YYYYMMDD}` to atomically increment the sequence counter. Two concurrent callers can never get the same ID — RTDB's optimistic concurrency retries the slower one.

**5. RTDB fires a stream event**

`RequestProvider` (subscribed to `requests` ref) re-reads and calls `notifyListeners()`.

**6. Widgets rebuild**

The donor card now shows "Track status" / "Withdraw" instead of "Send request". The Profile → Requests tab shows the new request. All live, no manual refresh needed.

**7. When the donor accepts**

`RequestRepository.updateStatus` does one atomic multi-path RTDB update:

```dart
await _db.ref().update({
  'requests/$id': updated.toMap(),           // mark accepted
  'donors/${donorTokenId}/closed': true,      // remove from search
  'donors/${donorTokenId}/acceptedRequestId': id,
});
```

Both changes land atomically — either both succeed or neither does. This prevents the "accepted request + open donor still showing in search" bug that the original code had.

---

## The theme and design system

All visual tokens live in `lib/core/theme/`.

### `app_colors.dart`

```dart
maroon       #6B0F1A   // primary brand
red          #B01E2F   // logomark
ink          #1A1517   // body text
inkMuted     #6C6460   // secondary text
inkFaint     #A39C97   // disabled/placeholders
surface      #FFFFFF   // cards, content
surfaceMuted #F5F3F1   // section fills
hairline     #E3DDD8   // 1px borders
success      #2E5A3B   // completed statuses
warning      #8A4B00   // offline banner
danger       #8B1A1A   // destructive actions
```

### `app_text_styles.dart`

Seven type roles: display, headline, title, body, bodyStrong, caption, label. Plus `monoTag` for token IDs and `button` for actions.

Fonts: **Fraunces** for display/headline, **Inter** for everything else, **JetBrains Mono** for token IDs.

### `app_theme.dart`

Single `ThemeData.light()` factory. Notable: zero elevation on AppBar, underline-style inputs, 2px corner radii everywhere, no shadows on cards.

---

## Token IDs, done properly

Format: `PREFIX-YYYYMMDD-###`. Example: `DNR-20260421-003`.

Chosen over UUIDs because they're readable, sortable, and easy to say out loud. The sequence counter lives in RTDB at `counters/DNR_20260421` and is incremented using an RTDB **transaction** — which means two concurrent mints on different devices never produce the same ID. RTDB's optimistic concurrency automatically retries the slower caller.

| Prefix | Entity |
|--------|--------|
| `DNR` | Donor token |
| `RCV` | Receiver token |
| `REQ` | Blood request |

---

## How to add a feature

Example: add a "donation history" view showing completed donations.

**Step 1 — Do you need new data?**
A completed request where `recipientEmail == currentUser.email` is a donation. No new data needed.

**Step 2 — Do you need a new repository method?**
`RequestRepository` already has `byRecipient(email)`. Filter for `status == completed` in the screen or provider.

**Step 3 — Where does it go in the UI?**
New tab on the profile screen, or a new screen navigated to from profile.

**Step 4 — How do you make it live?**
Use `context.watch<RequestProvider>()` and filter the list. It rebuilds automatically whenever RTDB pushes a change.

---

## Tests: what's covered, what isn't

The unit tests in `test/unit/` cover:

- `password_strength_test.dart` — 17 cases
- `blood_compatibility_test.dart` — 12 cases
- `validators_test.dart` — 29 cases
- `models_test.dart` — 9 cases (toMap/fromMap round-trips for all 4 models)

> **Note:** The repository tests from the original Hive implementation have been removed. They tested against a local Hive temp directory which no longer exists. New integration tests against Firebase Emulator are planned as a follow-up.

Password hash tests are also removed since password hashing is now handled entirely by Firebase Auth — no custom SHA-256 logic remains in the app.

To run the remaining tests:

```bash
flutter test test/unit/
```

---

## Things that caused bugs and how we fixed them

### Non-atomic ID minting (fixed)
Two concurrent `IdGenerator.donor()` calls could produce duplicate IDs. Fixed by using RTDB transactions on the counter node — the database guarantees only one caller wins per increment.

### Non-atomic accept → close transition (fixed)
Originally: request was written as `accepted` first, then donor was closed. If the donor close failed, we'd have an accepted request with the donor still visible in search. Fixed by using a single multi-path `_db.ref().update({...})` call that writes both changes atomically.

### Offline state only checked at startup (fixed)
Originally `databaseReachable` was set once when the app launched. If the user lost connection mid-session, no banner appeared. Fixed by using `connectivity_plus` to stream real-time network changes, with an RTDB probe to confirm actual Firebase reachability.

### firebase_options.dart gitignored
This file is generated per-developer by `flutterfire configure` and is intentionally excluded from the repo. Run `flutterfire configure` after cloning to regenerate it. See `lib/firebase_options.example.dart` for the expected structure.
