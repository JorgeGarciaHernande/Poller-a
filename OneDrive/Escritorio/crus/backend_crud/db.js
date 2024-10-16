const { Pool } = require('pg');
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: {
    rejectUnauthorized: false, // Render requiere SSL para conexiones seguras
  },
});

module.exports = pool;
