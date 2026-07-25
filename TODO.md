# TODO

## Auth
- [ ] Set up Google sign-in (google_sign_in package)
- [ ] Add sign out button to You page

## Backend
- [ ] Set up Supabase project and schema (users, caffeine_entries)
- [ ] Wire Supabase auth to Google sign-in
- [ ] Replace sample data with live Supabase reads/writes
- [ ] Push daily totals to Supabase when entries change

## Health Data (Android / Health Connect)
- [ ] Add Health Connect dependency and permissions to Android manifest
- [ ] Read resting heart rate from Health Connect
- [ ] Read sleep session data from Health Connect
- [ ] Feed real heart rate + sleep into the Compare screen charts
- [ ] Write each logged caffeine entry back to Health Connect as a NutritionRecord (so other health apps can see it)

## Logging
- [x] Allow user to input a custom time when logging caffeine

## Bugs
