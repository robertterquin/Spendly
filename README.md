# spendly

A new Flutter project.

## Getting Started

### 1. Environment Setup

Copy `.env.example` to `.env` and provide your credentials:

```bash
cp .env.example .env
```

Open `.env` and fill in:
- `GROQ_API_KEY`: Your Groq API key from [Groq Cloud Console](https://console.groq.com/keys).
- `SUPABASE_URL` & `SUPABASE_ANON_KEY`: (Optional) Your Supabase project URL and anon public key.

### 2. Running the App

Run the Flutter application with the environment file loaded:

```bash
flutter run --dart-define-from-file=.env
```

Or open the project in VS Code and press `F5` (pre-configured via `.vscode/launch.json`).

