# Deploy as a live system

Two supported paths. Pick based on how much control you need.

| Option | Best for | Public URL | Cost (typical) |
|--------|----------|------------|----------------|
| **Streamlit Community Cloud** | Fast demo, assignments, low ops | `https://<app>.streamlit.app` | Free tier |
| **AWS EC2** (this repo) | Full control, custom domain, HTTPS | `http://<public-ip>` | ~$15–20/mo (`t3.small`) |

Both need an **OpenAI API key** in secrets (never commit `.env`).

---

## Before you deploy

1. **Push code to GitHub** (example: `lokeshadda/ai-incident-resolution`).
2. Confirm `.env` is **not** tracked (listed in `.gitignore`).
3. Include recent fixes (e.g. project-local chat DB in `ui/app.py`).
4. Runbooks under `knowledge_base/docs/` must be in the repo. `chroma_db/` is rebuilt on first request.

```bash
cd ai-incident-resolution
git init   # if needed
git add .
git commit -m "Prepare for deployment"
git remote add origin https://github.com/lokeshadda/ai-incident-resolution.git
git push -u origin main
```

---

## Option A — Streamlit Community Cloud (fastest)

Single app: `streamlit_app.py` starts FastAPI on port 8001 and the UI on 8501 in one process.

1. Go to [share.streamlit.io](https://share.streamlit.io) → **Create app**.
2. Connect GitHub → repo **`lokeshadda/ai-incident-resolution`** → branch **`main`**.
3. **Main file path:** `streamlit_app.py`
4. **Advanced settings → Python:** `3.11`
5. **Secrets** (paste TOML):

```toml
OPENAI_API_KEY = "sk-your-key-here"
API_URL = "http://localhost:8001"
API_PORT = "8001"
```

6. **Deploy**. First cold start may take **1–3 minutes** (embedding model + Chroma index).

**Verify:** Open the app URL → send a sample incident → see trace and diagnosis → **Approve & Unlock Fix Steps**.

**Limits:** ~1 GB RAM on free tier; large embedding loads can OOM — use Python 3.11 and retry if the app sleeps.

**Troubleshooting:**

| Issue | Fix |
|-------|-----|
| Cannot reach the API | Main file must be `streamlit_app.py`, not `ui/app.py` |
| `OPENAI_API_KEY not set` | Add secret in app Settings → Secrets |
| Slow first message | Normal — KB warmup on first `/incident` |

---

## Option B — AWS EC2 (same style as `http://44.192.117.195`)

Your friend’s link is a **public EC2 IP** with **nginx on port 80** → Streamlit UI, FastAPI on localhost:8001. The app stays **always on** (no 12-hour sleep like Streamlit Cloud).

You get the same setup: open `http://<YOUR_PUBLIC_IP>` after deploy and put that URL in `docs/SUBMISSION_REPORT.md`.

Ubuntu 22.04, nginx on port 80, API + Streamlit on localhost only, systemd services.

### Prerequisites

- AWS CLI configured: `aws configure`
- EC2 **key pair** in your region
- OpenAI API key

### Deploy from your laptop

```bash
cd deploy/aws
chmod +x deploy.sh scripts/bootstrap.sh

export AWS_REGION=us-east-1
export KEY_PAIR=your-ec2-key-name
export OPENAI_API_KEY=sk-your-key-here
export SSH_CIDR=YOUR_PUBLIC_IP/32   # restrict SSH (recommended)

# Use your GitHub repo (required if not using the default template repo)
export REPO_URL=https://github.com/lokeshadda/ai-incident-resolution.git
export REPO_BRANCH=main

./deploy.sh
```

Wait **10–20 minutes** for bootstrap (`pip install`, first API warmup).

### After deploy

```bash
# Public UI
open http://PUBLIC_IP

# SSH checks
ssh -i ~/your-key.pem ubuntu@PUBLIC_IP
sudo systemctl status ai-incident-api ai-incident-ui nginx
curl -s http://127.0.0.1:8001/health
```

### HTTPS (optional)

Point a domain A record to the instance IP, then on the server:

```bash
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx -d incident.yourdomain.com
```

Open port **443** in the security group.

### Tear down

```bash
aws cloudformation delete-stack --stack-name ai-incident-resolution --region us-east-1
```

### Security note

The OpenAI key is passed via CloudFormation user-data. For production, use **AWS Secrets Manager** + SSM instead of plain user-data.

---

## Option C — API only (Railway)

`railway.toml` deploys **FastAPI only**. You must host the UI separately and set:

```env
API_URL=https://your-railway-app.up.railway.app
```

Use Streamlit Cloud or EC2 for the UI. Not recommended for a single demo URL.

---

## What is *not* persisted on a fresh deploy

| Data | Behavior |
|------|----------|
| In-memory incidents | Lost on API restart |
| Chat history (SQLite) | On Streamlit Cloud, ephemeral filesystem unless you use external storage |
| `chroma_db/` | Rebuilt from `knowledge_base/docs/` |
| Approved incidents | Written under `knowledge_base/docs/resolved/` on disk when approved (EC2); may not survive Streamlit Cloud redeploys |

---

## Update SUBMISSION_REPORT live link

After deploy, set the live URL in `docs/SUBMISSION_REPORT.md`:

- Streamlit: `https://<your-app>.streamlit.app`
- AWS: `http://<elastic-ip>`
