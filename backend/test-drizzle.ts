import { drizzle } from 'drizzle-orm/node-postgres';
import pg from 'pg';

const pool = new pg.Pool({ connectionString: 'postgres://user:pass@localhost/db' });

try {
  drizzle(pool);
  console.log("Success with pool");
} catch(e: any) {
  console.log("Error with pool:", e.message);
}

try {
  drizzle({ client: pool });
  console.log("Success with { client: pool }");
} catch(e: any) {
  console.log("Error with { client: pool }:", e.message);
}
