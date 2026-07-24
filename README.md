# Weather App

A Flutter app that fetches and displays the current weather for any city, using
[weatherapi.com](https://www.weatherapi.com/). Built with Clean Architecture,
Cubit state management, get_it dependency injection, and Hive offline caching.

## Features

- Search any city and see its name, temperature (°C), condition description, and condition icon
- Loading indicator while fetching
- Clear error messages for invalid cities and network failures, with retry
- **Offline caching (bonus):** the last successful result is cached in Hive and shown with an "Offline" banner when there is no connection
- **Responsive (bonus):** content is centered and capped at 500px, so it works on phones, tablets, and landscape

## Architecture

Clean Architecture, feature-first. Dependencies point inward: presentation → domain ← data.

```
lib/
├── core/            # shared: DI (get_it), API client, constants, failures/exceptions
└── features/weather/
    ├── domain/      # Weather entity, WeatherRepository contract, GetCurrentWeather use case
    ├── data/        # WeatherModel (JSON), remote (API) + local (Hive) data sources, repository impl
    └── presentation/# WeatherCubit + sealed states, page, widgets
```

- **SRP** — each class does one thing (use case = one action, ApiClient only does HTTP, widgets only render).
- **OCP** — sealed `Failure` hierarchy: new error kinds slot in without editing existing handling.
- **DIP** — presentation and domain depend on the abstract `WeatherRepository`; concretes are bound only in `core/di/injection_container.dart`.

### Why Cubit (flutter_bloc)?

- The screen has a small, enumerable set of states (initial / loading / loaded / error) that map 1:1 to explicit Cubit emissions — as a sealed class, the UI switch is exhaustive so no state can be forgotten.
- Business logic is outside widgets and unit-tested without the UI (`test/features/weather/presentation/weather_cubit_test.dart`).
- Cubit avoids Bloc's event boilerplate, which a single-action (search) screen doesn't need.

### Error handling

| Scenario | Result |
| --- | --- |
| Unknown city (API error 1006) | "City not found" message |
| Offline / timeout, cache exists | Cached weather + offline banner |
| Offline / timeout, no cache | "No internet connection" + retry |
| Other server errors / bad JSON | Generic server error + retry |
| Empty input | "Please enter a city name" (no request sent) |

## Environment configuration

The API base URL and key are not hard-coded — they are injected at build time
with `--dart-define-from-file` and read via `String.fromEnvironment` in
`lib/core/constants/api_constants.dart`.

Config files live in `env/`:

| File | Purpose |
| --- | --- |
| `env/example.json` | Template with placeholder values |
| `env/dev.json` | Development values |
| `env/prod.json` | Production values |

> **Note:** In a real project, `env/dev.json` and `env/prod.json` should be
> gitignored (only the `example.json` template committed) so API keys never
> land in version control. They are committed here **on purpose** so the
> project can be cloned and run immediately without any extra setup.

If you want to use your own key from [weatherapi.com](https://www.weatherapi.com/), copy the template and fill it in:

```
cp env/example.json env/dev.json
```

Variables:

| Key | Description |
| --- | --- |
| `WEATHER_BASE_URL` | weatherapi.com base URL (e.g. `https://api.weatherapi.com/v1`) |
| `WEATHER_API_KEY` | Your weatherapi.com API key |

The app asserts at startup (debug builds) that both values are present, so a
build launched without the flag fails fast with a clear message.

## Running

```
flutter pub get

# development
flutter run --dart-define-from-file=env/dev.json

# production
flutter run --release --dart-define-from-file=env/prod.json
```

The same flag applies to `flutter build` (apk / ipa / etc.).

