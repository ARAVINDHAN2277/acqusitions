# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

Node.js REST API built with Express.js, featuring user authentication with JWT tokens stored in HTTP-only cookies. Uses Drizzle ORM with Neon PostgreSQL database and Arcjet for security (bot detection, rate limiting, shield protection).

## Development Commands

### Running the Application
```bash
npm run dev              # Start dev server with --watch (auto-reloads on changes)
```

### Database Operations
```bash
npm run db:generate      # Generate Drizzle migrations from schema changes
npm run db:migrate       # Apply pending migrations to database
npm run db:studio        # Open Drizzle Studio for database GUI
```

### Code Quality
```bash
npm run lint             # Check for linting errors
npm run lint:fix         # Auto-fix linting errors
npm run format           # Format all files with Prettier
npm run format:check     # Check formatting without making changes
```

## Architecture

### Application Structure

**Layered MVC Architecture:**
- **Routes** → **Controllers** → **Services** → **Models**
- Controllers handle HTTP requests/responses and validation
- Services contain business logic and database operations
- Models define database schema (Drizzle ORM)

### Module Import Aliases

Uses Node.js subpath imports (package.json `imports` field):
- `#config/*` → `./src/config/*`
- `#controllers/*` → `./src/controllers/*`
- `#middleware/*` → `./src/middleware/*`
- `#models/*` → `./src/models/*`
- `#routes/*` → `./src/routes/*`
- `#services/*` → `./src/services/*`
- `#utils/*` → `./src/utils/*`
- `#validations/*` → `./src/validations/*`

**Always use these aliases** when importing from `src/`.

### Entry Points

1. `src/index.js` - Loads environment variables and imports server
2. `src/server.js` - Starts Express server on PORT (default 3000)
3. `src/app.js` - Configures Express middleware, security, and routes

### Security Architecture

**Arcjet Integration** (`src/config/arcjet.js`):
- Shield protection (suspicious request detection)
- Bot detection (allows search engines and previews)
- Global rate limiting: 5 requests per 2 seconds

**Dynamic Rate Limiting** (`src/middleware/security.middleware.js`):
- Applied per request based on user role
- Admin: 20 req/min
- User: 10 req/min
- Guest: 5 req/min

**Authentication** (`src/middleware/auth.middleware.js`):
- JWT tokens stored in HTTP-only cookies (cookie name: `token`)
- `authenticateToken` - Validates token from cookies
- `requireRole(allowedRoles)` - Role-based access control

### Database

**ORM:** Drizzle with Neon serverless PostgreSQL
**Schema location:** `src/models/*.js`
**Migration output:** `./drizzle/`

**User Model** (`src/models/user.model.js`):
```
users table:
- id (serial, primary key)
- name, email (unique), password (hashed with bcrypt)
- role (varchar, default 'user')
- created_at, updated_at (timestamps)
```

### Validation

Uses Zod schemas in `src/validations/*.js`. Validation errors formatted with `formatValidationError` utility before returning to client.

### Logging

Winston logger (`src/config/logger.js`):
- Logs to `logs/error.lg` and `logs/combined.log`
- Console output in non-production environments
- Default level: `info` (configurable via `LOG_LEVEL` env var)

### API Endpoints

**Public routes:**
- `GET /` - Hello world
- `GET /health` - Health check with uptime
- `GET /api` - API status

**Auth routes** (`/api/auth`):
- `POST /api/auth/sign-up` - User registration
- `POST /api/auth/sign-in` - User login
- `POST /api/auth/sign-out` - User logout

**User routes** (`/api/users`):
- Protected with `authenticateToken` middleware

## Code Style

### ESLint Rules
- **Indentation:** 2 spaces (with SwitchCase: 1)
- **Quotes:** Single quotes
- **Semicolons:** Required
- **Line endings:** Unix (LF)
- **Unused vars:** Error (except args prefixed with `_`)
- **Modern JS:** No `var`, prefer `const`, arrow callbacks, object shorthand

### Prettier Configuration
- Tab width: 2 spaces
- Print width: 80 characters
- Single quotes, trailing commas (ES5)
- Arrow parens: avoid
- End of line: LF

## Environment Variables

Required environment variables (see `.env.example`):
- `DATABASE_URL` - Neon PostgreSQL connection string
- `ARCJET_KEY` - Arcjet API key
- `JWT_SECRET` - JWT signing secret (default is insecure)
- `PORT` - Server port (default: 3000)
- `LOG_LEVEL` - Winston log level (default: info)
- `NODE_ENV` - Environment (affects logging)

## Working with Database

1. **Modify schema** in `src/models/*.js`
2. **Generate migration:** `npm run db:generate`
3. **Review migration** in `drizzle/` directory
4. **Apply migration:** `npm run db:migrate`

Database connection uses Neon's HTTP driver (`@neondatabase/serverless`) with Drizzle ORM.

## Adding New Features

When adding new features, follow the established pattern:

1. **Model** - Define schema in `src/models/` (Drizzle pgTable)
2. **Validation** - Create Zod schema in `src/validations/`
3. **Service** - Implement business logic in `src/services/`
4. **Controller** - Handle HTTP in `src/controllers/` (use validation helpers)
5. **Routes** - Wire up endpoints in `src/routes/`
6. **Register** - Import and mount routes in `src/app.js`

Always use the module aliases for imports.

## Password Handling

Passwords are hashed using bcrypt (10 salt rounds) in `auth.service.js`. Never return password hashes in API responses - use `.returning()` with explicit field selection.

## Common Patterns

**Error Handling:**
- Controllers use try-catch and pass errors to `next(e)`
- Logger used for all errors with context
- Return appropriate HTTP status codes

**Response Format:**
- Success: `{ message: "...", data: {...} }`
- Error: `{ error: "category", message: "details" }`
- Validation: `{ error: "Validation failed", details: [...] }`

**Token Management:**
- JWT payload: `{ id, email, role }`
- Expiry: 1 day
- Cookie helpers in `src/utils/cookies.js`
