# mono_webapp

Aplicación web monolítica de inscripción a cursos, construida con Flask. Permite que instructores publiquen cursos y que estudiantes se inscriban, con control de cupos y roles de usuario.

## Stack

- **Backend**: Flask, Flask-Login (autenticación), Flask-WTF (formularios), Flask-SQLAlchemy (ORM)
- **Base de datos**: PostgreSQL (`psycopg2`)
- **Frontend**: Jinja2 + CSS plano (sin framework JS)

## Estructura

```
mono_webapp/
├── wsgi.py                  # Entry point WSGI (app = app.main:app)
└── app/
    ├── main.py               # Application factory (create_app)
    ├── database.py           # Instancia compartida de SQLAlchemy
    ├── modules/
    │   ├── users/            # Autenticación, registro, roles
    │   ├── courses/          # CRUD de cursos
    │   └── enrollments/      # Inscripciones a cursos
    ├── templates/            # Vistas Jinja2 por módulo
    └── static/css/           # Estilos
```

Cada módulo de dominio (`users`, `courses`, `enrollments`) sigue el mismo patrón:

| Archivo | Responsabilidad |
|---|---|
| `models.py` | Modelo SQLAlchemy |
| `routes.py` | Blueprint con las rutas HTTP |
| `services.py` | Lógica de negocio y acceso a datos |
| `schemas.py` | Formularios WTForms (`users`, `courses`) |

## Roles y permisos

- **student**: se inscribe/cancela inscripciones en cursos activos.
- **instructor**: crea, edita y desactiva sus propios cursos; ve a los estudiantes inscritos.
- **admin**: gestiona cualquier curso y ve el listado de usuarios.

## Reglas de negocio destacadas

- Un curso tiene un cupo (`capacity`); no se puede reducir por debajo de la cantidad de inscritos activos.
- Un estudiante no puede inscribirse dos veces (se reactiva la inscripción si estaba cancelada).
- No se puede inscribir en un curso lleno o inactivo.
- Al desactivar un curso, se cancelan todas sus inscripciones activas.

## Configuración

La app lee variables de entorno en `app/main.py`:

| Variable | Descripción | Default |
|---|---|---|
| `SECRET_KEY` | Clave de sesión/CSRF de Flask | `dev-key-not-for-production` (no usar en prod) |
| `DATABASE_URL` | Cadena de conexión SQLAlchemy | `postgresql+psycopg2://appuser:***@mono_postgres:5432/appdb` |

> Definí ambas variables de entorno antes de desplegar en un entorno real; los valores por defecto son solo para desarrollo local.

## Puesta en marcha

Este repo no incluye `requirements.txt`, `Dockerfile` ni `docker-compose.yml`. Como mínimo necesitás:

```bash
pip install flask flask-sqlalchemy flask-login flask-wtf psycopg2-binary
```

y una instancia de PostgreSQL accesible según `DATABASE_URL`. Luego:

```bash
export SECRET_KEY=cambia-esto
export DATABASE_URL=postgresql+psycopg2://usuario:password@host:5432/appdb
flask --app mono_webapp/wsgi.py run
```

Las tablas se crean vía los modelos de SQLAlchemy; no hay migraciones (Alembic) configuradas todavía.

## Crear un usuario administrador

No hay seed ni comando de creación de admin. `password_hash` se genera con `werkzeug.security.generate_password_hash` (scrypt, salteado) — no se puede escribir a mano, hay que generarlo:

```bash
python -c "from werkzeug.security import generate_password_hash; print(generate_password_hash('TU_PASSWORD_AQUI'))"
```

y luego insertar el usuario directamente en la base de datos con el hash generado:

```sql
INSERT INTO users (full_name, email, password_hash, role, created_at)
VALUES (
    'Admin Principal',
    'admin@example.com',
    '<hash generado en el paso anterior>',
    'admin',
    now()
);
```

## Licencia

MIT — ver [LICENSE](LICENSE).
