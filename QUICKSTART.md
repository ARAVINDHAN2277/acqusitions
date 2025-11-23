# Quick Start Guide

Get your application running with Docker in under 5 minutes!

## 🚀 Development Setup (Fast Track)

### 1. Prerequisites
- Docker Desktop installed and running
- Neon account (free at [console.neon.tech](https://console.neon.tech))

### 2. Get Neon Credentials
Visit [Neon Console](https://console.neon.tech) and grab:
- **API Key** (Settings → API Keys)
- **Project ID** (from project dashboard)
- **Branch ID** (usually `main` or `br-xxx`)

### 3. Configure Environment
Copy the development environment template:

**Windows (PowerShell):**
```powershell
Copy-Item .env.example .env.development
```

**Linux/Mac:**
```bash
cp .env.example .env.development
```

Edit `.env.development` and add your credentials:
```bash
NEON_API_KEY=neon_api_xxxxxxxxxxxxx
NEON_PROJECT_ID=proud-sunset-12345
PARENT_BRANCH_ID=br-main-xxxxxx
```

### 4. Start Development Environment
```bash
docker-compose -f docker-compose.dev.yml up --build
```

### 5. Access Your App
🎉 Your app is now running at **http://localhost:3000**

The Neon Local proxy automatically created an ephemeral database branch for you!

---

## 🏭 Production Setup (Fast Track)

### 1. Get Production Database URL
From [Neon Console](https://console.neon.tech):
- Navigate to your project
- Go to **Connection Details**
- Copy the connection string

### 2. Configure Production Environment
**Windows (PowerShell):**
```powershell
Copy-Item .env.example .env.production
```

**Linux/Mac:**
```bash
cp .env.example .env.production
```

Edit `.env.production`:
```bash
NODE_ENV=production
DATABASE_URL=postgres://user:pass@ep-xxx.neon.tech/dbname?sslmode=require
```

### 3. Deploy
```bash
docker-compose -f docker-compose.prod.yml up -d --build
```

---

## 📝 Common Tasks

### Run Migrations
```bash
# Development
docker-compose -f docker-compose.dev.yml exec app npm run db:migrate

# Production
docker-compose -f docker-compose.prod.yml exec app npm run db:migrate
```

### View Logs
```bash
# Development
docker-compose -f docker-compose.dev.yml logs -f app

# Production
docker-compose -f docker-compose.prod.yml logs -f app
```

### Stop Services
```bash
# Development
docker-compose -f docker-compose.dev.yml down

# Production
docker-compose -f docker-compose.prod.yml down
```

### Shell Access
```bash
# Development
docker-compose -f docker-compose.dev.yml exec app sh

# Production
docker-compose -f docker-compose.prod.yml exec app sh
```

---

## 🔧 Troubleshooting

### Container won't start
```bash
# Check Docker is running
docker ps

# View detailed logs
docker-compose -f docker-compose.dev.yml logs
```

### Port already in use
```bash
# Windows - find process on port 3000
netstat -ano | findstr :3000

# Linux/Mac - find process on port 3000
lsof -i :3000

# Kill the process or change port in docker-compose file
```

### Database connection failed
1. Verify your credentials in `.env.development`
2. Check Neon Local is running: `docker ps | grep neon-local`
3. View Neon Local logs: `docker-compose -f docker-compose.dev.yml logs neon-local`

---

## 📚 Next Steps

- Read the full [Docker Setup Guide](./DOCKER_SETUP.md) for detailed information
- Learn about [Neon Local features](https://neon.com/docs/local/neon-local)
- Explore [Drizzle ORM documentation](https://orm.drizzle.team)

---

## 🆘 Need Help?

- **Detailed Documentation:** [DOCKER_SETUP.md](./DOCKER_SETUP.md)
- **Neon Discord:** [discord.gg/neon](https://discord.gg/neon)
- **GitHub Issues:** [Your repo issues](https://github.com/ARAVINDHAN2277/acquisitions/issues)
