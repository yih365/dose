# Dose — Caffeine Impact Tracker

A Flutter app for tracking caffeine intake and correlating it with health metrics (heart rate, sleep). Companion Wear OS app for Pixel Watch with a quick-log tile.

## Architecture

### Data sources

| Data | Source | Stored in Supabase? |
|---|---|---|
| Caffeine entries | This app | Yes — authoritative |
| User preferences (daily limit, etc.) | This app | Yes |
| Resting heart rate | Health Connect (read-only) | No |
| Sleep sessions | Health Connect (read-only) | No |

**Why Health Connect data is not copied to Supabase:**
- Health Connect is already the on-device source of truth; a copy would drift.
- Health data can be retroactively corrected in Health Connect; a backend copy would go stale.
- Google's Health Connect ToS restricts storing health data externally beyond core app function.
- Reduces privacy liability (GDPR, HIPAA-adjacent).

Health Connect data is pulled fresh each time the Compare screen opens (or on app resume). No caching needed — reads are local and fast.

**Writing caffeine back to Health Connect:**
Health Connect has a `NutritionRecord` type with a `caffeine` field. We write each logged entry back so other health apps (Google Fit, etc.) can see caffeine intake. This is one-way — we are the source, Health Connect is the echo.

### Backend (Supabase)

Stores only what originates in this app:
- `caffeine_entries` — type, mg, timestamp, user_id
- `user_preferences` — daily limit, sleep cutoff time, streak

### Pixel Watch (Wear OS)

Communication goes through the Android Wearable Data Layer, not the internet:
- Watch → Phone: `MessageClient` on `/log_caffeine`
- Phone → Watch: `DataClient` on `/daily_total`

The phone app writes to Supabase and Health Connect after receiving a watch message. The watch never touches the network directly.

## Project structure

```
lib/               Flutter phone app (Dart)
wearos/            Wear OS companion app (Kotlin, separate Android project)
android/           Flutter Android host — includes WatchListenerService bridge
```

## Development

### Phone app (macOS)
```bash
# Kill and relaunch after code changes
kill $(pgrep -f "dose.app/Contents/MacOS/dose") $(pgrep -f "flutter_tools.snapshot run") 2>/dev/null
flutter run -d macos &
until pgrep -f "dose.app/Contents/MacOS/dose" > /dev/null; do sleep 2; done && echo "App running"
```

### Wear OS app
Open `wearos/` as a separate project in Android Studio. Deploy to a Pixel Watch via ADB.
