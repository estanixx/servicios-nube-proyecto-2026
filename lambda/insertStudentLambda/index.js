const { Client } = require('pg');

exports.handler = async (event) => {


    // Only allow POST
    if (event.httpMethod !== 'POST') {
        return {
            statusCode: 405,
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ error: 'Method Not Allowed' })
        };
    }

    let client;
    try {
        const body = JSON.parse(event.body || '{}');
        const { nombre, apellido, fecha_nacimiento, direccion, correo_electronico, carrera } = body;

        // Validate required fields (all 6 from DDL schema)
        if (!nombre || !apellido || !fecha_nacimiento || !direccion || !correo_electronico || !carrera) {
            return {
                statusCode: 400,
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ error: 'Missing required fields: nombre, apellido, fecha_nacimiento, direccion, correo_electronico, carrera' })
            };
        }

        client = new Client({
            host: process.env.DB_HOST,
            port: parseInt(process.env.DB_PORT, 10),
            database: process.env.DB_NAME,
            user: process.env.DB_USER,
            password: process.env.DB_PASSWORD,
            ssl: { rejectUnauthorized: false }
        });

        await client.connect();

        // Create table if not exists
        await client.query(`
            CREATE TABLE IF NOT EXISTS public.estudiante (
                id serial PRIMARY KEY,
                nombre varchar(50),
                apellido varchar(50),
                fecha_nacimiento date,
                direccion varchar(100),
                correo_electronico varchar(100),
                carrera varchar(50)
            )
        `);

        // INSERT into estudiante table (all 6 fields per DDL schema)
        const sql = `INSERT INTO public.estudiante (nombre, apellido, fecha_nacimiento, direccion, correo_electronico, carrera) VALUES ($1, $2, $3, $4, $5, $6)`;

        await client.query(sql, [nombre, apellido, fecha_nacimiento, direccion, correo_electronico, carrera]);

        return {
            statusCode: 201,
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ success: true, message: 'Student inserted successfully' })
        };
    } catch (error) {
        console.error('Error:', error);
        return {
            statusCode: 500,
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ error: 'Internal Server Error', details: error.message })
        };
    } finally {
        if (client) {
            await client.end();
        }
    }
};
