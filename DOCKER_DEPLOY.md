# Docker Compose Deployment Guide

This guide will help you quickly deploy Nextcloud using Docker Compose with locally built images.

## Quick Start

### Prerequisites

- Docker Engine 20.10 or later
- Docker Compose V2 (comes with Docker Desktop or can be installed separately)

### Step 1: Prepare Environment

1. Clone this repository (if not already done):
   ```bash
   git clone https://github.com/thomelab-codes/forked-docker.git
   cd forked-docker
   ```

2. Copy the example environment file and customize it:
   ```bash
   cp .env.example .env
   ```

3. Edit `.env` file and set your own passwords and configuration:
   ```bash
   nano .env  # or use your preferred editor
   ```

   **Important:** Change all default passwords, especially:
   - `MYSQL_ROOT_PASSWORD`
   - `MYSQL_PASSWORD`
   - `NEXTCLOUD_ADMIN_PASSWORD`

### Step 2: Build and Start Services

Build the Nextcloud images and start all services:

```bash
docker compose up -d
```

This command will:
- Build the Nextcloud Apache image from the Dockerfile in `32/apache/`
- Pull the required database (MariaDB) and Redis images
- Create and start all containers
- Set up the necessary volumes for persistent data

### Step 3: Access Nextcloud

Once the containers are running, access Nextcloud at:

**http://localhost:8080**

(Or the port you configured in `NEXTCLOUD_PORT`)

On first access, Nextcloud will complete its setup automatically using the credentials from your `.env` file.

## Configuration Options

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

## Security Notes

1. **Never commit `.env` file** - It contains sensitive passwords
2. **Change all default passwords** before deployment
3. **Use HTTPS** in production with a reverse proxy
4. **Regular backups** - Back up the Docker volumes regularly
5. **Keep updated** - Regularly update to the latest Nextcloud version

## Support

For more information:
- [Nextcloud Documentation](https://docs.nextcloud.com/)
- [Docker Hub - Nextcloud](https://hub.docker.com/_/nextcloud)
- [GitHub Issues](https://github.com/thomelab-codes/forked-docker/issues)

## Examples

More advanced deployment examples can be found in the `.examples/` directory, including:
- FPM with Nginx
- Nginx reverse proxy configurations
- Additional security configurations
