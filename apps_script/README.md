# Apps Script

The backend is a Google Apps Script web app writing to a Google Sheet. Its
source lives in the Apps Script editor, not here — these files are the
changes that have to be pasted in, kept alongside the app so the two do not
drift apart.

| File | What it does |
|---|---|
| `security.gs` | Server side sign in, signed tokens, per player data scoping |
| `combined_endpoint.gs` | `?all=true`, which returns every list in one request |

## Order matters

The script must be deployed **before** the matching app build reaches
anyone. The app calls endpoints that an older deployment does not have, so
installing the app first means nobody can sign in.

1. Paste and deploy `security.gs`, leaving `ENFORCE_AUTH` set to `false`.
   Nothing changes for anyone yet — requests without a token still work, so
   every copy of the app already out there keeps running.
2. Build and hand out the new app. It signs in against the script and
   starts sending tokens.
3. Once everyone has updated, set `ENFORCE_AUTH` to `true` in
   **Project Settings → Script Properties**. Anonymous access stops from
   that moment. No redeploy is needed, and setting it back to `false`
   reverses it.

## Redeploying

**Deploy → Manage deployments → pencil → Version: New version → Deploy.**

Keep the *same* deployment. A new deployment gets a new URL, and the URL is
compiled into every installed copy of the app — changing it breaks all of
them at once.

## The coach code

It is not in this repository and must never be. It lives in Script
Properties, which the app never reads.

The code that used to be hardcoded in the app is in this repository's git
history permanently, and the repository is public. It has to be treated as
publicly known. Whatever replaces it must be a **different value** — moving
the same string into Script Properties fixes nothing.

## Checking it works

With `ENFORCE_AUTH` off, this should return the data:

```
<exec url>?all=true
```

With it on, the same URL should return:

```json
{"status":"error","code":"AUTH_REQUIRED","message":"Please sign in again."}
```

That is the whole point — a bare URL stops being enough.
