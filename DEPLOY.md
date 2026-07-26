# Deploy SRJ Tech

This guide deploys:

- **Backend** → [Render](https://render.com)
- **Website (Flutter Web)** → [Firebase Hosting](https://firebase.google.com/docs/hosting)
- **Database** → [MongoDB Atlas](https://www.mongodb.com/atlas) (required for Render)

---

## 1) MongoDB Atlas (required)

1. Create a free cluster at https://cloud.mongodb.com
2. Database Access → create a user (save username/password)
3. Network Access → Add IP Address → `0.0.0.0/0` (allow Render)
4. Database → Connect → Drivers → copy the URI, e.g.

```text
mongodb+srv://USER:PASSWORD@cluster0.xxxxx.mongodb.net/srj_tech?retryWrites=true&w=majority
```

5. Seed once (from your machine, with Atlas URI):

```bash
cd backend
MONGODB_URI="mongodb+srv://USER:PASSWORD@cluster0.xxxxx.mongodb.net/srj_tech?retryWrites=true&w=majority" npm run seed
```

---

## 2) Deploy backend to Render

### Option A — Blueprint (`render.yaml`)

1. Push this repo to GitHub
2. Render Dashboard → **New** → **Blueprint**
3. Select the repo (root contains `backend/render.yaml`, or set path to `backend`)
4. Fill secret env vars when prompted

### Option B — Web Service (manual)

1. Render → **New Web Service**
2. Connect GitHub repo
3. Settings:
   - **Root Directory:** `backend`
   - **Runtime:** Node
   - **Build Command:** `npm install`
   - **Start Command:** `npm start`
   - **Health Check Path:** `/api/health`

### Environment variables on Render

| Key | Example / notes |
|-----|-----------------|
| `MONGODB_URI` | Atlas connection string |
| `CORS_ORIGIN` | `https://YOUR_PROJECT.web.app,https://YOUR_PROJECT.firebaseapp.com` |
| `ALLOW_FIREBASE_HOSTING` | `true` |
| `SMTP_HOST` | `smtp.gmail.com` |
| `SMTP_PORT` | `465` |
| `SMTP_SECURE` | `true` |
| `SMTP_USER` | `srjtechsupport@gmail.com` |
| `SMTP_PASS` | Gmail App Password |
| `MAIL_FROM` | `SRJ Tech Website <srjtechsupport@gmail.com>` |
| `MAIL_TO` | `srjtechsupport@gmail.com` |
| `MAIL_AUTO_REPLY` | `true` |
| `NODE_ENV` | `production` |

After deploy, copy your API URL, for example:

```text
https://srj-tech-api.onrender.com
```

Health check:

```text
https://srj-tech-api.onrender.com/api/health
```

> Free Render services can sleep after idle time; first request may be slow.

---

## 3) Deploy website to Firebase Hosting

### One-time setup

```bash
# From project root
firebase login
firebase projects:create srj-tech-web   # or use an existing project id
```

Edit `.firebaserc` and set your real Firebase project id:

```json
{
  "projects": {
    "default": "YOUR_FIREBASE_PROJECT_ID"
  }
}
```

Then:

```bash
firebase use YOUR_FIREBASE_PROJECT_ID
```

### Build + deploy

Replace the Render URL with yours:

```bash
chmod +x scripts/deploy_firebase.sh

API_BASE_URL=https://srj-tech-api.onrender.com/api ./scripts/deploy_firebase.sh
```

Or manually:

```bash
flutter build web --release \
  --dart-define=API_BASE_URL=https://srj-tech-api.onrender.com/api

firebase deploy --only hosting
```

Site URL will look like:

```text
https://YOUR_FIREBASE_PROJECT_ID.web.app
```

---

## 4) Final checklist

1. Atlas seeded (`npm run seed` with Atlas URI)
2. Render `/api/health` returns OK
3. Render `CORS_ORIGIN` includes your Firebase URLs
4. Flutter built with production `API_BASE_URL`
5. Contact form sends email (SMTP vars set on Render)

---

## Local vs production API

| Environment | API base |
|-------------|----------|
| Local | `http://localhost:5001/api` (default) |
| Production | `--dart-define=API_BASE_URL=https://YOUR-API.onrender.com/api` |
