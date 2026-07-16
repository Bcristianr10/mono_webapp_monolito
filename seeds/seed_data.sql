-- Seed data para desarrollo/pruebas locales.
-- Contraseña de TODOS los usuarios: "Password123"
-- (hash generado con werkzeug.security.generate_password_hash, scrypt)
--
-- IDs a partir de 1000/2000 para no chocar con filas que ya tengas
-- (ids bajos, autogenerados por serial). Si tu tabla ya tiene ids >= 1000,
-- ajustá los rangos antes de correr esto.
--
-- Ejecutar contra una base ya inicializada (db.create_all() corrido antes):
--   psql "postgresql://bruiz:987654321@localhost:5432/appdb" -f seeds/seed_data.sql

BEGIN;

-- ============================================================
-- USERS
-- ============================================================
INSERT INTO users (id, full_name, email, password_hash, role, created_at) VALUES
(1000, 'Admin Seed',           'seed.admin@example.com',       'scrypt:32768:8:1$ZR8sN6Xgk4X1vMk2$8a11f3e93b452e8902f5247af41e71122065dbfd429c06dc45c485ad62529a8ea2409f0431faee265b24fa26e05bb9e9b44488bdc653566b36d9bc1bbb995788', 'admin',      '2026-06-01 09:00:00+00'),
(1001, 'Laura Gómez',          'laura.gomez@example.com',      'scrypt:32768:8:1$ZR8sN6Xgk4X1vMk2$8a11f3e93b452e8902f5247af41e71122065dbfd429c06dc45c485ad62529a8ea2409f0431faee265b24fa26e05bb9e9b44488bdc653566b36d9bc1bbb995788', 'instructor', '2026-06-01 09:05:00+00'),
(1002, 'Carlos Pérez',         'carlos.perez@example.com',     'scrypt:32768:8:1$ZR8sN6Xgk4X1vMk2$8a11f3e93b452e8902f5247af41e71122065dbfd429c06dc45c485ad62529a8ea2409f0431faee265b24fa26e05bb9e9b44488bdc653566b36d9bc1bbb995788', 'instructor', '2026-06-01 09:10:00+00'),
(1003, 'Marta Díaz',           'marta.diaz@example.com',       'scrypt:32768:8:1$ZR8sN6Xgk4X1vMk2$8a11f3e93b452e8902f5247af41e71122065dbfd429c06dc45c485ad62529a8ea2409f0431faee265b24fa26e05bb9e9b44488bdc653566b36d9bc1bbb995788', 'instructor', '2026-06-01 09:15:00+00'),
(1004, 'Ana Torres',           'ana.torres@example.com',       'scrypt:32768:8:1$ZR8sN6Xgk4X1vMk2$8a11f3e93b452e8902f5247af41e71122065dbfd429c06dc45c485ad62529a8ea2409f0431faee265b24fa26e05bb9e9b44488bdc653566b36d9bc1bbb995788', 'student',    '2026-06-02 10:00:00+00'),
(1005, 'Luis Ramírez',         'luis.ramirez@example.com',     'scrypt:32768:8:1$ZR8sN6Xgk4X1vMk2$8a11f3e93b452e8902f5247af41e71122065dbfd429c06dc45c485ad62529a8ea2409f0431faee265b24fa26e05bb9e9b44488bdc653566b36d9bc1bbb995788', 'student',    '2026-06-02 10:05:00+00'),
(1006, 'Sofía Castro',         'sofia.castro@example.com',     'scrypt:32768:8:1$ZR8sN6Xgk4X1vMk2$8a11f3e93b452e8902f5247af41e71122065dbfd429c06dc45c485ad62529a8ea2409f0431faee265b24fa26e05bb9e9b44488bdc653566b36d9bc1bbb995788', 'student',    '2026-06-02 10:10:00+00'),
(1007, 'Diego Molina',         'diego.molina@example.com',     'scrypt:32768:8:1$ZR8sN6Xgk4X1vMk2$8a11f3e93b452e8902f5247af41e71122065dbfd429c06dc45c485ad62529a8ea2409f0431faee265b24fa26e05bb9e9b44488bdc653566b36d9bc1bbb995788', 'student',    '2026-06-02 10:15:00+00'),
(1008, 'Valentina Rojas',      'valentina.rojas@example.com',  'scrypt:32768:8:1$ZR8sN6Xgk4X1vMk2$8a11f3e93b452e8902f5247af41e71122065dbfd429c06dc45c485ad62529a8ea2409f0431faee265b24fa26e05bb9e9b44488bdc653566b36d9bc1bbb995788', 'student',    '2026-06-02 10:20:00+00'),
(1009, 'Mateo Herrera',        'mateo.herrera@example.com',    'scrypt:32768:8:1$ZR8sN6Xgk4X1vMk2$8a11f3e93b452e8902f5247af41e71122065dbfd429c06dc45c485ad62529a8ea2409f0431faee265b24fa26e05bb9e9b44488bdc653566b36d9bc1bbb995788', 'student',    '2026-06-02 10:25:00+00'),
(1010, 'Camila Vargas',        'camila.vargas@example.com',    'scrypt:32768:8:1$ZR8sN6Xgk4X1vMk2$8a11f3e93b452e8902f5247af41e71122065dbfd429c06dc45c485ad62529a8ea2409f0431faee265b24fa26e05bb9e9b44488bdc653566b36d9bc1bbb995788', 'student',    '2026-06-02 10:30:00+00'),
(1011, 'Sebastián Ortiz',      'sebastian.ortiz@example.com',  'scrypt:32768:8:1$ZR8sN6Xgk4X1vMk2$8a11f3e93b452e8902f5247af41e71122065dbfd429c06dc45c485ad62529a8ea2409f0431faee265b24fa26e05bb9e9b44488bdc653566b36d9bc1bbb995788', 'student',    '2026-06-02 10:35:00+00'),
(1012, 'Isabella Cruz',        'isabella.cruz@example.com',    'scrypt:32768:8:1$ZR8sN6Xgk4X1vMk2$8a11f3e93b452e8902f5247af41e71122065dbfd429c06dc45c485ad62529a8ea2409f0431faee265b24fa26e05bb9e9b44488bdc653566b36d9bc1bbb995788', 'student',    '2026-06-02 10:40:00+00'),
(1013, 'Nicolás Silva',        'nicolas.silva@example.com',    'scrypt:32768:8:1$ZR8sN6Xgk4X1vMk2$8a11f3e93b452e8902f5247af41e71122065dbfd429c06dc45c485ad62529a8ea2409f0431faee265b24fa26e05bb9e9b44488bdc653566b36d9bc1bbb995788', 'student',    '2026-06-02 10:45:00+00');

