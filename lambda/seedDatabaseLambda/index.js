const fs = require('fs');
const path = require('path');
const { Client } = require('pg');

exports.handler = async () => {
    const seedSql = fs.readFileSync(path.join(__dirname, 'seed.sql'), 'utf8');

    const client = new Client({
        host:     process.env.DB_HOST,
        port:     parseInt(process.env.DB_PORT, 10),
        database: process.env.DB_NAME,
        user:     process.env.DB_USER,
        password: process.env.DB_PASSWORD,
        ssl:      { rejectUnauthorized: false },
    });

    await client.connect();

    try {
        await client.query('BEGIN');
        await client.query(seedSql);
        const { rows } = await client.query('SELECT COUNT(*)::int AS count FROM public.estudiante');
        await client.query('COMMIT');

        return {
            statusCode: 200,
            body: JSON.stringify({
                message: 'Seed completado',
                estudiante_count: rows[0].count,
            }),
        };
    } catch (err) {
        await client.query('ROLLBACK');
        console.error('Seed falló:', err);
        throw err;
    } finally {
        await client.end();
    }
};
