
-- PROYECTO La Esquinita del Pan
-- Paso 1: Creacion de usuarios
-- Ejecutar como: ConexionOracle ADMIN

-- Usuario administrador del proyecto
CREATE USER usr_admin_esquinita IDENTIFIED BY "Cuatrimestre22026.";
GRANT CONNECT TO usr_admin_esquinita;
GRANT RESOURCE TO usr_admin_esquinita;
ALTER USER usr_admin_esquinita QUOTA UNLIMITED ON DATA;

-- Usuario cajero
CREATE USER usr_cajero_esquinita IDENTIFIED BY "Cuatrimestre22026.";
GRANT CONNECT TO usr_cajero_esquinita;
GRANT RESOURCE TO usr_cajero_esquinita;
ALTER USER usr_cajero_esquinita QUOTA UNLIMITED ON DATA;

-- Usuario produccion
CREATE USER usr_produccion_esquinita IDENTIFIED BY "Cuatrimestre22026.";
GRANT CONNECT TO usr_produccion_esquinita;
GRANT RESOURCE TO usr_produccion_esquinita;
ALTER USER usr_produccion_esquinita QUOTA UNLIMITED ON DATA;

-- Paso 2: Creacion de roles

CREATE ROLE admin_panaderia_role;
CREATE ROLE cajero_panaderia_role;
CREATE ROLE produccion_panaderia_role;

-- Paso 3: Asignar roles a usuarios

GRANT admin_panaderia_role      TO usr_admin_esquinita;
GRANT cajero_panaderia_role     TO usr_cajero_esquinita;
GRANT produccion_panaderia_role TO usr_produccion_esquinita;

-- Verificacion

SELECT username, account_status, profile
FROM dba_users
WHERE username IN (
    'USR_ADMIN_ESQUINITA',
    'USR_CAJERO_ESQUINITA',
    'USR_PRODUCCION_ESQUINITA'
);

SELECT role FROM dba_roles
WHERE role IN (
    'ADMIN_PANADERIA_ROLE',
    'CAJERO_PANADERIA_ROLE',
    'PRODUCCION_PANADERIA_ROLE'
);

SELECT grantee, granted_role
FROM dba_role_privs
WHERE grantee IN (
    'USR_ADMIN_ESQUINITA',
    'USR_CAJERO_ESQUINITA',
    'USR_PRODUCCION_ESQUINITA'
);

GRANT CREATE MATERIALIZED VIEW TO PROFESOR;

GRANT CREATE JOB TO PROFESOR;


SELECT job_name, enabled, state, next_run_date
FROM DBA_SCHEDULER_JOBS
WHERE job_name = 'REFRESCA_VM_EML';

-- Permisos para Jobs y vistas materializadas

GRANT CREATE MATERIALIZED VIEW TO USR_ADMIN_ESQUINITA;
GRANT CREATE JOB               TO USR_ADMIN_ESQUINITA;
