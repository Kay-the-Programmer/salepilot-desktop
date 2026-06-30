# Google Sign-In setup (desktop)

The desktop app signs in with Google using a system-browser + loopback OAuth
flow, exchanges the result for a Firebase ID token, and posts it to the backend
`POST /auth/google`. Everything is already wired in code — you only need to
(1) enable the Google provider + create a Desktop OAuth client, and
(2) drop the client id/secret into `google_oauth.json`.

Firebase project: **`salepilot-ae09f`** (shared with the web/mobile apps + backend).
The Firebase Web API key is already baked in as a default, so you do **not** need
to set `FIREBASE_API_KEY`.

---

## 1. Enable the Google provider (one-time, free)

Firebase Console → project **salepilot-ae09f** → **Build → Authentication →
Sign-in method** → **Google** → enable → Save.
(If it's already enabled for the web/mobile apps, skip this.)

## 2. Create a Desktop OAuth client (one-time, free)

The existing Web/iOS/Android clients can't do desktop loopback — make a new one:

1. Google Cloud Console → same project (`salepilot-ae09f`) →
   **APIs & Services → Credentials**.
2. **+ Create credentials → OAuth client ID**.
3. **Application type → Desktop app**. Name it e.g. `SalePilot Desktop`.
4. **Create**. Copy the **Client ID** and **Client secret**.

No redirect URIs to configure — Desktop clients allow `http://127.0.0.1:<port>`
loopback automatically. Because the client lives in the same project, Firebase
accepts its tokens with no extra whitelisting.

> If the OAuth consent screen is in **Testing** mode, add your Google account
> under **Audience → Test users** (or click **Publish app**). The scopes used
> (`openid email profile`) are non-sensitive, so no verification is required.

## 3. Fill in `google_oauth.json`

This file is git-ignored. Replace the placeholders:

```json
{
  "GOOGLE_OAUTH_CLIENT_ID": "1234567890-abcdef.apps.googleusercontent.com",
  "GOOGLE_OAUTH_CLIENT_SECRET": "GOCSPX-xxxxxxxxxxxxxxxx"
}
```

## 4. Run / build with the defines

```powershell
flutter run   -d windows --dart-define-from-file=google_oauth.json
flutter build windows     --dart-define-from-file=google_oauth.json
```

You can put any other compile-time config in the same file too, e.g.
`"API_BASE_URL": "https://s-back-q0gg.onrender.com/api"`.

Without the file (or with placeholders unreplaced) the app still runs — the
"Continue with Google" button just shows a "not configured" message instead of
crashing.
