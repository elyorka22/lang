# Lingua

Cross-platform language exchange & AI tutor app (Flutter).  
Telegram-smooth chat · Duolingo-style learning · ChatGPT-style tutor · Tandem-style partners.

## Stack

| Layer | Tech |
|--------|------|
| Mobile | Flutter, Dart, Material 3 |
| State | Riverpod |
| Routing | GoRouter |
| HTTP | Dio + JWT refresh |
| Realtime | Socket.IO client |
| Local | Hive + flutter_secure_storage |
| Media | Cloudflare R2 / DO Spaces (presigned upload) |

## Project structure

```
lib/
 ├── core/           # theme, network, storage, errors, config
 ├── shared/         # models, widgets, mock data, providers
 ├── features/
 │     ├── auth/
 │     ├── home/
 │     ├── chat/
 │     ├── ai/
 │     ├── discover/
 │     ├── profile/
 │     ├── vocabulary/
 │     ├── notifications/
 │     ├── learning/
 │     └── settings/
 ├── routes/
 └── main.dart
```

Each feature follows Clean Architecture: `presentation` → `application` → `domain` → `data`.

## Run locally

Requires Flutter **3.22+** (Dart 3.3+) on a supported OS.

```bash
flutter pub get
flutter run
```

Demo auth works offline with mock data (`USE_MOCK=true` by default):

- Email: `alex@lingua.app` / any password ≥ 6 chars  
- Or **Continue as guest** / Google / Apple (mock)

Build:

```bash
flutter build apk
flutter build appbundle
flutter build ios
```

### Point at your NestJS API

```bash
flutter run --dart-define=USE_MOCK=false \
  --dart-define=API_BASE_URL=https://api.yourdomain.com/v1 \
  --dart-define=SOCKET_URL=https://api.yourdomain.com \
  --dart-define=MEDIA_CDN_URL=https://cdn.yourdomain.com
```

Endpoint map: `lib/core/network/api_endpoints.dart`.

## Features included

- Auth (email, Google/Apple hooks, guest, password reset)
- Onboarding (native / learning language / interests)
- Home (daily goal, AI suggestions, online users, continue learning, chats)
- Discover (filters, list + swipe cards)
- Chat (Telegram-style bubbles, long-press AI actions, typing, read receipts UI)
- AI tutor (modes: tutor / grammar / roleplay / IELTS + free-tier limit)
- Voice analysis screen (scores + coaching tips)
- Vocabulary + SRS-style flashcards
- Profile, friends actions, learning stats, premium paywall UI
- Settings (theme, privacy stubs, logout, delete account)
- Light / dark Material 3 theme (`#7C3AED` Aurora Violet primary)

## Backend contract (NestJS)

Expected stack: NestJS · PostgreSQL · Redis · R2/Spaces · FCM · Socket.IO · Cloudflare CDN.

Media must use **presigned uploads** to object storage (`POST /media/presign`) — never store images/voice on the app server.

Realtime events (Socket.IO): `message:new`, `typing`, `presence:update`, `message:read`, `conversation:join|leave`.

## Configure before production

1. Google Sign-In / Apple Sign-In client IDs  
2. Firebase (`google-services.json` + `GoogleService-Info.plist`) — see `PushNotificationService`  
3. WebRTC provider for voice/video calls  
4. StoreKit / Play Billing for Premium  
5. Replace mock repositories with Dio + Socket implementations  

## Design system

- Primary `#7C3AED`, mist lilac surfaces, 16–20px radii, 8pt spacing  
- Plus Jakarta Sans via `google_fonts`  
- Soft shadows, motion via `flutter_animate`

## First-time platform sync

If Android/iOS tooling looks incomplete on a fresh machine, regenerate platforms while keeping `lib/`:

```bash
flutter create . --project-name lingua --org com.lingua --platforms=android,ios
flutter pub get
```

