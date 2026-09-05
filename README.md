# immich-config

Immich photo server running on **gpu-server** (mathis@gpu-server, ThinkStation P520, Ubuntu 26.04).

## Layout

- Photos live on the 1TB USB disk (UUID `6a664797-e80f-4011-82dd-860d4b9b4a55`), mounted at
  `/mnt/immich_external` via `/etc/fstab`.
  - `library/` — 138G Immich media library (`UPLOAD_LOCATION`)
  - `postgres/` — Postgres 14 data dir (`DB_DATA_LOCATION`)
- Compose files deployed at `~/immich/` on gpu-server (copies of `docker-compose.yml` + `.env` here).
- Immich pinned to `v3.1.0` (upgraded from v2.4-era DB on 2026-09-05; VectorChord migration completed).
- Docker has a systemd override (`/etc/systemd/system/docker.service.d/require-immich-disk.conf`)
  so it will not start unless the USB disk is mounted — prevents Postgres from initialising an
  empty DB if the disk is missing at boot.
- DB backup: `pg_dumpall` snapshot at `/mnt/bulk/immich-db-backups/` on gpu-server.

## Access

- Web / API (over Tailscale): http://gpu-server:2283
- Log in with the existing admin account (13k+ assets).
- Password reset if needed:
  `sudo docker exec -it immich_server immich-admin reset-admin-password`

## Upgrading

```sh
# on gpu-server, in ~/immich
sudo docker compose pull && sudo docker compose up -d
```

Check release notes for breaking changes first and bump `IMMICH_VERSION` in `.env`
(here and on the server).

⚠️ `format.sh` formats /dev/sda2 — that is now the photo disk. Do not run it.
