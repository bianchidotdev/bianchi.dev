# Bianchi's Identity Provider

This deploys Pocket ID on Fly.io, using Litestream for SQLite replication to Tigris s3 compatible storage.

## Overview

The setup builds a custom Docker image that bundles:

    Pocket ID: A simple and lightweight OIDC provider.
    Litestream: A tool for replicating SQLite databases to S3.

The application entrypoint is Litestream, which:

    Restores the database from S3 (if it exists).
    Starts replicating changes to the S3 bucket.
    Launches Pocket ID as a subprocess.

This ensures your SQLite database is backed up and can be restored if the Fly machine is restarted or moved.


## Configuration

### Environment Variables

The following environment variables are configured in `fly.yaml`:

| Variable | Description |
|----------|-------------|
| `APP_URL` | The public URL of your Pocket ID instance. |
| `DB_CONNECTION_STRING` | Path to the SQLite database file (`/usr/local/var/data/pocket-id.db`). |
| `FILE_BACKEND` | Set to `s3` to use S3 for file storage (if applicable). |

### Tigris Storage (S3)

With Fly.io, you can use [Tigris](https://fly.io/docs/reference/tigris/) for S3-compatible object storage. This simplifies the setup significantly.

1.  **Create a Tigris bucket**:
    ```sh
    fly storage create
    ```
    This will automatically set the following secrets on your app:
    - `AWS_ACCESS_KEY_ID`
    - `AWS_SECRET_ACCESS_KEY`
    - `AWS_ENDPOINT_URL_S3`
    - `AWS_REGION`
    - `BUCKET_NAME`

2.  **Verify configuration**:
    Ensure your `fly.yaml` environment variables (or secrets) map correctly if the names differ, but by default, Litestream and standard AWS SDKs will pick up `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, and `AWS_ENDPOINT_URL_S3`.

    *Note: The `etc/litestream.yml` in this image expects `BUCKET_NAME` to be set.*

## Deployment

### Manual Deployment

1. **Launch the app** (first time only):
   ```sh
   fly launch --no-deploy
   ```

   *Note: This will generate a `fly.toml` if one doesn't exist, but you should use the provided `fly.yaml` as a base.*

2. **Create the volume**:
   ```sh
   fly volumes create data --size 1
   ```

3. **Set up storage**:
   Run `fly storage create` to provision a Tigris bucket and automatically set the necessary secrets (`AWS_ACCESS_KEY_ID`, etc.).

4. **Set encryption key**
   PocketID requires an encryption key or encryption key file to be set.
   ```sh
   ENCRYPTION_KEY=$(openssl rand -base64 32)
   fly secrets set ENCRYPTION_KEY=${ENCRYPTION_KEY}
   ```

4. **Deploy**:
   ```sh
   fly deploy
   ```


Credit to https://github.com/salekseev/pocket-id-fly