-- ============================================================
-- COURSES
-- (instructor_id: 1001=Laura, 1002=Carlos, 1003=Marta)
-- ============================================================
INSERT INTO courses (id, title, description, instructor_id, capacity, is_active, created_at) VALUES
(2000, 'Introducción a Bases de Datos',      'Modelo relacional, SQL y normalización.',                 1001, 3,  true,  '2026-06-05 08:00:00+00'),
(2001, 'Arquitectura de Software',           'Estilos arquitectónicos, monolitos y microservicios.',    1001, 20, true,  '2026-06-06 08:00:00+00'),
(2002, 'Programación Web con Flask',         'Construcción de aplicaciones web con Flask y SQLAlchemy.', 1002, 15, true,  '2026-06-07 08:00:00+00'),
(2003, 'Álgebra Lineal',                     'Vectores, matrices y transformaciones lineales.',          1002, 25, true,  '2026-06-08 08:00:00+00'),
(2004, 'Machine Learning Aplicado',          'Modelos supervisados y no supervisados con Python.',       1003, 10, true,  '2026-06-09 08:00:00+00'),
(2005, 'Historia de la Tecnología',          'Curso descontinuado, usado para probar cursos inactivos.', 1003, 30, false, '2026-05-01 08:00:00+00');

-- ============================================================
-- ENROLLMENTS
-- Curso 2000 queda LLENO (capacity=3, 3 activos) para probar CourseFullError.
-- Curso 2002 tiene una inscripción CANCELADA (Sebastián) para probar la reactivación.
-- Curso 2005 (inactivo) tiene una inscripción cancelada histórica (cascada al desactivar).
-- ============================================================
INSERT INTO enrollments (user_id, course_id, status, enrolled_at) VALUES
(1004, 2000, 'active',    '2026-06-10 09:00:00+00'),
(1005, 2000, 'active',    '2026-06-10 09:05:00+00'),
(1006, 2000, 'active',    '2026-06-10 09:10:00+00'),

(1004, 2001, 'active',    '2026-06-11 09:00:00+00'),
(1007, 2001, 'active',    '2026-06-11 09:05:00+00'),
(1008, 2001, 'active',    '2026-06-11 09:10:00+00'),
(1009, 2001, 'active',    '2026-06-11 09:15:00+00'),

(1005, 2002, 'active',    '2026-06-12 09:00:00+00'),
(1008, 2002, 'active',    '2026-06-12 09:05:00+00'),
(1010, 2002, 'active',    '2026-06-12 09:10:00+00'),
(1011, 2002, 'cancelled', '2026-06-12 09:15:00+00'),

(1006, 2003, 'active',    '2026-06-13 09:00:00+00'),
(1009, 2003, 'active',    '2026-06-13 09:05:00+00'),
(1012, 2003, 'active',    '2026-06-13 09:10:00+00'),

(1007, 2004, 'active',    '2026-06-14 09:00:00+00'),
(1010, 2004, 'active',    '2026-06-14 09:05:00+00'),
(1013, 2004, 'active',    '2026-06-14 09:10:00+00'),

(1004, 2005, 'cancelled', '2026-05-02 09:00:00+00');

-- Reajustar las secuencias porque insertamos ids explícitos.
SELECT setval(pg_get_serial_sequence('users', 'id'), (SELECT MAX(id) FROM users));
SELECT setval(pg_get_serial_sequence('courses', 'id'), (SELECT MAX(id) FROM courses));
SELECT setval(pg_get_serial_sequence('enrollments', 'id'), (SELECT MAX(id) FROM enrollments));

COMMIT;
