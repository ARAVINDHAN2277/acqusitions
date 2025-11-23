# Docker Management Script for Windows PowerShell
# Usage: .\docker.ps1 <command> [environment]
# Example: .\docker.ps1 up dev

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('up', 'down', 'build', 'logs', 'shell', 'migrate', 'studio', 'restart', 'clean')]
    [string]$Command,
    
    [Parameter(Mandatory=$false)]
    [ValidateSet('dev', 'prod')]
    [string]$Environment = 'dev'
)

$ComposeFile = if ($Environment -eq 'dev') { 'docker-compose.dev.yml' } else { 'docker-compose.prod.yml' }

Write-Host "🐳 Docker Manager - Environment: $Environment" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

switch ($Command) {
    'up' {
        Write-Host "🚀 Starting services..." -ForegroundColor Green
        docker-compose -f $ComposeFile up --build
    }
    'down' {
        Write-Host "🛑 Stopping services..." -ForegroundColor Yellow
        docker-compose -f $ComposeFile down
    }
    'build' {
        Write-Host "🔨 Building containers..." -ForegroundColor Blue
        docker-compose -f $ComposeFile build --no-cache
    }
    'logs' {
        Write-Host "📋 Showing logs..." -ForegroundColor Magenta
        docker-compose -f $ComposeFile logs -f app
    }
    'shell' {
        Write-Host "💻 Opening shell..." -ForegroundColor Cyan
        docker-compose -f $ComposeFile exec app sh
    }
    'migrate' {
        Write-Host "🗄️  Running migrations..." -ForegroundColor Green
        docker-compose -f $ComposeFile exec app npm run db:migrate
    }
    'studio' {
        Write-Host "🎨 Opening Drizzle Studio..." -ForegroundColor Magenta
        docker-compose -f $ComposeFile exec app npm run db:studio
    }
    'restart' {
        Write-Host "🔄 Restarting services..." -ForegroundColor Yellow
        docker-compose -f $ComposeFile restart
    }
    'clean' {
        Write-Host "🧹 Cleaning up..." -ForegroundColor Red
        Write-Host "This will remove all containers, volumes, and images!" -ForegroundColor Red
        $Confirm = Read-Host "Are you sure? (yes/no)"
        if ($Confirm -eq 'yes') {
            docker-compose -f $ComposeFile down -v --rmi all
            Write-Host "✅ Cleanup complete!" -ForegroundColor Green
        } else {
            Write-Host "❌ Cleanup cancelled." -ForegroundColor Yellow
        }
    }
}

Write-Host ""
Write-Host "================================" -ForegroundColor Cyan
Write-Host "✅ Command completed!" -ForegroundColor Green
