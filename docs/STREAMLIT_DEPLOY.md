# Deploy on Streamlit Community Cloud (free)

One public URL, no AWS. Uses `streamlit_app.py` (API + UI in one app).

**Note:** Free apps **sleep after 12 hours** with no visitors. First open after sleep takes **1–2 minutes** to wake (click “Yes, get this app back up!”).

---

## Step 1 — Push code to GitHub

Do **not** commit `.env` (OpenAI key).

```bash
cd /Users/lokeshadda/Downloads/ai-incident-resolution
chmod +x scripts/push-to-github.sh
./scripts/push-to-github.sh
```

Create the repo on GitHub first if needed: https://github.com/new → name `ai-incident-resolution` → empty repo → then run the script.

Confirm: https://github.com/lokeshadda/ai-incident-resolution shows your files and **no** `.env`.

---

## Step 2 — Sign in to Streamlit Cloud

1. Open https://share.streamlit.io
2. Click **Sign in** → **Continue with GitHub**
3. Authorize Streamlit to access your GitHub account

---

## Step 3 — Create the app

1. Click **Create app**
2. **Repository:** `lokeshadda/ai-incident-resolution`
3. **Branch:** `main`
4. **Main file path:** `streamlit_app.py` ← important (not `ui/app.py`)
5. **App URL (optional):** pick a name, e.g. `lokesh-incident-agent` → `https://lokesh-incident-agent.streamlit.app`

---

## Step 4 — Advanced settings

Click **Advanced settings**:

| Setting | Value |
|---------|--------|
| Python version | **3.11** |
| Dependencies file | `requirements.txt` (default) |

---

## Step 5 — Secrets (OpenAI key)

Before or after deploy, open **Settings → Secrets** and paste:

```toml
OPENAI_API_KEY = "sk-your-actual-key-here"
API_URL = "http://localhost:8001"
API_PORT = "8001"
```

Use your real key from local `.env`. Never commit it to GitHub.

Click **Save**.

---

## Step 6 — Deploy and wait

1. Click **Deploy**
2. Watch **Logs** — first deploy can take **3–5 minutes** (install + dependencies)
3. When status is **Running**, open your app URL

---

## Step 7 — Test the live app

Send:

```text
payment-db is throwing too many clients error after deployment. Severity is high.
```

You should see:

- Agent **trace**
- **Root cause** and confidence
- **Approve & Unlock Fix Steps** (remediation hidden until approved)

---

## Step 8 — Update submission report

In `docs/SUBMISSION_REPORT.md`, set:

```markdown
| Live system (Streamlit Cloud) | https://your-app-name.streamlit.app |
```

Commit and push if you like.

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| “Cannot reach the API” | Main file must be **`streamlit_app.py`** |
| `OPENAI_API_KEY not set` | Add Secrets (Step 5) → Reboot app |
| App shows “Zzz” / sleeping | Normal after 12h idle — open URL and click wake button |
| First message very slow | Normal — embedding model + Chroma index on cold start |
| `😦 Oh no` / memory error | Redeploy with Python **3.11**; free tier ~1 GB RAM |
| Import errors | Repo root must contain `agents/`, `api/`, `graph/`, `knowledge_base/` |

**Reboot:** App menu (⋮) → **Reboot app** after changing secrets or code.

---

## What reviewers should know

Add one line in your report or presentation:

> Live demo on Streamlit Cloud; the app may sleep after 12 hours of inactivity and takes 1–2 minutes to wake on first visit.
