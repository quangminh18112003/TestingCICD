CI / CD for UniClub (GitHub Actions)
=================================

Quick summary
-------------
- `ci.yml` runs on push & PR to `main`:
  - backend unit tests (Maven)
  - frontend install & build (pnpm)
  - integration tests with MySQL service (runs `mvn verify` in `uniclub-be`)
- `cd.yml` runs on pushes to `main` and builds Docker images for backend and frontend. It will attempt to push images to GitHub Container Registry (GHCR) if you set `GHCR_TOKEN` in repository secrets.

Setup / required secrets
------------------------
- GHCR (optional - to push images):
  - `GHCR_TOKEN` — a personal access token with `write:packages` (or you can use `${{ secrets.GITHUB_TOKEN }}` with proper repo permissions).
- If you prefer Docker Hub, add `DOCKERHUB_USERNAME` and `DOCKERHUB_PASSWORD` and update `.github/workflows/cd.yml` steps accordingly.

Integration tests
-----------------
- The integration job uses a MySQL service provided by the runner. Tests in `uniclub-be` will be executed against `jdbc:mysql://127.0.0.1:3306/uniclub` with username `root` and password `root`.
- If your tests require other environment configuration (different DB port, additional services, or secrets), update the `integration-tests` job in `.github/workflows/ci.yml` and add required secrets in the repository's settings.

Notes
-----
- CI focuses on running the project's build and tests; please review the test settings or add a dedicated Maven profile for DB-backed integration tests for more control.
- If you want me to also add a CodeQL scan, secret detection, or Docker push to Docker Hub instead of GHCR, tell me which option you prefer and I will add it.
