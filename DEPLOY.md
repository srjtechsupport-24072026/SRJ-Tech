# Deploy SRJ Tech

Everything runs on [Render](https://render.com), split across two services:

- **API** (`srj-tech-website-apis`) → Node web service
- **Website** (`srj-tech-website`) → static site serving the Flutter web build
- **Database** → [MongoDB Atlas](https://www.mongodb.com/atlas) (required by the API)

---

## 1) MongoDB Atlas (required)

1. Create a free cluster at https://cloud.mongodb.com
2. Database Access → create a user (save username/password)
3. Network Access → Add IP Address → `0.0.0.0/0` (Render's outbound IPs are not static on the free plan)
4. Database → Connect → Drivers → copy the URI, e.g.

```text
mongodb+srv://USER:PASSWORD@cluster0.xxxxx.mongodb.net/srj_tech?retryWrites=true&w=majority
```

5. Seed once from your machine, pointed at Atlas:

```bash
cd backend
MONGODB_URI="mongodb+srv://USER:PASSWORD@cluster0.xxxxx.mongodb.net/srj_tech?retryWrites=true&w=majority" npm run seed
```

---

## 2) API service (Node)

Render → **New Web Service** → connect the GitHub repo.

| Setting | Value |
|---------|-------|
| Root Directory | `backend` |
| Runtime | Node |
| Build Command | `npm install` |
| Start Command | `npm start` |
| Health Check Path | `/api/health` |

### Environment variables

| Key | Example / notes |
|-----|-----------------|
| `MONGODB_URI` | Atlas connection string |
| `CORS_ORIGIN` | `https://srj-tech-website.onrender.com` |
| `ALLOW_RENDER_HOSTING` | `true` — also allows any `*.onrender.com` origin |
| `SMTP_HOST` | `smtp.gmail.com` |
| `SMTP_PORT` | `465` |
| `SMTP_SECURE` | `true` |
| `SMTP_USER` | `srjtechsupport@gmail.com` |
| `SMTP_PASS` | Gmail App Password |
| `MAIL_FROM` | `SRJ Tech Website <srjtechsupport@gmail.com>` |
| `MAIL_TO` | `srjtechsupport@gmail.com` |
| `MAIL_AUTO_REPLY` | `true` |
| `NODE_ENV` | `production` |

Verify:

```text
https://srj-tech-website-apis.onrender.com/api/health
```

It should report `"database": "connected"`.

---

## 3) Website service (static)

Render → **New Static Site** → same GitHub repo.

| Setting | Value |
|---------|-------|
| Root Directory | *(leave blank — repo root)* |
| Build Command | `./scripts/render_build.sh` |
| Publish Directory | `build/web` |

Add one environment variable so the build knows where the API lives:

| Key | Value |
|-----|-------|
| `API_BASE_URL` | `https://srj-tech-website-apis.onrender.com/api` |

### Redirect/Rewrite rule (required)

`go_router` uses real URL paths, so deep links like `/services` must fall back to
the Flutter entry point. Under **Redirects/Rewrites** add:

| Source | Destination | Action |
|--------|-------------|--------|
| `/*` | `/index.html` | Rewrite |

Without this, refreshing on any page other than `/` returns 404.

### What the build script does

`scripts/render_build.sh` downloads the Flutter SDK (Render has no Flutter
runtime), caches it between deploys, and runs the release build with the
production API URL baked in. It forces the **CanvasKit** renderer because the
HTML renderer does not support `BackdropFilter`, which the site's glassmorphism
panels depend on.

First deploy takes a few minutes while the SDK downloads; later deploys reuse
the cache and are much faster.

---

## 4) Blueprint alternative

`render.yaml` at the repo root defines both services. Render Dashboard → **New**
→ **Blueprint** → select the repo, then fill in the secret values marked
`sync: false`. This creates the API and static site together with the rewrite
rule and cache headers already configured.

---

## 5) Final checklist

1. Atlas seeded and Network Access allows `0.0.0.0/0`
2. `/api/health` reports `"database": "connected"`
3. `CORS_ORIGIN` on the API includes the static site URL
4. `API_BASE_URL` set on the static site before building
5. `/*` → `/index.html` rewrite is active
6. Contact form delivers email (SMTP vars set on the API service)

> Free Render web services sleep after ~15 minutes idle, so the first API call
> after a quiet period takes 30–60s. The static site does not sleep, so pages
> still load instantly.

---

## Local vs production API

| Environment | API base |
|-------------|----------|
| Local | `http://localhost:5001/api` (default) |
| Production | `--dart-define=API_BASE_URL=https://srj-tech-website-apis.onrender.com/api` |

Build locally exactly the way Render does:

```bash
API_BASE_URL=https://srj-tech-website-apis.onrender.com/api ./scripts/render_build.sh
```
