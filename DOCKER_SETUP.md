# Docker Setup with Neon Database

This guide explains how to run the application with Docker using Neon Database for both development and production environments.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Architecture Overview](#architecture-overview)
- [Development Setup (Neon Local)](#development-setup-neon-local)
- [Production Setup (Neon Cloud)](#production-setup-neon-cloud)
- [Environment Variables](#environment-variables)
- [Common Commands](#common-commands)
- [Troubleshooting](#troubleshooting)

---

## Prerequisites

- Docker and Docker Compose installed
- Neon account ([Sign up](https://console.neon.tech))
- Neon API key, Project ID, and Branch ID from your [Neon Console](https://console.neon.tech)

---

## Architecture Overview

### Development Environment
```
┌─────────────────┐         ┌──────────────────┐         ┌─────────────────┐
│   Your App      │ ──────> │   Neon Local     │ ──────> │   Neon Cloud    │
│  (Container)    │         │   (Container)    │         │   (Ephemeral    │
│                 │         │   Proxy          │         │    Branch)      │
└─────────────────┘         └──────────────────┘         └─────────────────┘
```

**Benefits:**
- Automatic ephemeral branch creation for each dev session
- No manual database cleanup needed
- Branch lifecycle tied to Docker container lifecycle
- Fresh database copy on each restart

### Production Environment
```
┌─────────────────┐
│   Your App      │ ────────────────────> Neon Cloud Database
│  (Container)    │         Direct Connection
└─────────────────┘
```

**Benefits:**
- Direct connection to production database
- No intermediary proxy overhead
- Full Neon Cloud features (autoscaling, branching, etc.)

---

## Development Setup (Neon Local)

### Step 1: Get Your Neon Credentials

1. Go to [Neon Console](https://console.neon.tech)
2. Select your project
3. Navigate to **Settings** → **API Keys** to get your API key
4. Copy your **Project ID** from the project dashboard
5. Copy your **Branch ID** (usually `main` branch) to use as parent branch

### Step 2: Configure Development Environment

Create or update `.env.development`:

```bash
# Neon Configuration
NEON_API_KEY=your_actual_api_key_here
NEON_PROJECT_ID=your_project_id_here
PARENT_BRANCH_ID=your_main_branch_id_here

# Database URL (Neon Local)
DATABASE_URL=postgres://neon:npg@neon-local:5432/neondb?sslmode=require

# Application
NODE_ENV=development
PORT=3000
```

### Step 3: Start Development Environment

```bash
# Build and start all services
docker-compose -f docker-compose.dev.yml up --build

# Or run in detached mode
docker-compose -f docker-compose.dev.yml up -d --build
```

### Step 4: Run Database Migrations (if needed)

```bash
# Generate migrations
docker-compose -f docker-compose.dev.yml exec app npm run db:generate

# Run migrations
docker-compose -f docker-compose.dev.yml exec app npm run db:migrate

# Open Drizzle Studio
docker-compose -f docker-compose.dev.yml exec app npm run db:studio
```

### Step 5: Access Your Application

- Application: http://localhost:3000
- Neon Local Postgres: `localhost:5432` (from host machine)

### How Ephemeral Branches Work

When you start the development environment:

1. Neon Local container starts
2. Automatically creates a new branch from `PARENT_BRANCH_ID`
3. Your app connects to this ephemeral branch via the proxy
4. When you stop the container, the branch is automatically deleted

This ensures you always have a clean database state for testing!

---

## Production Setup (Neon Cloud)

### Step 1: Get Your Production Database URL

1. Go to [Neon Console](https://console.neon.tech)
2. Select your project
3. Navigate to **Connection Details**
4. Copy the **Connection String** for your production branch

Example format:
```
postgres://username:password@ep-example-123456.us-east-2.aws.neon.tech/dbname?sslmode=require
```

### Step 2: Configure Production Environment

Create or update `.env.production`:

```bash
# Database URL (Neon Cloud - Direct Connection)
DATABASE_URL=postgres://username:password@your-endpoint.neon.tech/dbname?sslmode=require

# Application
NODE_ENV=production
PORT=3000

# Other production secrets
JWT_SECRET=your_production_jwt_secret
```

**⚠️ SECURITY WARNING:** Never commit `.env.production` with real credentials! Use your deployment platform's secret management instead.

### Step 3: Deploy to Production

#### Using Docker Compose (Local Production Test)

```bash
# Build and start production container
docker-compose -f docker-compose.prod.yml up --build

# Or run in detached mode
docker-compose -f docker-compose.prod.yml up -d --build
```

#### Using Docker (Manual Deployment)

```bash
# Build production image
docker build --target production -t acquisitions:latest .

# Run container with environment variables
docker run -d \
  --name acquisitions-prod \
  -p 3000:3000 \
  -e DATABASE_URL="your_neon_cloud_url" \
  -e NODE_ENV=production \
  acquisitions:latest
```

#### Cloud Deployment Examples

**AWS ECS/Fargate:**
```bash
# Tag and push to ECR
docker tag acquisitions:latest 123456789.dkr.ecr.us-east-1.amazonaws.com/acquisitions:latest
docker push 123456789.dkr.ecr.us-east-1.amazonaws.com/acquisitions:latest

# Use AWS Secrets Manager for DATABASE_URL
```

**Google Cloud Run:**
```bash
# Build and deploy
gcloud builds submit --tag gcr.io/PROJECT_ID/acquisitions
gcloud run deploy acquisitions \
  --image gcr.io/PROJECT_ID/acquisitions \
  --platform managed \
  --set-env-vars NODE_ENV=production \
  --set-secrets DATABASE_URL=neon-db-url:latest
```

**Kubernetes:**
```yaml
# Use Kubernetes Secrets
kubectl create secret generic neon-db \
  --from-literal=database-url='postgres://...'
```

---

## Environment Variables

### Required Variables

| Variable | Development | Production | Description |
|----------|-------------|------------|-------------|
| `NEON_API_KEY` | ✅ Required | ❌ Not used | Your Neon API key for local proxy |
| `NEON_PROJECT_ID` | ✅ Required | ❌ Not used | Your Neon project ID |
| `PARENT_BRANCH_ID` | ✅ Required | ❌ Not used | Parent branch for ephemeral branches |
| `DATABASE_URL` | ✅ Local proxy | ✅ Cloud URL | Database connection string |
| `NODE_ENV` | development | production | Environment mode |
| `PORT` | 3000 | 3000 | Application port |

### Optional Variables

Add any application-specific variables to your `.env.*` files:
- `JWT_SECRET`
- `API_KEYS`
- `FEATURE_FLAGS`
- etc.

---

## Common Commands

### Development

```bash
# Start services
docker-compose -f docker-compose.dev.yml up

# Start in background
docker-compose -f docker-compose.dev.yml up -d

# Stop services
docker-compose -f docker-compose.dev.yml down

# View logs
docker-compose -f docker-compose.dev.yml logs -f app

# Rebuild containers
docker-compose -f docker-compose.dev.yml up --build

# Run commands in app container
docker-compose -f docker-compose.dev.yml exec app npm run lint
docker-compose -f docker-compose.dev.yml exec app npm run db:studio

# Shell access
docker-compose -f docker-compose.dev.yml exec app sh
```

### Production

```bash
# Start services
docker-compose -f docker-compose.prod.yml up -d

# Stop services
docker-compose -f docker-compose.prod.yml down

# View logs
docker-compose -f docker-compose.prod.yml logs -f app

# Rebuild containers
docker-compose -f docker-compose.prod.yml up -d --build
```

### Cleanup

```bash
# Remove all containers and volumes
docker-compose -f docker-compose.dev.yml down -v

# Remove all images
docker-compose -f docker-compose.dev.yml down --rmi all

# Prune unused Docker resources
docker system prune -a
```

---

## Troubleshooting

### Issue: Cannot connect to Neon Local

**Symptoms:**
```
Error: connect ECONNREFUSED 127.0.0.1:5432
```

**Solutions:**
1. Check if Neon Local container is running:
   ```bash
   docker ps | grep neon-local
   ```

2. Verify environment variables are set correctly in `.env.development`

3. Check Neon Local logs:
   ```bash
   docker-compose -f docker-compose.dev.yml logs neon-local
   ```

4. Ensure health check is passing:
   ```bash
   docker inspect neon-local-dev | grep -A 10 Health
   ```

### Issue: Self-signed certificate error

**Symptoms:**
```
Error: self signed certificate
```

**Solutions:**
1. For JavaScript apps, ensure your database config includes:
   ```javascript
   ssl: {
     rejectUnauthorized: false
   }
   ```

2. Use the updated database configuration provided in `src/config/database.dev.js`

### Issue: Neon API authentication failed

**Symptoms:**
```
Error: Invalid API key or Project ID
```

**Solutions:**
1. Verify your credentials in [Neon Console](https://console.neon.tech)
2. Regenerate API key if necessary
3. Double-check `.env.development` has correct values
4. Ensure no extra spaces or quotes around values

### Issue: Port already in use

**Symptoms:**
```
Error: Bind for 0.0.0.0:5432 failed: port is already allocated
```

**Solutions:**
1. Check what's using the port:
   ```bash
   # Windows
   netstat -ano | findstr :5432
   
   # Linux/Mac
   lsof -i :5432
   ```

2. Stop conflicting service or change port in `docker-compose.dev.yml`:
   ```yaml
   ports:
     - '5433:5432'  # Use different host port
   ```

### Issue: Volume permissions (Linux/Mac)

**Symptoms:**
```
Error: EACCES: permission denied
```

**Solutions:**
1. Fix ownership:
   ```bash
   sudo chown -R $USER:$USER .
   ```

2. Or run with proper user in docker-compose:
   ```yaml
   user: "${UID}:${GID}"
   ```

### Issue: Production database connection failed

**Symptoms:**
```
Error: Connection terminated unexpectedly
```

**Solutions:**
1. Verify DATABASE_URL is correct in `.env.production`
2. Check Neon Console for database status
3. Ensure `sslmode=require` is in connection string
4. Verify network/firewall allows outbound connections to neon.tech

---

## Additional Resources

- [Neon Documentation](https://neon.com/docs)
- [Neon Local Documentation](https://neon.com/docs/local/neon-local)
- [Docker Documentation](https://docs.docker.com)
- [Drizzle ORM Documentation](https://orm.drizzle.team)

---

## Support

If you encounter issues not covered here:

1. Check [Neon Discord](https://discord.gg/neon)
2. Review [Neon GitHub Issues](https://github.com/neondatabase/neon)
3. Consult [Docker Community Forums](https://forums.docker.com)
