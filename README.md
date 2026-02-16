# Lush? Salon Admin App

A lightweight admin dashboard for salon operations with responsive web/desktop/mobile layouts.

## Tech Stack
- Flutter (Material 3)
- Riverpod (state management)
- GoRouter (navigation)
- Google Fonts (typography)

## Features
- KPI dashboard with revenue and booking snapshots
- Bookings queue with quick status overview
- Staff roster and load visibility
- Customer insights placeholders for analytics

## Setup Instructions
1. `flutter pub get`
2. `flutter run`

## Screenshots
- Dashboard
- Bookings
- Staff
- Insights

## Assumptions
- Data is mocked locally for the assignment.
- Firebase can be connected for real-time bookings and analytics as a future step.

## Firebase Notes
- Firebase is wired through `FirebaseBootstrap`. Set `enableFirebase = true` and replace the web options or run FlutterFire to generate platform configs.
