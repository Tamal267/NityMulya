import postgres, { Sql } from "postgres";

const connectionString: string | undefined = process.env.DATABASE_URL;

if (!connectionString) {
  throw new Error("DATABASE_URL environment variable is not set");
}

const sql: Sql = postgres(connectionString);

// Export both default and named export for compatibility
export default sql;
export { sql as db };
