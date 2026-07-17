# Backend API sketch for NestJS

This Flutter client expects a NestJS API matching `lib/core/network/api_endpoints.dart`.

## Suggested modules

- `auth` — JWT access + refresh, Google/Apple token exchange, email verify
- `users` — profiles, block, report, avatar presign
- `discover` — filtered cursor pagination, online presence (Redis)
- `friends` — follow / request / accept / reject
- `chat` — conversations, messages (cursor), Socket.IO gateway
- `groups` — Telegram-style multi-member practice rooms
- `social` — topic rooms, host tables (30m/4 seats), mentors, correction karma
- `games` — flashcards entry, leveled AI quest chat, picture words (assoc. vocab), XP unlock
- `media` — R2/Spaces presigned PUT URLs only
- `ai` — chat, translate, grammar, explain, improve, pronounce, voice-analysis, lessons, quiz, roleplay (rate-limited)
- `vocabulary` — CRUD + SRS scheduling
- `learning` — daily goals, Goal Map (level by deadline), XP, streaks, achievements, leaderboard
- Languages catalog: EN, RU, UZ (+ ES/FR/DE/PT/JA/IT/KO/ZH/AR) — extend in `AppLanguages`
- `notifications` — FCM token registry + push jobs
- `billing` — Premium entitlements

## Groups API

- `POST /groups` — create `{ title, description, memberIds }`
- `GET /groups/:id`
- `POST /groups/:id/members` — add members
- `DELETE /groups/:id/members/:userId`
- `POST /groups/:id/leave`
- Socket events reuse `conversation:join` with group conversation ids

## Performance checklist

- Cursor pagination on messages, discover, vocabulary
- Redis cache for online users + session denylist
- Bull/BullMQ (or Nest queues) for AI + push jobs
- Rate limit AI + auth endpoints
- WebP + client-side compression before R2 upload
- CDN in front of object storage

## Security checklist

- bcrypt/argon2 passwords
- refresh token rotation + device sessions
- HTTPS only
- content moderation hooks on reports
- anti-spam on friend requests / messages
