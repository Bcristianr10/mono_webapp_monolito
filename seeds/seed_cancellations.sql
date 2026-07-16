-- Backfill de enrollment_status_history para los reportes de cancelaciones.
-- Requiere haber corrido antes seeds/seed_data.sql.
-- Solo toca inscripciones de usuarios seed (id >= 1000); no modifica tus datos reales.

BEGIN;

-- 1) Historial 'active' (creación) para todas las inscripciones seed
INSERT INTO enrollment_status_history (enrollment_id, status, changed_at)
SELECT id, 'active', enrolled_at
FROM enrollments
WHERE user_id >= 1000;

-- 2) Convertir a 'cancelled' 5 inscripciones que estaban activas
--    (2 en Álgebra Lineal, 2 en Machine Learning, 1 más en Programación Web con Flask)
UPDATE enrollments SET status = 'cancelled' WHERE user_id = 1008 AND course_id = 2002;
UPDATE enrollments SET status = 'cancelled' WHERE user_id = 1006 AND course_id = 2003;
UPDATE enrollments SET status = 'cancelled' WHERE user_id = 1009 AND course_id = 2003;
UPDATE enrollments SET status = 'cancelled' WHERE user_id = 1007 AND course_id = 2004;
UPDATE enrollments SET status = 'cancelled' WHERE user_id = 1010 AND course_id = 2004;

-- 3) Historial 'cancelled' de las 2 cancelaciones que ya traía seed_data.sql
INSERT INTO enrollment_status_history (enrollment_id, status, changed_at)
SELECT id, 'cancelled', TIMESTAMPTZ '2026-06-15 09:15:00+00'
FROM enrollments WHERE user_id = 1011 AND course_id = 2002;

INSERT INTO enrollment_status_history (enrollment_id, status, changed_at)
SELECT id, 'cancelled', TIMESTAMPTZ '2026-05-03 09:00:00+00'
FROM enrollments WHERE user_id = 1004 AND course_id = 2005;

-- 4) Historial 'cancelled' de las 5 nuevas cancelaciones del paso 2
--    (tiempos distintos hasta cancelar, para variar el promedio por curso)
INSERT INTO enrollment_status_history (enrollment_id, status, changed_at)
SELECT id, 'cancelled', TIMESTAMPTZ '2026-06-14 09:05:00+00' FROM enrollments WHERE user_id = 1008 AND course_id = 2002;

INSERT INTO enrollment_status_history (enrollment_id, status, changed_at)
SELECT id, 'cancelled', TIMESTAMPTZ '2026-06-17 09:00:00+00' FROM enrollments WHERE user_id = 1006 AND course_id = 2003;

INSERT INTO enrollment_status_history (enrollment_id, status, changed_at)
SELECT id, 'cancelled', TIMESTAMPTZ '2026-06-23 09:05:00+00' FROM enrollments WHERE user_id = 1009 AND course_id = 2003;

INSERT INTO enrollment_status_history (enrollment_id, status, changed_at)
SELECT id, 'cancelled', TIMESTAMPTZ '2026-06-15 09:00:00+00' FROM enrollments WHERE user_id = 1007 AND course_id = 2004;

INSERT INTO enrollment_status_history (enrollment_id, status, changed_at)
SELECT id, 'cancelled', TIMESTAMPTZ '2026-06-16 09:05:00+00' FROM enrollments WHERE user_id = 1010 AND course_id = 2004;

COMMIT;
