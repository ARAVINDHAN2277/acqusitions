# Acquisitions App - Docker Deployment

Complete Docker setup for development and production environments with Neon Database.

## 🏗️ Architecture

### Development (Neon Local)
```
Your App ──────> Neon Local ──────> Neon Cloud
(Container)      (Proxy)            (Ephemeral Branch)
```

### Production (Neon Cloud)
```
Your App ──────────────────> Neon Cloud Database
(Container)      (Direct Connection)
```

## 🚀 Quick Start

### Development
```bash
# 1. Copy environment template
cp .env.example .env.development

# 2. Add your Neon credentials to .env.development
# 3. Start development environment
docker-compose -f docker-compose.dev.yml up --build
```

### Production
```bash
# 1. Copy environment template
cp .env.example .env.production

# 2. Add your production Neon URL to .env.production  
# 3. Start production environment
docker-compose -f docker-compose.prod.yml up -d --build
```

## 📁 Docker Files Structure

```
acquisitions/
├── Dockerfile                 # Multi-stage build for dev/prod
├── docker-compose.dev.yml     # Development with Neon Local
├── docker-compose.prod.yml    # Production with Neon Cloud
├── .env.development          # Dev environment variables
├── .env.production          # Prod environment variables
├── .dockerignore           # Optimize Docker builds
├── docker.sh              # Linux/Mac helper script
├── docker.ps1             # Windows PowerShell helper script
├── QUICKSTART.md          # 5-minute setup guide
└── DOCKER_SETUP.md        # Comprehensive documentation
```

## 🛠️ Helper Scripts

### Windows (PowerShell)
```powershell
# Start development
.\docker.ps1 up dev

# View logs
.\docker.ps1 logs dev

# Run migrations
.\docker.ps1 migrate dev

# Stop services
.\docker.ps1 down dev
```

### Linux/Mac (Bash)
```bash
# Make executable (first time)
chmod +x docker.sh

# Start development  
./docker.sh up dev

# View logs
./docker.sh logs dev

# Run migrations
./docker.sh migrate dev

# Stop services
./docker.sh down dev
```

## 🔑 Environment Variables

### Development (.env.development)
```bash
NEON_API_KEY=your_neon_api_key
NEON_PROJECT_ID=your_project_id  
PARENT_BRANCH_ID=your_main_branch_id
DATABASE_URL=postgres://neon:npg@neon-local:5432/neondb?sslmode=require
```

### Production (.env.production)
```bash
NODE_ENV=production
DATABASE_URL=postgres://user:pass@your-endpoint.neon.tech/dbname?sslmode=require
```

## 📚 Documentation

- **[QUICKSTART.md](./QUICKSTART.md)** - Get running in 5 minutes
- **[DOCKER_SETUP.md](./DOCKER_SETUP.md)** - Comprehensive guide
- **[Neon Local Docs](https://neon.com/docs/local/neon-local)** - Official documentation

## 🆘 Common Issues

### Container won't start
```bash
# Check Docker is running
docker ps

# Check logs
docker-compose -f docker-compose.dev.yml logs
```

### Database connection failed
```bash
# Verify Neon Local is running
docker ps | grep neon-local

# Check Neon Local logs
docker-compose -f docker-compose.dev.yml logs neon-local
```

### Port conflicts
```bash
# Windows - find what's using port
netstat -ano | findstr :3000

# Linux/Mac - find what's using port  
lsof -i :3000
```

## 🔧 Manual Commands

If you prefer manual Docker commands over the helper scripts:

```bash
# Development
docker-compose -f docker-compose.dev.yml up --build
docker-compose -f docker-compose.dev.yml down
docker-compose -f docker-compose.dev.yml logs -f app
docker-compose -f docker-compose.dev.yml exec app npm run db:migrate

# Production
docker-compose -f docker-compose.prod.yml up -d --build
docker-compose -f docker-compose.prod.yml down
docker-compose -f docker-compose.prod.yml logs -f app
```

## 🚀 Deployment

### Cloud Platforms

**AWS ECS/Fargate:**
- Push to ECR
- Use AWS Secrets Manager for DATABASE_URL

**Google Cloud Run:**
- Build with Cloud Build
- Use Secret Manager for secrets

**Kubernetes:**
- Create secrets: `kubectl create secret generic neon-db --from-literal=database-url='postgres://...'`

**PaaS (Heroku, Railway, Render):**
- Set DATABASE_URL as environment variable
- Deploy directly from Git

## 🎯 Benefits

### Development
- ✅ Automatic ephemeral database branches
- ✅ No manual cleanup needed  
- ✅ Fresh database on every restart
- ✅ Isolated development environment

### Production  
- ✅ Direct connection to Neon Cloud
- ✅ Full Neon features (autoscaling, branching)
- ✅ Production-optimized container
- ✅ Health checks and restart policies

---

**Need help?** Check [DOCKER_SETUP.md](./DOCKER_SETUP.md) for detailed troubleshooting.