# 🚀 MindMirror Deployment Guide

This guide covers everything you need to know to take MindMirror from your local development environment to a publicly accessible deployment, complete with an Android APK.

**Key Concept**: A mobile app (frontend) needs a persistent, publicly accessible URL to talk to the backend. `localhost` on a phone means the phone itself, not your laptop.

---

## The Two Paths

Choose the path that fits your current needs and constraints:

1.  **Path A: The Hackathon Fast-Track (ngrok)**: Easiest. Backend runs on your laptop, `ngrok` exposes it to the internet temporarily. Good for a 10-minute demo on a phone.
2.  **Path B: The Persistent Deploy (Render/Railway)**: Harder. Backend runs on cloud servers. Good for sharing the app with others after the hackathon.

---

## Path A: The Hackathon Fast-Track (Local + ngrok)

Use this method if you just need to demo the app on a physical Android device right now and your laptop will stay awake.

### Step 1: Start Your Local Backend
1. Ensure Docker Desktop is running.
2. Open PowerShell in the `jrlun` folder.
3. Start the stack: `docker compose up -d`

### Step 2: Create a Public Tunnel
1. Download [ngrok](https://ngrok.com/download) and authenticate it (requires a free account).
2. Open a new PowerShell window and run:
   ```powershell
   ngrok http 8001
   ```
3. Look for the `Forwarding` line in the output. It will look like `https://xyz-123.ngrok-free.app`. **Copy this URL.** Do not close this terminal window.

### Step 3: Update Flutter API Config
1. Open `frontend/lib/services/api_config.dart`.
2. Change the `baseUrl` to your ngrok URL:
   ```dart
   static const String baseUrl = 'https://xyz-123.ngrok-free.app'; // No trailing slash!
   ```

### Step 4: Build the Android APK
1. Open PowerShell in the `jrlun/frontend` folder.
2. Run the build command:
   ```powershell
   flutter build apk --release
   ```
3. When finished, the APK is located at:
   `frontend/build/app/outputs/flutter-apk/app-release.apk`

### Step 5: Install & Test
1. Transfer the `.apk` file to your Android phone (via USB, email, or cloud drive).
2. Install it (you may need to allow "Install from unknown sources").
3. **Important**: Your laptop must remain on, Docker must be running, and the ngrok terminal must stay open for the app to work.

---

## Path B: The Persistent Deploy (Render / Railway)

Use this method if you want the app to work 24/7 without relying on your laptop. We'll use Render as an example, as they offer free tiers for both Web Services and Postgres.

### Step 1: Prep the Codebase
1. Ensure your code is pushed to a GitHub repository.
2. Double-check that `.env` is NOT in source control (it should be in `.gitignore`).

### Step 2: Deploy the Database (Render)
1. Go to [Render.com](https://render.com) and create an account.
2. Click **New +** > **PostgreSQL**.
3. Name it `mindmirror-db`. The free tier is fine.
4. Once deployed, copy the **Internal Database URL** (for Render web services) or **External Database URL** (if you host the backend elsewhere).
5. *Note: You will need to manually run your SQL migration scripts (`001`, `002`, `003`) against this new database using a tool like pgAdmin or DBeaver connecting via the External URL.*

### Step 3: Deploy the Backend (Render)
1. In Render, click **New +** > **Web Service**.
2. Connect your GitHub repository.
3. **Build Command**: Render handles Docker automatically, but if you need to specify: Use the `backend/Dockerfile`.
   * *Alternatively (non-Docker Python env)*:
     * Build command: `pip install -r backend/requirements.txt`
     * Start command: `uvicorn backend.main:app --host 0.0.0.0 --port $PORT`
4. **Environment Variables**: You MUST set these in the Render dashboard:
   * `GROQ_API_KEY`: Your Groq key (`gsk_...`)
   * `DATABASE_URL`: The Internal Database URL you copied in Step 2.
5. Deploy. Once finished, Render will give you a public URL (e.g., `https://mindmirror-backend.onrender.com`).

### Step 4: Update Flutter API Config
1. Open `frontend/lib/services/api_config.dart`.
2. Change the `baseUrl` to your Render URL:
   ```dart
   static const String baseUrl = 'https://mindmirror-backend.onrender.com'; // No trailing slash
   ```

### Step 5: Build the Android APK
1. Open PowerShell in the `jrlun/frontend` folder.
2. Run the build command:
   ```powershell
   flutter build apk --release
   ```
3. Transfer and install the `.apk` on your phone. It now talks to your cloud server 24/7!

---

## 🍎 A Note on iOS (iPhones)

Building for iOS requires a macOS environment and an Apple Developer account ($99/yr) if you want to deploy to real devices beyond 7 days.
*   **Without a Mac**: You cannot build an iOS app (`.ipa` file) natively on Windows.
*   **Workaround**: You can deploy the Flutter frontend as a Web App (`flutter build web`) and host it on Firebase Hosting or Vercel, then open it in Safari on the iPhone.

---

## Troubleshooting Checklist

*   **App won't connect / Network Error**:
    *   Did you update `api_config.dart`?
    *   Is your backend URL correct (no trailing slash, e.g., `http://...` not `http://.../`)?
    *   If using Path A, is ngrok still running?
*   **APK won't install**:
    *   Ensure you uninstalled any previous versions of the app from your phone first.
    *   Ensure "Install from unknown sources" is enabled in Android settings.
*   **AI extraction fails in the cloud**:
    *   Did you set the `GROQ_API_KEY` environment variable in your hosting provider's dashboard?
