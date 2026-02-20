# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

HSF Training lesson: "Introduction to Databases for HEP" — a Jupyter Book 2.x (MyST Markdown) educational curriculum teaching database fundamentals (MySQL, SQLite, OpenSearch) with applications in High Energy Physics and Nuclear Physics.

**Status:** Pre-alpha. Published at https://hsf-training.github.io/hsf-training-databases-basics/

## Build and Development Commands

Activate the virtual environment first, then:

```bash
make jb-build           # Build Jupyter Book site (HTML output in _build/)
make jb-start           # Start Jupyter Book dev server with live reload
make jb-clean           # Remove _build/ directory
```

Or directly:
```bash
jupyter-book build --html
jupyter-book start
```

## Pre-commit Hooks

Required before committing:
```bash
pip3 install pre-commit && pre-commit install
```

Hooks enforce: trailing whitespace removal, end-of-file newlines, codespell (dictionary overrides in `codespell.txt`), and `blacken-docs` for Python code blocks in Markdown. Run manually with `pre-commit run -a`.

## Architecture

- **`myst.yml`** — Jupyter Book 2.x configuration: project metadata, table of contents, and site settings.
- **`_episodes/`** — Lesson content as numbered MyST Markdown files (`NN-topic.md`, e.g. `02-sql-basics.md`). Each has YAML front matter with title, teaching time, and exercises. Questions, objectives, and keypoints are rendered as admonition blocks. Episodes are listed in the TOC in `myst.yml`.
- **`_extras/`** — Supplementary pages (about, discussion, instructor guide).
- **`fig/`** — Figures and diagrams referenced by episodes.
- **`Makefile`** — Jupyter Book build commands.
- **`.devcontainer/`** — GitHub Codespaces config with Docker Compose services: MySQL (3306), OpenSearch (9200, 9600), Grafana (3000).
- **`_build/`** — Generated output (gitignored, never edit directly).

## Content Conventions

- Episodes use MyST directive syntax for admonitions:
  - `:::{note}` for callouts/informational boxes
  - `:::{important}` for prerequisites
  - `:::::{admonition} Title` with `:class: challenge` for exercises, containing nested `::::{admonition} Solution` with `:class: dropdown` for collapsible solutions
- Code output is shown in `` ```text `` fenced blocks.
- Mark incomplete sections with `FIXME`.
- New episodes must follow the `NN-topic.md` naming pattern with two-digit ordering prefix and be added to the TOC in `myst.yml`.
- Several files are centrally maintained by the HSF Training organization (marked with `CENTRALLY MAINTAINED` comments) — avoid modifying these: `.pre-commit-config.yaml` (partially), `.github/config.yml`, `.github/stale.yml`.

## Commit and PR Guidelines

- Short, imperative commit messages with optional scope prefix (`docs:`, `build:`, `setup:`).
- Reference issues with `#123`.
- Run `jupyter-book build --html` to verify the site builds before opening PRs.
- Never commit `_build/` contents.
