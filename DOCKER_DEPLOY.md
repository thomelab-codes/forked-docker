# Docker Compose Deployment Guide

This guide will help you quickly deploy Nextcloud using Docker Compose with official pre-built images from Docker Hub.

## Quick Start

### Prerequisites

- Docker Engine 20.10 or later
- Docker Compose V2 (comes with Docker Desktop or can be installed separately)

### Step 1: Prepare Environment

1. Clone this repository (if not already done):
   ```bash
   git clone <repository-url>
   cd forked-docker
   ```

2. Copy the example environment file and customize it:
   ```bash
   cp .env.example .env
   ```

3. **⚠️ IMPORTANT - Security:** Edit `.env` file and set your own strong passwords:
   ```bash
   nano .env  # or use your preferred editor
   ```

   **You MUST change all default passwords, especially:**
   - `MYSQL_ROOT_PASSWORD` - Use a strong password (20+ characters recommended)
   - `MYSQL_PASSWORD` - Use a strong password (20+ characters recommended)
   - `NEXTCLOUD_ADMIN_PASSWORD` - Use a strong password (20+ characters recommended)

   **DO NOT use the default 'changeme' passwords in production!**

### Step 2: Build and Start Services

Build the Nextcloud images and start all services:

```bash
docker compose up -d
```

This command will:
- Pull the Nextcloud Apache image (version 32) from Docker Hub
- Pull the required database (MariaDB) and Redis images
- Create and start all containers
- Set up the necessary volumes for persistent data

### Step 3: Access Nextcloud

Once the containers are running, access Nextcloud at:

**http://localhost:8080**

(Or the port you configured in `NEXTCLOUD_PORT`)

On first access, Nextcloud will complete its setup automatically using the credentials from your `.env` file.

## Configuration Options

### Building from Source vs Using Pre-built Images

By default, `docker-compose.yml` uses the official pre-built Nextcloud images from Docker Hub, which is faster and more reliable.

If you want to build Nextcloud from the local Dockerfiles in this repository:

```bash
# Use the build variant
docker compose -f docker-compose.build.yml up -d
```

Note: Building from source may fail if there are issues in the Dockerfiles. Use the default `docker-compose.yml` for a more reliable experience.

### Using PostgreSQL Instead of MariaDB

1. Edit `docker-compose.yml`:
   - Comment out the `db` (MariaDB) service
   - Uncomment the `postgres` service
   
2. Update the `app` service environment variables to use PostgreSQL:
   - Change `MYSQL_HOST` to `POSTGRES_HOST`
   - Update other `MYSQL_*` variables to `POSTGRES_*`

3. Update your `.env` file with PostgreSQL credentials

### Changing the Port

To run Nextcloud on a different port, edit the `NEXTCLOUD_PORT` variable in `.env`:

```bash
NEXTCLOUD_PORT=8888
```

### Setting Up Behind a Reverse Proxy

If you're running Nextcloud behind a reverse proxy (like Nginx or Traefik):

1. Update these variables in `.env`:
   ```bash
   OVERWRITEPROTOCOL=https
   OVERWRITEHOST=yourdomain.com
   ```

2. Remove or change the port mapping in `docker-compose.yml`:
   ```yaml
   ports:
     - "127.0.0.1:8080:80"  # Only accessible from localhost
   ```

## Common Commands

### View logs
```bash
docker compose logs -f app
```

### Restart services
```bash
docker compose restart
```

### Stop services
```bash
docker compose down
```

### Stop and remove all data
```bash
docker compose down -v
```
**Warning:** This will delete all data including your Nextcloud files and database!

### Rebuild images after updates
```bash
docker compose build --no-cache
docker compose up -d
```

### Run occ commands
```bash
docker compose exec -u www-data app php occ <command>
```

Example - List users:
```bash
docker compose exec -u www-data app php occ user:list
```

## Upgrading

To upgrade to a newer version of Nextcloud:

1. Stop the services:
   ```bash
   docker compose down
   ```

2. Update the Dockerfile path in `docker-compose.yml` if a new version is available (e.g., change `32/apache/Dockerfile` to `33/apache/Dockerfile`)

3. Rebuild and restart:
   ```bash
   docker compose build --no-cache
   docker compose up -d
   ```

Nextcloud will automatically run database migrations on startup.

## Troubleshooting

### Container won't start

Check logs:
```bash
docker compose logs app
docker compose logs db
```

### Permission issues

Make sure volumes have correct permissions:
```bash
docker compose exec -u www-data app bash
```

### Database connection issues

Verify database is running and healthy:
```bash
docker compose ps
docker compose exec db mysql -u root -p
```

### Reset installation

To start fresh:
```bash
docker compose down -v
rm -rf .env
cp .env.example .env
# Edit .env with new passwords
docker compose up -d
```

## ⚠️ Security Notes

**CRITICAL - Before Production Deployment:**

1. **Never commit `.env` file** - It contains sensitive passwords. The `.gitignore` file is configured to exclude it.
2. **Change ALL default passwords** - The default passwords in `.env.example` are placeholders and MUST be changed:
   - Use passwords with at least 20 characters
   - Include uppercase, lowercase, numbers, and special characters
   - Never use "changeme" or similar weak passwords
3. **Use HTTPS** in production - Deploy behind a reverse proxy (Nginx, Traefik, Caddy) with valid SSL certificates
4. **Regular backups** - Back up the Docker volumes regularly:
   ```bash
   docker run --rm -v forked-docker_nextcloud:/data -v $(pwd):/backup ubuntu tar czf /backup/nextcloud-backup.tar.gz /data
   docker run --rm -v forked-docker_db:/data -v $(pwd):/backup ubuntu tar czf /backup/db-backup.tar.gz /data
   ```
5. **Keep updated** - Regularly update to the latest Nextcloud version and rebuild containers
6. **Limit access** - If not using a reverse proxy, bind to localhost only: `127.0.0.1:8080:80`

## Support

For more information:
- [Nextcloud Documentation](https://docs.nextcloud.com/)
- [Docker Hub - Nextcloud](https://hub.docker.com/_/nextcloud)
- [Nextcloud Community Forum](https://help.nextcloud.com/)

## Examples

More advanced deployment examples can be found in the `.examples/` directory, including:
- FPM with Nginx
- Nginx reverse proxy configurations
- Additional security configurations
