import 'dotenv/config';
import { neon, neonConfig } from '@neondatabase/serverless';
import { drizzle } from 'drizzle-orm/neon-http';

// Configure Neon for local development
// Neon Local only supports HTTP-based communication, not websockets
if (process.env.NODE_ENV === 'development') {
  neonConfig.fetchEndpoint = process.env.DATABASE_URL.replace('postgres://', 'http://').replace(':5432', ':5432');
}

const sql = neon(process.env.DATABASE_URL, {
  // For Neon Local with self-signed certificates
  fetchOptions: {
    ssl: {
      rejectUnauthorized: false
    }
  }
});

const db = drizzle(sql);

export { db, sql };
