
-- PROYECTO La Esquinita del Pan
-- Permisos a roles y sinonimos publicos
-- Ejecutar como: usr_admin_esquinita
-- NOTA: Tablas estan en modelo_fisico_esquinita_del_pan.sql
--       Este script se corre DESPUES de ese.

-- Permisos al rol administrador
-- Acceso total a todas l3as tablas


GRANT ALL ON DIM_CATEGORIA_PRODUCTO        TO admin_panaderia_role;
GRANT ALL ON DIM_PRODUCTO                  TO admin_panaderia_role;
GRANT ALL ON DIM_INGREDIENTE               TO admin_panaderia_role;
GRANT ALL ON DIM_PROVEEDOR                 TO admin_panaderia_role;
GRANT ALL ON DIM_EMPLEADO                  TO admin_panaderia_role;
GRANT ALL ON DIM_CLIENTE                   TO admin_panaderia_role;
GRANT ALL ON DIM_TIEMPO                    TO admin_panaderia_role;
GRANT ALL ON FACT_VENTA                    TO admin_panaderia_role;
GRANT ALL ON FACT_DETALLE_VENTA            TO admin_panaderia_role;
GRANT ALL ON FACT_COMPRA                   TO admin_panaderia_role;
GRANT ALL ON FACT_DETALLE_COMPRA           TO admin_panaderia_role;
GRANT ALL ON FACT_PRODUCCION               TO admin_panaderia_role;
GRANT ALL ON FACT_INVENTARIO_INGREDIENTE   TO admin_panaderia_role;

-- Permisos al rol cajero
-- Solo ventas y catalogo de productos

GRANT SELECT ON DIM_PRODUCTO               TO cajero_panaderia_role;
GRANT SELECT ON DIM_CATEGORIA_PRODUCTO     TO cajero_panaderia_role;
GRANT SELECT ON DIM_TIEMPO                 TO cajero_panaderia_role;
GRANT SELECT, INSERT ON DIM_CLIENTE        TO cajero_panaderia_role;
GRANT SELECT, INSERT, UPDATE ON FACT_VENTA           TO cajero_panaderia_role;
GRANT SELECT, INSERT, UPDATE ON FACT_DETALLE_VENTA   TO cajero_panaderia_role;

-- Permisos al rol produccion
-- Solo produccion, compras e inventario

GRANT SELECT ON DIM_PRODUCTO               TO produccion_panaderia_role;
GRANT SELECT ON DIM_INGREDIENTE            TO produccion_panaderia_role;
GRANT SELECT ON DIM_PROVEEDOR              TO produccion_panaderia_role;
GRANT SELECT ON DIM_TIEMPO                 TO produccion_panaderia_role;
GRANT SELECT, INSERT, UPDATE ON FACT_PRODUCCION              TO produccion_panaderia_role;
GRANT SELECT, INSERT, UPDATE ON FACT_COMPRA                  TO produccion_panaderia_role;
GRANT SELECT, INSERT, UPDATE ON FACT_DETALLE_COMPRA          TO produccion_panaderia_role;
GRANT SELECT, INSERT, UPDATE ON FACT_INVENTARIO_INGREDIENTE  TO produccion_panaderia_role;

-- Sinonimos publicos
-- Permite hacer SELECT * FROM FACT_VENTA
-- en vez de SELECT * FROM usr_admin_esquinita.FACT_VENTA

