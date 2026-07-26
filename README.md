# SRJ Tech Website

Dynamic company website for **SRJ Tech**, built with:

- **Flutter Web** — Material 3 UI, `go_router`, animated sections
- **Node.js + Express** — REST API
- **MongoDB** — company profile, pages, services, contact messages

## Project structure

```
├── lib/                 # Flutter web frontend
├── web/                 # Flutter web host
├── backend/             # Node.js API + MongoDB
└── README.md
```

## Pages (v1)

| Route | Page |
|-------|------|
| `/` | Home |
| `/about` | About |
| `/services` | Services |
| `/contact` | Contact form |

## Prerequisites

- Flutter SDK (web enabled)
- Node.js 18+
- MongoDB running locally

## Setup

See **[DEPLOY.md](./DEPLOY.md)** for the production deploy (API + website on Render).

### 1. Start MongoDB

```bash
mongod
```

### 2. Backend

```bash
cd backend
cp .env.example .env
npm install
npm run seed
npm run dev
```

API runs at `http://localhost:5001`

### Enable email delivery (contact form → company inbox)

Contact form submissions are emailed to `srjtechsupport@gmail.com`.

1. Open Google Account → **Security** → turn on **2-Step Verification**
2. Create an **App Password** for Mail
3. Put it in `backend/.env`:

```bash
SMTP_USER=srjtechsupport@gmail.com
SMTP_PASS=your_16_char_app_password
MAIL_TO=srjtechsupport@gmail.com
```

4. Restart the API (`npm run dev`)

Visitors also get an automatic “we received your message” reply (disable with `MAIL_AUTO_REPLY=false`).

### 3. Frontend

From the project root:

```bash
flutter pub get
flutter run -d chrome --web-port=8080
```

Optional: point to another API host:

```bash
flutter run -d chrome --web-port=8080 \
  --dart-define=API_BASE_URL=http://localhost:5001/api
```

## API endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/health` | Health check |
| GET | `/api/company` | Company profile |
| GET | `/api/pages` | Page list |
| GET | `/api/pages/:slug` | Page content |
| GET | `/api/services` | Services list |
| GET | `/api/contact/details` | Public contact channels & hours |
| POST | `/api/contact` | Submit contact inquiry |
| GET | `/api/contact/messages` | List inquiries (internal) |
| PATCH | `/api/contact/messages/:id/status` | Update inquiry status |

## Updating content

Edit seed data in `backend/src/seed/seed.js`, then re-run:

```bash
cd backend && npm run seed
```

Or update documents directly in MongoDB (`srj_tech` database).

## Next steps

After this foundation is running, we can add:

- Portfolio / case studies
- Team page
- Blog / insights
- Admin CMS for editing content
- Email notifications for contact form
