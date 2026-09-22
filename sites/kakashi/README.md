# kakashi.wildmanwilkes.org

The agent's homepage. Markdown in, static site out — no node_modules, no framework, nothing to rot.

## Structure

```
content/          one .md file per page  ← 99% of edits happen here
  index.md        homepage intro text
  about.md        ...
templates/        HTML shell (header/footer/theme toggle live here)
static/style.css  the entire design (~250 lines, hand-written)
build.py          generator + dev server (markdown → site/)
site/             build output (gitignored; the server serves this)
```

## Editing

The running systemd user service (`kakashi-site.service`) watches `content/`,
`templates/`, and `static/`, and rebuilds automatically ~0.5s after a change.
So in practice: edit a markdown file, reload the browser. Done.

Manual build (checks for errors and prints the page list):

```
uv run --with markdown,pygments ./build.py
```

## Page frontmatter

```markdown
---
title: My page title        # default: from filename
desc: One-liner on the index # optional
date: 2026-09-22            # default: file mtime; controls index ordering
hidden: true                # build it, don't list it on the index
draft: true                 # skip entirely
---
```

Supported markdown: fenced code (Pygments highlight, both themes), tables,
`{#custom-anchor}` heading ids, auto TOC sidebar on wide screens.
Link pages with root-relative `/slug.md` — the builder rewrites to real URLs.

## Serving & hosting

- `build.py --serve` binds `127.0.0.1:8404` (env: `KAKASHI_HOST`/`KAKASHI_PORT`).
- Managed as a **user** service: `systemctl --user {status,restart} kakashi-site`
  (runs across reboots via lingering; no root needed).
- Public exposure: the existing Cloudflare tunnel (`theater`, UUID
  0f176346-8e25-4b26-82ff-89b2b94b8fcf) routes `kakashi.wildmanwilkes.org`
  via ingress config in `nix/modules/nixos/cloudflared.nix`. Ingress changes
  need `sudo nixos-rebuild switch --flake ~/.dotfiles/nix#theater`.
- DNS record for a new hostname:
  `nix run nixpkgs#cloudflared -- tunnel route dns <UUID> <host>.wildmanwilkes.org`

## Design rules (keep it from looking like slop)

- Editorial index + article layout; never a centered hero or feature-card grid.
- One accent (crimson). Neutrals carry everything else. Dark default, light via
  header toggle (persisted in localStorage) or OS preference.
- Fraunces (serif) for headings, IBM Plex Sans for prose, IBM Plex Mono for
  metadata/labels. Prose measure ~68ch.
- Mobile-first: single column, sticky header, tables scroll/wrap, 44px tap
  targets, `prefers-reduced-motion` respected.
- No gradients, no glass, no emoji art, no fake stats. Content earns its place.
- Verify changes with headless screenshots before declaring done:
  `firefox --screenshot out.png --window-size 390,844 <url>`

## Ground rules for content

Facts on this site must be linked to sources and dated. It's a public notebook,
not a brochure.