CREATE PUBLIC SYNONYM DIM_CATEGORIA_PRODUCTO      FOR usr_admin_esquinita.DIM_CATEGORIA_PRODUCTO;
CREATE PUBLIC SYNONYM DIM_PRODUCTO                FOR usr_admin_esquinita.DIM_PRODUCTO;
CREATE PUBLIC SYNONYM DIM_INGREDIENTE             FOR usr_admin_esquinita.DIM_INGREDIENTE;
CREATE PUBLIC SYNONYM DIM_PROVEEDOR               FOR usr_admin_esquinita.DIM_PROVEEDOR;
CREATE PUBLIC SYNONYM DIM_EMPLEADO                FOR usr_admin_esquinita.DIM_EMPLEADO;
CREATE PUBLIC SYNONYM DIM_CLIENTE                 FOR usr_admin_esquinita.DIM_CLIENTE;
CREATE PUBLIC SYNONYM DIM_TIEMPO                  FOR usr_admin_esquinita.DIM_TIEMPO;
CREATE PUBLIC SYNONYM FACT_VENTA                  FOR usr_admin_esquinita.FACT_VENTA;
CREATE PUBLIC SYNONYM FACT_DETALLE_VENTA          FOR usr_admin_esquinita.FACT_DETALLE_VENTA;
CREATE PUBLIC SYNONYM FACT_COMPRA                 FOR usr_admin_esquinita.FACT_COMPRA;
CREATE PUBLIC SYNONYM FACT_DETALLE_COMPRA         FOR usr_admin_esquinita.FACT_DETALLE_COMPRA;
CREATE PUBLIC SYNONYM FACT_PRODUCCION             FOR usr_admin_esquinita.FACT_PRODUCCION;
CREATE PUBLIC SYNONYM FACT_INVENTARIO_INGREDIENTE FOR usr_admin_esquinita.FACT_INVENTARIO_INGREDIENTE;

-- Verificacion de permisos otorgados

SELECT grantee, table_name, privilege
FROM dba_tab_privs
WHERE table_name IN (
    'DIM_CATEGORIA_PRODUCTO',
    'DIM_PRODUCTO',
    'DIM_INGREDIENTE',
    'DIM_PROVEEDOR',
    'DIM_EMPLEADO',
    'DIM_CLIENTE',
    'DIM_TIEMPO',
    'FACT_VENTA',
    'FACT_DETALLE_VENTA',
    'FACT_COMPRA',
    'FACT_DETALLE_COMPRA',
    'FACT_PRODUCCION',
    'FACT_INVENTARIO_INGREDIENTE'
)
ORDER BY grantee, table_name;

-- Verificar sinonimos creados
SELECT synonym_name, table_owner, table_name
FROM dba_synonyms
WHERE table_owner = 'USR_ADMIN_ESQUINITA'
ORDER BY synonym_name;



-- Respaldo Manual
 
-- Respaldo de ventas
CREATE TABLE FACT_VENTA_BAK AS
SELECT * FROM FACT_VENTA;
 
-- Respaldo de detalle de ventas
CREATE TABLE FACT_DETALLE_VENTA_BAK AS
SELECT * FROM FACT_DETALLE_VENTA;
 
-- Respaldo de produccion
CREATE TABLE FACT_PRODUCCION_BAK AS
SELECT * FROM FACT_PRODUCCION;
 
-- Respaldo de inventario
CREATE TABLE FACT_INVENTARIO_BAK AS
SELECT * FROM FACT_INVENTARIO_INGREDIENTE;
 
-- Verificar -- que los respaldos tienen datos
SELECT 'FACT_VENTA_BAK'             AS tabla, COUNT(*) AS registros FROM FACT_VENTA_BAK             UNION ALL
SELECT 'FACT_DETALLE_VENTA_BAK'     AS tabla, COUNT(*) AS registros FROM FACT_DETALLE_VENTA_BAK     UNION ALL
SELECT 'FACT_PRODUCCION_BAK'        AS tabla, COUNT(*) AS registros FROM FACT_PRODUCCION_BAK        UNION ALL
SELECT 'FACT_INVENTARIO_BAK'        AS tabla, COUNT(*) AS registros FROM FACT_INVENTARIO_BAK;


-- Vistas Materializadas
 
-- Vista 1: Ventas agrupadas por producto, mes y año
CREATE MATERIALIZED VIEW mv_ventas_por_producto
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
AS
SELECT
  p.nombre_producto,
  p.unidad_medida,
  SUM(dv.cantidad)    AS total_unidades_vendidas,
  SUM(dv.subtotal)    AS total_ingresos,
  t.mes,
  t.anio
FROM FACT_DETALLE_VENTA dv
JOIN DIM_PRODUCTO p ON dv.id_producto = p.id_producto
JOIN FACT_VENTA   v ON dv.id_venta    = v.id_venta
JOIN DIM_TIEMPO   t ON v.id_tiempo    = t.id_tiempo
GROUP BY p.nombre_producto, p.unidad_medida, t.mes, t.anio;
 
