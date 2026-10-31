# Tripmate

A Flutter travel app for discovering destinations, saving favourites and planning trips. Each trip has a day-by-day itinerary, a packing checklist and a budget tracker. All data is stored locally on the device.

## Features

- **Splash and login:** animated splash screen, then a login page with form validation and a guest option. Both use `splash.jpg` as the background.
- **Explore:** 10 destinations with search and category filters (Beach, City, Culture, Adventure).
- **Destination details:** photo header, rating, average daily cost, best time to visit, highlights.
- **Saved:** favourite any destination with the heart icon and find it later in the Saved tab.
- **Trip planning:** pick dates and a budget to create a trip.
- **Itinerary:** add activities by day and tick them off as you go.
- **Packing list:** a default checklist you can extend, with a progress bar.
- **Budget tracker:** log expenses and see what's left to spend, with a warning when you go over.
- **Persistence:** favourites and trips are saved with `shared_preferences` and survive app restarts.

## Requirements

- Flutter 3.10 or newer (Dart 3)
- An Android or iOS emulator, a physical device, or Chrome for web testing

## Getting started

```bash
flutter create tripmate
cd tripmate
```

1. Replace `lib/main.dart` and `pubspec.yaml` with the files from this project.
2. Create the folder `assets/images/` in the project root and add the images listed below.
3. Install dependencies and run:

```bash
flutter pub get
flutter run
```

## Project structure

```
tripmate/
├── lib/
│   └── main.dart          # the entire app
├── assets/
│   └── images/            # destination photos (see below)
├── pubspec.yaml
└── README.md
```

## Images

Add these JPGs (landscape, about 1200 px wide) to `assets/images/`. Free sources include [Unsplash](https://unsplash.com) and [Pexels](https://pexels.com). Filenames must match exactly.

| File | Suggested search |
|---|---|
| `splash.jpg` | Scenic travel shot, such as a mountain lake or airplane window |
| `paris.jpg` | Eiffel Tower |
| `bali.jpg` | Bali rice terraces or beach |
| `tokyo.jpg` | Tokyo skyline or Shibuya at night |
| `santorini.jpg` | Santorini blue domes |
| `maldives.jpg` | Maldives overwater villas |
| `new_york.jpg` | New York skyline |
| `jaipur.jpg` | Hawa Mahal or Amber Fort |
| `swiss_alps.jpg` | Swiss Alps mountains |
| `machu_picchu.jpg` | Machu Picchu |
| `rome.jpg` | Colosseum |

If an image is missing, the app shows a placeholder icon instead of crashing.

## pubspec.yaml essentials

```yaml
dependencies:
  flutter:
    sdk: flutter
  shared_preferences: ^2.2.3

flutter:
  uses-material-design: true
  assets:
    - assets/images/
```

## How it works

| Area | Details |
|---|---|
| State | `AppStore` (a `ChangeNotifier`) holds favourites and trips. Screens listen to it with `ListenableBuilder`. |
| Storage | Favourites are saved as a string list and trips as JSON in `shared_preferences`. |
| Models | `Destination` (static data), `Trip`, `PlanItem`, `PackItem`, `Expense`. |
| Navigation | `SplashPage` → `LoginPage` → `HomeShell` (bottom navigation with Explore, Saved, My trips). |
| Theme | Material 3, deep teal (`kInk`) with a marigold accent (`kAccent`). |

## Customising

- **Add a destination:** add an entry to `kDestinations` in `main.dart` and drop a matching `<id>.jpg` into `assets/images/`.
- **Change the currency:** edit `kCurrency` near the top of `main.dart`.
- **Change colours:** edit `kInk`, `kAccent`, `kSurface` and `kText`.
- **Add real authentication:** replace the body of `_signIn()` in `LoginPage` with your auth call (Firebase Auth, for example) and call `_goHome()` on success. The current login only validates the form and has no backend.

## Usage tips

- Swipe a trip card left on the My trips tab to delete it.
- Day numbers in the itinerary run from 1 to the length of the trip.
- The login page is shown on every launch. Session persistence is not implemented.

## Known limitations

- Login is client-side validation only.
- Destination data is hard-coded; there is no live API.
- Data lives on the device only, with no cloud sync or backup.

## Dependencies

- [`shared_preferences`](https://pub.dev/packages/shared_preferences) for local persistence
