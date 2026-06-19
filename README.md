# Paperly

> Your day, on paper.

A minimal daily planner for people who want focus, not features. Each day gets its own page — a to-do list and a color-coded time-block schedule. An AI assistant turns a quick brain dump into a structured plan. Works fully offline; optionally syncs across devices via Supabase.

**Website:** _coming soon_

---

## Features

- **Daily page** — one clean page per day, no backlog clutter
- **To-do list** — quick capture, tap to check off
- **Time blocks** — schedule your hours with 5 color labels
- **AI planner** — brain-dump anything, get back a time-blocked plan
- **Offline-first** — local SQLite via Drift, syncs when online
- **Optional auth** — sign in with Google to back up and sync across devices

---

## Running the app

### Prerequisites

- Flutter SDK `^3.5.0`
- A `.env` file in the project root (see below)

### 1. Install dependencies

```bash
flutter pub get
```

### 2. Set up environment variables

Create a `.env` file in the project root:

```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
OPENAI_API_KEY=your-openai-key
```

All keys are optional — the app runs without them, but auth and AI planning will be disabled.

### 3. Run

Use the provided script so env vars are injected as `--dart-define` flags:

```bash
./run.sh
```

To target a specific device:

```bash
./run.sh -d "iPhone 16"
```

Or run manually without env vars (auth and AI disabled):

```bash
flutter run
```

---

## Project structure

```
lib/
├── core/           # Theme, router, Supabase client, env
├── data/
│   ├── local/      # Drift database (todos, time blocks)
│   └── remote/     # Supabase sync
└── features/
    ├── onboarding/ # First-launch tutorial flow
    ├── daily/      # Main daily page + widgets
    ├── ai_planner/ # Brain dump → AI plan
    ├── auth/       # Sign in / sign up
    └── profile/    # Profile sheet
```

---

## Tech stack

| Layer | Library |
|---|---|
| State management | Riverpod |
| Local database | Drift + SQLite |
| Backend / auth | Supabase |
| Navigation | go_router |
| AI planning | OpenAI API |