-- Vista 2: Ingredientes con alerta de stock bajo
CREATE MATERIALIZED VIEW mv_alerta_inventario
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
AS
SELECT
  i.nombre_ingrediente,
  i.unidad_medida,
  inv.cantidad_disponible,
  inv.stock_minimo,
  inv.alerta_stock,
  t.fecha
FROM FACT_INVENTARIO_INGREDIENTE inv
JOIN DIM_INGREDIENTE i ON inv.id_ingrediente = i.id_ingrediente
JOIN DIM_TIEMPO      t ON inv.id_tiempo      = t.id_tiempo
WHERE inv.alerta_stock = 'S';
 
-- Verificar -- las vistas materializadas
SELECT * FROM mv_ventas_por_producto;
SELECT * FROM mv_alerta_inventario;

-- Refresco de las vistas manual
 
CREATE OR REPLACE PROCEDURE refresca_vistas_esquinita AS
BEGIN
  DBMS_MVIEW.REFRESH('mv_ventas_por_producto');
  DBMS_MVIEW.REFRESH('mv_alerta_inventario');
  DBMS_OUTPUT.PUT_LINE('Vistas actualizadas correctamente: ' || SYSDATE);
END;
 
-- Probar el procedimiento manualmente
BEGIN
  refresca_vistas_esquinita;
END;


-- Job de respaldo automatico a media noche

BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
    job_name        => 'job_respaldo_esquinita',
    job_type        => 'PLSQL_BLOCK',
    job_action      => 'BEGIN
                          -- Limpiar respaldos anteriores
                          DELETE FROM FACT_VENTA_BAK;
                          DELETE FROM FACT_DETALLE_VENTA_BAK;
                          DELETE FROM FACT_PRODUCCION_BAK;
                          DELETE FROM FACT_INVENTARIO_BAK;
 
                          -- Reinsertar datos actuales
                          INSERT INTO FACT_VENTA_BAK
                            SELECT * FROM FACT_VENTA;
                          INSERT INTO FACT_DETALLE_VENTA_BAK
                            SELECT * FROM FACT_DETALLE_VENTA;
                          INSERT INTO FACT_PRODUCCION_BAK
                            SELECT * FROM FACT_PRODUCCION;
                          INSERT INTO FACT_INVENTARIO_BAK
                            SELECT * FROM FACT_INVENTARIO_INGREDIENTE;
 
                          COMMIT;
                          DBMS_OUTPUT.PUT_LINE(''Respaldo completado: '' || SYSDATE);
                        END;',
    start_date      => TRUNC(SYSTIMESTAMP + 1),
    repeat_interval => 'FREQ=DAILY; BYHOUR=0; BYMINUTE=0; BYSECOND=0',
    enabled         => TRUE,
    comments        => 'Respaldo diario automatico de tablas criticas - Esquinita del Pan'
  );
END;
 
-- Job de refresco de las vistas materializadas a media noche

BEGIN
  DBMS_SCHEDULER.CREATE_JOB (
    job_name        => 'job_refresco_vistas_esquinita',
    job_type        => 'PLSQL_BLOCK',
    job_action      => 'BEGIN
                          DBMS_MVIEW.REFRESH(''mv_ventas_por_producto'');
                          DBMS_MVIEW.REFRESH(''mv_alerta_inventario'');
                          DBMS_OUTPUT.PUT_LINE(''Vistas refrescadas: '' || SYSDATE);
                        END;',
    start_date      => TRUNC(SYSTIMESTAMP + 1),
    repeat_interval => 'FREQ=DAILY; BYHOUR=0; BYMINUTE=0; BYSECOND=0',
    enabled         => TRUE,
    comments        => 'Refresco diario de vistas materializadas - Esquinita del Pan'
  );
END;

-- Validar los jobs
 
SELECT job_name, enabled, state, next_run_date
FROM USER_SCHEDULER_JOBS
WHERE job_name IN (
    'JOB_RESPALDO_ESQUINITA',
    'JOB_REFRESCO_VISTAS_ESQUINITA'
);
 
