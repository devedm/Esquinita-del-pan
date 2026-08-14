
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
-- ------------------------------------------------------------------------------
-- ENCRIPTACION DE DATOS SENSIBLES - PROYECTO ESQUINITA
-- Tablas afectadas: DIM_CLIENTE, DIM_EMPLEADO, DIM_PROVEEDOR
--
-- IMPORTANTE ANTES DE CORRER ESTE SCRIPT:
--  GRANT EXECUTE ON DBMS_CRYPTO TO USR_ADMIN_ESQUINITA;
-- Clave 'esquinita@2026'  MISMA clave en las 3 funciones

--  SALARIO se encripta (se guarda como texto).
--  Los triggers aplican en INSERT y UPDATE.
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- 1. FUNCIONES DE ENCRIPTACION / DESENCRIPTACION 
--------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION encriptar_texto (p_text VARCHAR2) RETURN RAW IS
    l_key RAW(32) := UTL_I18N.STRING_TO_RAW(
                        SUBSTR(RPAD('esquinita@2026', 32, 'X'), 1, 32),
                        'AL32UTF8'
                     );
BEGIN
    IF p_text IS NULL THEN
        RETURN NULL;
    END IF;

    RETURN DBMS_CRYPTO.ENCRYPT(
        UTL_I18N.STRING_TO_RAW(p_text, 'AL32UTF8'),
        DBMS_CRYPTO.AES_CBC_PKCS5,
        l_key
    );
END encriptar_texto;
/

CREATE OR REPLACE FUNCTION desencriptar_texto (p_encrypted RAW) RETURN VARCHAR2 IS
    l_key RAW(32) := UTL_I18N.STRING_TO_RAW(
                        SUBSTR(RPAD('esquinita@2026', 32, 'X'), 1, 32),
                        'AL32UTF8'
                     );
    l_raw RAW(32767);
BEGIN
    IF p_encrypted IS NULL THEN
        RETURN NULL;
    END IF;

    l_raw := DBMS_CRYPTO.DECRYPT(
        p_encrypted,
        DBMS_CRYPTO.AES_CBC_PKCS5,
        l_key
    );
    RETURN UTL_I18N.RAW_TO_CHAR(l_raw, 'AL32UTF8');
END desencriptar_texto;
/

--------------------------------------------------------------------------------
-- 2. MIGRACION DE COLUMNAS EXISTENTES
--    (agrandar columnas + encriptar el dato que ya este cargado)
--------------------------------------------------------------------------------

------------------------------
-- DIM_CLIENTE
------------------------------
ALTER TABLE DIM_CLIENTE MODIFY (NOMBRE   VARCHAR2(250 BYTE));
ALTER TABLE DIM_CLIENTE MODIFY (TELEFONO VARCHAR2(80  BYTE));
ALTER TABLE DIM_CLIENTE MODIFY (CORREO   VARCHAR2(280 BYTE));

UPDATE DIM_CLIENTE SET NOMBRE   = encriptar_texto(NOMBRE)   WHERE NOMBRE   IS NOT NULL;
UPDATE DIM_CLIENTE SET TELEFONO = encriptar_texto(TELEFONO) WHERE TELEFONO IS NOT NULL;
UPDATE DIM_CLIENTE SET CORREO   = encriptar_texto(CORREO)   WHERE CORREO   IS NOT NULL;
COMMIT;

------------------------------
-- DIM_EMPLEADO
------------------------------
ALTER TABLE DIM_EMPLEADO MODIFY (NOMBRE   VARCHAR2(150 BYTE));
ALTER TABLE DIM_EMPLEADO MODIFY (APELLIDO VARCHAR2(150 BYTE));

UPDATE DIM_EMPLEADO SET NOMBRE   = encriptar_texto(NOMBRE)   WHERE NOMBRE   IS NOT NULL;
UPDATE DIM_EMPLEADO SET APELLIDO = encriptar_texto(APELLIDO) WHERE APELLIDO IS NOT NULL;
COMMIT;

-- SALARIO cambia de NUMBER a VARCHAR2, asi que necesita columna temporal
ALTER TABLE DIM_EMPLEADO ADD (SALARIO_TMP VARCHAR2(60 BYTE));

UPDATE DIM_EMPLEADO
   SET SALARIO_TMP = encriptar_texto(TO_CHAR(SALARIO))
 WHERE SALARIO IS NOT NULL;
COMMIT;

ALTER TABLE DIM_EMPLEADO DROP COLUMN SALARIO;
ALTER TABLE DIM_EMPLEADO RENAME COLUMN SALARIO_TMP TO SALARIO;

------------------------------
-- DIM_PROVEEDOR
------------------------------
ALTER TABLE DIM_PROVEEDOR MODIFY (NOMBRE_EMPRESA VARCHAR2(250 BYTE));
ALTER TABLE DIM_PROVEEDOR MODIFY (CONTACTO       VARCHAR2(250 BYTE));
ALTER TABLE DIM_PROVEEDOR MODIFY (TELEFONO       VARCHAR2(80  BYTE));
ALTER TABLE DIM_PROVEEDOR MODIFY (CORREO         VARCHAR2(280 BYTE));
ALTER TABLE DIM_PROVEEDOR MODIFY (DIRECCION      VARCHAR2(450 BYTE));

UPDATE DIM_PROVEEDOR SET NOMBRE_EMPRESA = encriptar_texto(NOMBRE_EMPRESA) WHERE NOMBRE_EMPRESA IS NOT NULL;
UPDATE DIM_PROVEEDOR SET CONTACTO       = encriptar_texto(CONTACTO)       WHERE CONTACTO       IS NOT NULL;
UPDATE DIM_PROVEEDOR SET TELEFONO       = encriptar_texto(TELEFONO)       WHERE TELEFONO       IS NOT NULL;
UPDATE DIM_PROVEEDOR SET CORREO         = encriptar_texto(CORREO)         WHERE CORREO         IS NOT NULL;
UPDATE DIM_PROVEEDOR SET DIRECCION      = encriptar_texto(DIRECCION)      WHERE DIRECCION      IS NOT NULL;
COMMIT;


--------------------------------------------------------------------------------
-- 3. TRIGGERS: encriptan automaticamente en cada INSERT/UPDATE
--
-- IMPORTANTE: usan UPDATING('COLUMNA') para encriptar SOLO cuando esa
-- columna viene explicitamente en el INSERT/UPDATE. 
--------------------------------------------------------------------------------

CREATE OR REPLACE TRIGGER trg_dim_cliente_enc
BEFORE INSERT OR UPDATE ON DIM_CLIENTE
FOR EACH ROW
BEGIN
    IF INSERTING OR UPDATING('NOMBRE') THEN
        :NEW.NOMBRE := encriptar_texto(:NEW.NOMBRE);
    END IF;

    IF INSERTING OR UPDATING('TELEFONO') THEN
        :NEW.TELEFONO := encriptar_texto(:NEW.TELEFONO);
    END IF;

    IF INSERTING OR UPDATING('CORREO') THEN
        :NEW.CORREO := encriptar_texto(:NEW.CORREO);
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_dim_empleado_enc
BEFORE INSERT OR UPDATE ON DIM_EMPLEADO
FOR EACH ROW
BEGIN
    IF INSERTING OR UPDATING('NOMBRE') THEN
        :NEW.NOMBRE := encriptar_texto(:NEW.NOMBRE);
    END IF;

    IF INSERTING OR UPDATING('APELLIDO') THEN
        :NEW.APELLIDO := encriptar_texto(:NEW.APELLIDO);
    END IF;

    IF INSERTING OR UPDATING('SALARIO') THEN
        :NEW.SALARIO := encriptar_texto(:NEW.SALARIO);
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_dim_proveedor_enc
BEFORE INSERT OR UPDATE ON DIM_PROVEEDOR
FOR EACH ROW
BEGIN
    IF INSERTING OR UPDATING('NOMBRE_EMPRESA') THEN
        :NEW.NOMBRE_EMPRESA := encriptar_texto(:NEW.NOMBRE_EMPRESA);
    END IF;

    IF INSERTING OR UPDATING('CONTACTO') THEN
        :NEW.CONTACTO := encriptar_texto(:NEW.CONTACTO);
    END IF;

    IF INSERTING OR UPDATING('TELEFONO') THEN
        :NEW.TELEFONO := encriptar_texto(:NEW.TELEFONO);
    END IF;

    IF INSERTING OR UPDATING('CORREO') THEN
        :NEW.CORREO := encriptar_texto(:NEW.CORREO);
    END IF;

    IF INSERTING OR UPDATING('DIRECCION') THEN
        :NEW.DIRECCION := encriptar_texto(:NEW.DIRECCION);
    END IF;
END;
/


--------------------------------------------------------------------------------
-- 4. COMO CONSULTAR LOS DATOS DESPUES DE ESTO
--------------------------------------------------------------------------------

-- Para leer en texto plano:
--   SELECT ID_CLIENTE, desencriptar_texto(NOMBRE) AS NOMBRE,
--          desencriptar_texto(TELEFONO) AS TELEFONO,
--          desencriptar_texto(CORREO) AS CORREO
--     FROM DIM_CLIENTE;

--   SELECT ID_EMPLEADO, desencriptar_texto(NOMBRE) AS NOMBRE,
--          desencriptar_texto(APELLIDO) AS APELLIDO,
--          TO_NUMBER(desencriptar_texto(SALARIO)) AS SALARIO
--     FROM DIM_EMPLEADO;

--  CON LOS WHERE / BUSQUEDAS:
-- Una vez encriptada la columna, ya NO se puede hacer
--   WHERE CORREO = 'juan@correo.com'
-- porque lo que esta guardado es el texto cifrado, no el original.
-- se tiene que hacer:
--   WHERE desencriptar_texto(CORREO) = 'juan@correo.com'
--------------------------------------------------------------------------------
);

--------------------------------------------------------------------------------
-- PROBAR ENCRIPTACION Y DESENCRIPTACION
-- Se corre cada bloque y compara los resultados para ver el antes/despues.
--------------------------------------------------------------------------------

-- 1) Encriptar un texto suelto: el resultado es ilegible (cifrado en RAW/hex)
SELECT encriptar_texto('Roman Elizondo') AS TEXTO_CIFRADO
  FROM DUAL;

-- 2) Desencriptarlo: se recupera el texto original
SELECT desencriptar_texto(encriptar_texto('Roman Elizondo')) AS TEXTO_RECUPERADO
  FROM DUAL;


-- 3) Insertar un cliente de prueba (el trigger encripta automaticamente
--    NOMBRE, TELEFONO y CORREO antes de guardarlos)
INSERT INTO DIM_CLIENTE (NOMBRE, TELEFONO, CORREO, FECHA_REGISTRO)
VALUES ('Demo Encriptacion', '70001111', 'demo@correo.com', SYSDATE);
COMMIT;


-- 4) Ver como quedo GUARDADO REALMENTE en la tabla
--    (esto es lo que veria cualquiera que consulte la tabla directamente,
--    sin pasar por la funcion de desencriptar)
SELECT ID_CLIENTE, NOMBRE, TELEFONO, CORREO
  FROM DIM_CLIENTE
 WHERE NOMBRE = encriptar_texto('Demo Encriptacion');
-- -> NOMBRE, TELEFONO y CORREO aparecen como texto cifrado, ilegible


-- 5) Ver el MISMO registro pero desencriptado
--    (esto es lo que veria la aplicacion o un reporte autorizado)
SELECT ID_CLIENTE,
       desencriptar_texto(NOMBRE)   AS NOMBRE,
       desencriptar_texto(TELEFONO) AS TELEFONO,
       desencriptar_texto(CORREO)   AS CORREO
  FROM DIM_CLIENTE
 WHERE NOMBRE = encriptar_texto('Demo Encriptacion');
-- -> Ahora se ve "Demo Encriptacion", "70001111", "demo@correo.com" en claro


-- 6) Limpiar el registro de prueba
DELETE FROM DIM_CLIENTE WHERE NOMBRE = encriptar_texto('Demo Encriptacion');
COMMIT;
--------------------------------------------------------------------------------


 
--------------------------------------------------------------------------------
-- AUDITORIA ESQUINITA 

--  En las bitacoras de DIM_CLIENTE/DIM_EMPLEADO/DIM_PROVEEDOR se guarda
--  el valor CIFRADO (tal cual esta en la columna), NO el texto plano.
--  Si guardaramos el texto plano en la bitacora, estariamos creando una
--  segunda copia SIN PROTEGER del dato sensible.

-- ORDEN DE EJECUCION: correr de arriba a abajo, una sola vez. Si se
-- vuelve a correr, los CREATE TABLE de la seccion 4 van a fallar porque
-- ya existen 
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- 1. CORREGIR TRIGGER DUPLICADO (ESTADO_VENTA se registraba 2 veces)
--------------------------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE 'DROP TRIGGER UPDATE_ESTADO_VENTA_ESQUINITA';
EXCEPTION WHEN OTHERS THEN NULL; END;
/
-- Queda activo solo UPDATE_LOG_ESTADO_VENTA_ESQUINITA (hace lo mismo, sin duplicar)


--------------------------------------------------------------------------------
-- 2. AGREGAR COLUMNA OPERACION A LAS BITACORAS EXISTENTES
--------------------------------------------------------------------------------
ALTER TABLE LOG_FACT_VENTA_ESQUINITA            ADD (OPERACION VARCHAR2(10));
ALTER TABLE LOG_ESTADO_VENTA_ESQUINITA          ADD (OPERACION VARCHAR2(10));
ALTER TABLE LOG_METODO_PAGO_ESQUINITA           ADD (OPERACION VARCHAR2(10));
ALTER TABLE LOG_DETALLE_VENTA_ESQUINITA         ADD (OPERACION VARCHAR2(10));
ALTER TABLE LOG_FACT_COMPRA_ESQUINITA           ADD (OPERACION VARCHAR2(10));
ALTER TABLE LOG_ESTADO_COMPRA_ESQUINITA         ADD (OPERACION VARCHAR2(10));
ALTER TABLE LOG_DETALLE_COMPRA_ESQUINITA        ADD (OPERACION VARCHAR2(10));
ALTER TABLE LOG_FACT_PRODUCCION_ESQUINITA       ADD (OPERACION VARCHAR2(10));
ALTER TABLE LOG_INVENTARIO_INGREDIENTE_ESQUINITA ADD (OPERACION VARCHAR2(10));


--------------------------------------------------------------------------------
-- 3. RECREAR TRIGGERS: ahora tambien disparan en INSERT y DELETE
--    (antes solo disparaban en UPDATE de la columna indicada)
--------------------------------------------------------------------------------

-- FACT_VENTA / TOTAL_VENTA
CREATE OR REPLACE TRIGGER UPDATE_LOG_FACT_VENTA_ESQUINITA
AFTER INSERT OR UPDATE OF TOTAL_VENTA OR DELETE ON FACT_VENTA
FOR EACH ROW
DECLARE
    v_operacion VARCHAR2(10);
BEGIN
    IF INSERTING THEN v_operacion := 'INSERT';
    ELSIF UPDATING THEN v_operacion := 'UPDATE';
    ELSIF DELETING THEN v_operacion := 'DELETE';
    END IF;

    INSERT INTO LOG_FACT_VENTA_ESQUINITA
        (ID_VENTA, TOTAL_ANTERIOR, TOTAL_NUEVO, FECHA_CAMBIO, USUARIO, OPERACION)
    VALUES (
        NVL(:NEW.ID_VENTA, :OLD.ID_VENTA),
        :OLD.TOTAL_VENTA,
        :NEW.TOTAL_VENTA,
        SYSDATE,
        USER,
        v_operacion
    );
END;
/

-- FACT_VENTA / ESTADO_VENTA
CREATE OR REPLACE TRIGGER UPDATE_LOG_ESTADO_VENTA_ESQUINITA
AFTER INSERT OR UPDATE OF ESTADO_VENTA OR DELETE ON FACT_VENTA
FOR EACH ROW
DECLARE
    v_operacion VARCHAR2(10);
BEGIN
    IF INSERTING THEN v_operacion := 'INSERT';
    ELSIF UPDATING THEN v_operacion := 'UPDATE';
    ELSIF DELETING THEN v_operacion := 'DELETE';
    END IF;

    INSERT INTO LOG_ESTADO_VENTA_ESQUINITA
        (ID_VENTA, ESTADO_ANTERIOR, ESTADO_NUEVO, FECHA_CAMBIO, USUARIO, OPERACION)
    VALUES (
        NVL(:NEW.ID_VENTA, :OLD.ID_VENTA),
        :OLD.ESTADO_VENTA,
        :NEW.ESTADO_VENTA,
        SYSDATE,
        USER,
        v_operacion
    );
END;
/

-- FACT_VENTA / METODO_PAGO
CREATE OR REPLACE TRIGGER UPDATE_LOG_METODO_PAGO_ESQUINITA
AFTER INSERT OR UPDATE OF METODO_PAGO OR DELETE ON FACT_VENTA
FOR EACH ROW
DECLARE
    v_operacion VARCHAR2(10);
BEGIN
    IF INSERTING THEN v_operacion := 'INSERT';
    ELSIF UPDATING THEN v_operacion := 'UPDATE';
    ELSIF DELETING THEN v_operacion := 'DELETE';
    END IF;

    INSERT INTO LOG_METODO_PAGO_ESQUINITA
        (ID_VENTA, METODO_ANTERIOR, METODO_NUEVO, FECHA_CAMBIO, USUARIO, OPERACION)
    VALUES (
        NVL(:NEW.ID_VENTA, :OLD.ID_VENTA),
        :OLD.METODO_PAGO,
        :NEW.METODO_PAGO,
        SYSDATE,
        USER,
        v_operacion
    );
END;
/

-- FACT_DETALLE_VENTA / CANTIDAD, PRECIO_UNITARIO
CREATE OR REPLACE TRIGGER UPDATE_LOG_DETALLE_VENTA_ESQUINITA
AFTER INSERT OR UPDATE OF CANTIDAD, PRECIO_UNITARIO OR DELETE ON FACT_DETALLE_VENTA
FOR EACH ROW
DECLARE
    v_operacion VARCHAR2(10);
BEGIN
    IF INSERTING THEN v_operacion := 'INSERT';
    ELSIF UPDATING THEN v_operacion := 'UPDATE';
    ELSIF DELETING THEN v_operacion := 'DELETE';
    END IF;

    INSERT INTO LOG_DETALLE_VENTA_ESQUINITA
        (ID_DETALLE_VENTA, CANTIDAD_ANTERIOR, CANTIDAD_NUEVA, PRECIO_ANTERIOR, PRECIO_NUEVO, FECHA_CAMBIO, USUARIO, OPERACION)
    VALUES (
        NVL(:NEW.ID_DETALLE, :OLD.ID_DETALLE),
        :OLD.CANTIDAD,
        :NEW.CANTIDAD,
        :OLD.PRECIO_UNITARIO,
        :NEW.PRECIO_UNITARIO,
        SYSDATE,
        USER,
        v_operacion
    );
END;
/

-- FACT_COMPRA / TOTAL_COMPRA
CREATE OR REPLACE TRIGGER UPDATE_LOG_FACT_COMPRA_ESQUINITA
AFTER INSERT OR UPDATE OF TOTAL_COMPRA OR DELETE ON FACT_COMPRA
FOR EACH ROW
DECLARE
    v_operacion VARCHAR2(10);
BEGIN
    IF INSERTING THEN v_operacion := 'INSERT';
    ELSIF UPDATING THEN v_operacion := 'UPDATE';
    ELSIF DELETING THEN v_operacion := 'DELETE';
    END IF;

    INSERT INTO LOG_FACT_COMPRA_ESQUINITA
        (ID_COMPRA, TOTAL_ANTERIOR, TOTAL_NUEVO, FECHA_CAMBIO, USUARIO, OPERACION)
    VALUES (
        NVL(:NEW.ID_COMPRA, :OLD.ID_COMPRA),
        :OLD.TOTAL_COMPRA,
        :NEW.TOTAL_COMPRA,
        SYSDATE,
        USER,
        v_operacion
    );
END;
/

-- FACT_COMPRA / ESTADO
CREATE OR REPLACE TRIGGER UPDATE_LOG_ESTADO_COMPRA_ESQUINITA
AFTER INSERT OR UPDATE OF ESTADO OR DELETE ON FACT_COMPRA
FOR EACH ROW
DECLARE
    v_operacion VARCHAR2(10);
BEGIN
    IF INSERTING THEN v_operacion := 'INSERT';
    ELSIF UPDATING THEN v_operacion := 'UPDATE';
    ELSIF DELETING THEN v_operacion := 'DELETE';
    END IF;

    INSERT INTO LOG_ESTADO_COMPRA_ESQUINITA
        (ID_COMPRA, ESTADO_ANTERIOR, ESTADO_NUEVO, FECHA_CAMBIO, USUARIO, OPERACION)
    VALUES (
        NVL(:NEW.ID_COMPRA, :OLD.ID_COMPRA),
        :OLD.ESTADO,
        :NEW.ESTADO,
        SYSDATE,
        USER,
        v_operacion
    );
END;
/

-- FACT_DETALLE_COMPRA / CANTIDAD, COSTO_UNITARIO
CREATE OR REPLACE TRIGGER UPDATE_LOG_DETALLE_COMPRA_ESQUINITA
AFTER INSERT OR UPDATE OF CANTIDAD, COSTO_UNITARIO OR DELETE ON FACT_DETALLE_COMPRA
FOR EACH ROW
DECLARE
    v_operacion VARCHAR2(10);
BEGIN
    IF INSERTING THEN v_operacion := 'INSERT';
    ELSIF UPDATING THEN v_operacion := 'UPDATE';
    ELSIF DELETING THEN v_operacion := 'DELETE';
    END IF;

    INSERT INTO LOG_DETALLE_COMPRA_ESQUINITA
        (ID_DETALLE_COMPRA, CANTIDAD_ANTERIOR, CANTIDAD_NUEVA, COSTO_ANTERIOR, COSTO_NUEVO, FECHA_CAMBIO, USUARIO, OPERACION)
    VALUES (
        NVL(:NEW.ID_DETALLE_COMPRA, :OLD.ID_DETALLE_COMPRA),
        :OLD.CANTIDAD,
        :NEW.CANTIDAD,
        :OLD.COSTO_UNITARIO,
        :NEW.COSTO_UNITARIO,
        SYSDATE,
        USER,
        v_operacion
    );
END;
/

-- FACT_PRODUCCION / CANTIDAD_PRODUCIDA
CREATE OR REPLACE TRIGGER UPDATE_LOG_FACT_PRODUCCION_ESQUINITA
AFTER INSERT OR UPDATE OF CANTIDAD_PRODUCIDA OR DELETE ON FACT_PRODUCCION
FOR EACH ROW
DECLARE
    v_operacion VARCHAR2(10);
BEGIN
    IF INSERTING THEN v_operacion := 'INSERT';
    ELSIF UPDATING THEN v_operacion := 'UPDATE';
    ELSIF DELETING THEN v_operacion := 'DELETE';
    END IF;

    INSERT INTO LOG_FACT_PRODUCCION_ESQUINITA
        (ID_PRODUCCION, CANTIDAD_ANTERIOR, CANTIDAD_NUEVA, FECHA_CAMBIO, USUARIO, OPERACION)
    VALUES (
        NVL(:NEW.ID_PRODUCCION, :OLD.ID_PRODUCCION),
        :OLD.CANTIDAD_PRODUCIDA,
        :NEW.CANTIDAD_PRODUCIDA,
        SYSDATE,
        USER,
        v_operacion
    );
END;
/

-- FACT_INVENTARIO_INGREDIENTE / CANTIDAD_DISPONIBLE
CREATE OR REPLACE TRIGGER UPDATE_LOG_INVENTARIO_ING_ESQUINITA
AFTER INSERT OR UPDATE OF CANTIDAD_DISPONIBLE OR DELETE ON FACT_INVENTARIO_INGREDIENTE
FOR EACH ROW
DECLARE
    v_operacion VARCHAR2(10);
BEGIN
    IF INSERTING THEN v_operacion := 'INSERT';
    ELSIF UPDATING THEN v_operacion := 'UPDATE';
    ELSIF DELETING THEN v_operacion := 'DELETE';
    END IF;

    INSERT INTO LOG_INVENTARIO_INGREDIENTE_ESQUINITA
        (ID_INGREDIENTE, CANTIDAD_ANTERIOR, CANTIDAD_NUEVA, FECHA_CAMBIO, USUARIO, OPERACION)
    VALUES (
        NVL(:NEW.ID_INGREDIENTE, :OLD.ID_INGREDIENTE),
        :OLD.CANTIDAD_DISPONIBLE,
        :NEW.CANTIDAD_DISPONIBLE,
        SYSDATE,
        USER,
        v_operacion
    );
END;
/


--------------------------------------------------------------------------------
-- 4. AUDITORIA DE LAS TABLAS ENCRIPTADAS
--------------------------------------------------------------------------------

------------------------------
-- DIM_CLIENTE
------------------------------
CREATE TABLE LOG_DIM_CLIENTE_ESQUINITA (
    ID_CLIENTE        NUMBER,
    NOMBRE_ANTERIOR   VARCHAR2(250 BYTE),
    NOMBRE_NUEVO      VARCHAR2(250 BYTE),
    TELEFONO_ANTERIOR VARCHAR2(80  BYTE),
    TELEFONO_NUEVO    VARCHAR2(80  BYTE),
    CORREO_ANTERIOR   VARCHAR2(280 BYTE),
    CORREO_NUEVO      VARCHAR2(280 BYTE),
    FECHA_CAMBIO      DATE,
    USUARIO           VARCHAR2(30),
    OPERACION         VARCHAR2(10)
);

CREATE OR REPLACE TRIGGER UPDATE_LOG_DIM_CLIENTE_ESQUINITA
AFTER INSERT OR UPDATE OF NOMBRE, TELEFONO, CORREO OR DELETE ON DIM_CLIENTE
FOR EACH ROW
DECLARE
    v_operacion VARCHAR2(10);
BEGIN
    IF INSERTING THEN v_operacion := 'INSERT';
    ELSIF UPDATING THEN v_operacion := 'UPDATE';
    ELSIF DELETING THEN v_operacion := 'DELETE';
    END IF;

    INSERT INTO LOG_DIM_CLIENTE_ESQUINITA
        (ID_CLIENTE, NOMBRE_ANTERIOR, NOMBRE_NUEVO, TELEFONO_ANTERIOR, TELEFONO_NUEVO,
         CORREO_ANTERIOR, CORREO_NUEVO, FECHA_CAMBIO, USUARIO, OPERACION)
    VALUES (
        NVL(:NEW.ID_CLIENTE, :OLD.ID_CLIENTE),
        :OLD.NOMBRE, :NEW.NOMBRE,
        :OLD.TELEFONO, :NEW.TELEFONO,
        :OLD.CORREO, :NEW.CORREO,
        SYSDATE,
        USER,
        v_operacion
    );
END;
/

------------------------------
-- DIM_EMPLEADO
------------------------------
CREATE TABLE LOG_DIM_EMPLEADO_ESQUINITA (
    ID_EMPLEADO       NUMBER,
    NOMBRE_ANTERIOR   VARCHAR2(150 BYTE),
    NOMBRE_NUEVO      VARCHAR2(150 BYTE),
    APELLIDO_ANTERIOR VARCHAR2(150 BYTE),
    APELLIDO_NUEVO    VARCHAR2(150 BYTE),
    SALARIO_ANTERIOR  VARCHAR2(60  BYTE),
    SALARIO_NUEVO     VARCHAR2(60  BYTE),
    FECHA_CAMBIO      DATE,
    USUARIO           VARCHAR2(30),
    OPERACION         VARCHAR2(10)
);

CREATE OR REPLACE TRIGGER UPDATE_LOG_DIM_EMPLEADO_ESQUINITA
AFTER INSERT OR UPDATE OF NOMBRE, APELLIDO, SALARIO OR DELETE ON DIM_EMPLEADO
FOR EACH ROW
DECLARE
    v_operacion VARCHAR2(10);
BEGIN
    IF INSERTING THEN v_operacion := 'INSERT';
    ELSIF UPDATING THEN v_operacion := 'UPDATE';
    ELSIF DELETING THEN v_operacion := 'DELETE';
    END IF;

    INSERT INTO LOG_DIM_EMPLEADO_ESQUINITA
        (ID_EMPLEADO, NOMBRE_ANTERIOR, NOMBRE_NUEVO, APELLIDO_ANTERIOR, APELLIDO_NUEVO,
         SALARIO_ANTERIOR, SALARIO_NUEVO, FECHA_CAMBIO, USUARIO, OPERACION)
    VALUES (
        NVL(:NEW.ID_EMPLEADO, :OLD.ID_EMPLEADO),
        :OLD.NOMBRE, :NEW.NOMBRE,
        :OLD.APELLIDO, :NEW.APELLIDO,
        :OLD.SALARIO, :NEW.SALARIO,
        SYSDATE,
        USER,
        v_operacion
    );
END;
/

------------------------------
-- DIM_PROVEEDOR
------------------------------
CREATE TABLE LOG_DIM_PROVEEDOR_ESQUINITA (
    ID_PROVEEDOR            NUMBER,
    NOMBRE_EMPRESA_ANTERIOR VARCHAR2(250 BYTE),
    NOMBRE_EMPRESA_NUEVO    VARCHAR2(250 BYTE),
    CONTACTO_ANTERIOR       VARCHAR2(250 BYTE),
    CONTACTO_NUEVO          VARCHAR2(250 BYTE),
    TELEFONO_ANTERIOR       VARCHAR2(80  BYTE),
    TELEFONO_NUEVO          VARCHAR2(80  BYTE),
    CORREO_ANTERIOR         VARCHAR2(280 BYTE),
    CORREO_NUEVO            VARCHAR2(280 BYTE),
    DIRECCION_ANTERIOR      VARCHAR2(450 BYTE),
    DIRECCION_NUEVO         VARCHAR2(450 BYTE),
    FECHA_CAMBIO            DATE,
    USUARIO                 VARCHAR2(30),
    OPERACION               VARCHAR2(10)
);

CREATE OR REPLACE TRIGGER UPDATE_LOG_DIM_PROVEEDOR_ESQUINITA
AFTER INSERT OR UPDATE OF NOMBRE_EMPRESA, CONTACTO, TELEFONO, CORREO, DIRECCION OR DELETE ON DIM_PROVEEDOR
FOR EACH ROW
DECLARE
    v_operacion VARCHAR2(10);
BEGIN
    IF INSERTING THEN v_operacion := 'INSERT';
    ELSIF UPDATING THEN v_operacion := 'UPDATE';
    ELSIF DELETING THEN v_operacion := 'DELETE';
    END IF;

    INSERT INTO LOG_DIM_PROVEEDOR_ESQUINITA
        (ID_PROVEEDOR, NOMBRE_EMPRESA_ANTERIOR, NOMBRE_EMPRESA_NUEVO,
         CONTACTO_ANTERIOR, CONTACTO_NUEVO,
         TELEFONO_ANTERIOR, TELEFONO_NUEVO,
         CORREO_ANTERIOR, CORREO_NUEVO,
         DIRECCION_ANTERIOR, DIRECCION_NUEVO,
         FECHA_CAMBIO, USUARIO, OPERACION)
    VALUES (
        NVL(:NEW.ID_PROVEEDOR, :OLD.ID_PROVEEDOR),
        :OLD.NOMBRE_EMPRESA, :NEW.NOMBRE_EMPRESA,
        :OLD.CONTACTO, :NEW.CONTACTO,
        :OLD.TELEFONO, :NEW.TELEFONO,
        :OLD.CORREO, :NEW.CORREO,
        :OLD.DIRECCION, :NEW.DIRECCION,
        SYSDATE,
        USER,
        v_operacion
    );
END;
/


--------------------------------------------------------------------------------
-- 5. VERIFICACION
--------------------------------------------------------------------------------

-- Todos deberian aparecer VALID
SELECT trigger_name, table_name, status
  FROM user_triggers
 WHERE trigger_name LIKE 'UPDATE_LOG%'
 ORDER BY table_name, trigger_name;

-- Para leer una bitacora de datos encriptados en texto plano 
-- SELECT ID_CLIENTE, OPERACION, FECHA_CAMBIO, USUARIO,
--        desencriptar_texto(NOMBRE_ANTERIOR) AS NOMBRE_ANTERIOR,
--        desencriptar_texto(NOMBRE_NUEVO)    AS NOMBRE_NUEVO
--   FROM LOG_DIM_CLIENTE_ESQUINITA
--  ORDER BY FECHA_CAMBIO DESC;


--------------------------------------------------------------------------------
-- 6. PRUEBA RAPIDA (no toca datos reales)
--------------------------------------------------------------------------------
-- INSERT INTO DIM_CLIENTE (NOMBRE, TELEFONO, CORREO, FECHA_REGISTRO)
-- VALUES ('Auditoria Test', '87654321', 'auditoria@test.com', SYSDATE);
--
-- SELECT OPERACION, FECHA_CAMBIO, USUARIO,
--        desencriptar_texto(NOMBRE_NUEVO) AS NOMBRE_NUEVO
--   FROM LOG_DIM_CLIENTE_ESQUINITA
--  ORDER BY FECHA_CAMBIO DESC FETCH FIRST 1 ROWS ONLY;
--
-- DELETE FROM DIM_CLIENTE WHERE NOMBRE = encriptar_texto('Auditoria Test');
--
-- SELECT OPERACION, FECHA_CAMBIO, USUARIO,
--        desencriptar_texto(NOMBRE_ANTERIOR) AS NOMBRE_BORRADO
--   FROM LOG_DIM_CLIENTE_ESQUINITA

-- Prueba de Auditoria Seguridad
-- Insertar una venta de prueba (ajustá ID_CLIENTE, ID_EMPLEADO, ID_TIEMPO a valores que existan)
INSERT INTO FACT_VENTA (ID_VENTA, ID_CLIENTE, ID_EMPLEADO, ID_TIEMPO, TOTAL_VENTA, METODO_PAGO, ESTADO_VENTA)
VALUES (9999, (SELECT MIN(ID_CLIENTE) FROM DIM_CLIENTE), (SELECT MIN(ID_EMPLEADO) FROM DIM_EMPLEADO),
        (SELECT MIN(ID_TIEMPO) FROM DIM_TIEMPO), 1000, 'EFECTIVO', 'PENDIENTE');

-- Modificarla (dispara los 3 triggers: total, estado, metodo)
UPDATE FACT_VENTA SET TOTAL_VENTA = 1500, ESTADO_VENTA = 'COMPLETADA', METODO_PAGO = 'TARJETA'
WHERE ID_VENTA = 9999;

-- Borrarla
DELETE FROM FACT_VENTA WHERE ID_VENTA = 9999;
COMMIT;

-- Verificar: cada bitácora debe mostrar INSERT, UPDATE y DELETE para ID_VENTA = 9999
SELECT * FROM LOG_FACT_VENTA_ESQUINITA   WHERE ID_VENTA = 9999 ORDER BY FECHA_CAMBIO;
SELECT * FROM LOG_ESTADO_VENTA_ESQUINITA WHERE ID_VENTA = 9999 ORDER BY FECHA_CAMBIO;
SELECT * FROM LOG_METODO_PAGO_ESQUINITA  WHERE ID_VENTA = 9999 ORDER BY FECHA_CAMBIO;

-- --------------------------------------------------------------------------------
-- Prueba Sobre tabla encriptada
-- --------------------------------------------------------------------------------
INSERT INTO DIM_CLIENTE (NOMBRE, TELEFONO, CORREO, FECHA_REGISTRO)
VALUES ('Auditoria Test', '87654321', 'auditoria@test.com', SYSDATE);

UPDATE DIM_CLIENTE SET TELEFONO = '99998888'
WHERE NOMBRE = encriptar_texto('Auditoria Test');

DELETE FROM DIM_CLIENTE WHERE NOMBRE = encriptar_texto('Auditoria Test');
COMMIT;

-- Verificar, mostrando los valores en texto plano (no el cifrado)
SELECT OPERACION, FECHA_CAMBIO, USUARIO,
       desencriptar_texto(NOMBRE_ANTERIOR)   AS NOMBRE_ANTERIOR,
       desencriptar_texto(NOMBRE_NUEVO)      AS NOMBRE_NUEVO,
       desencriptar_texto(TELEFONO_ANTERIOR) AS TEL_ANTERIOR,
       desencriptar_texto(TELEFONO_NUEVO)    AS TEL_NUEVO
  FROM LOG_DIM_CLIENTE_ESQUINITA
 ORDER BY FECHA_CAMBIO DESC
 FETCH FIRST 3 ROWS ONLY;
 -- ----------------------------------------------------------------------------
 -- Vista general de todo lo auditado recientemente
 SELECT 'FACT_VENTA' AS TABLA, OPERACION, USUARIO, FECHA_CAMBIO FROM LOG_FACT_VENTA_ESQUINITA
UNION ALL
SELECT 'DIM_CLIENTE', OPERACION, USUARIO, FECHA_CAMBIO FROM LOG_DIM_CLIENTE_ESQUINITA
ORDER BY FECHA_CAMBIO DESC;

--  ORDER BY FECHA_CAMBIO DESC FETCH FIRST 1 ROWS ONLY;
--------------------------------------------------------------------------------


    
    /* ============================================================
   POLÍTICAS DE AUDITORÍA
   PROYECTO: LA ESQUINITA DEL PAN
   ESQUEMA: USR_ADMIN_ESQUINITA

   Registra:
   SELECT
   INSERT
   UPDATE
   DELETE

   sobre las tablas indicadas.
   ============================================================ */


/* ============================================================
   1. TABLAS DIMENSIONALES
   ============================================================ */

CREATE AUDIT POLICY POL_AUDIT_DIM_CATEGORIA
ACTIONS
    SELECT ON USR_ADMIN_ESQUINITA.DIM_CATEGORIA_PRODUCTO,
    INSERT ON USR_ADMIN_ESQUINITA.DIM_CATEGORIA_PRODUCTO,
    UPDATE ON USR_ADMIN_ESQUINITA.DIM_CATEGORIA_PRODUCTO,
    DELETE ON USR_ADMIN_ESQUINITA.DIM_CATEGORIA_PRODUCTO;

CREATE AUDIT POLICY POL_AUDIT_DIM_CLIENTE
ACTIONS
    SELECT ON USR_ADMIN_ESQUINITA.DIM_CLIENTE,
    INSERT ON USR_ADMIN_ESQUINITA.DIM_CLIENTE,
    UPDATE ON USR_ADMIN_ESQUINITA.DIM_CLIENTE,
    DELETE ON USR_ADMIN_ESQUINITA.DIM_CLIENTE;

CREATE AUDIT POLICY POL_AUDIT_DIM_CLIENTE_BAK
ACTIONS
    SELECT ON USR_ADMIN_ESQUINITA.DIM_CLIENTE_BAK,
    INSERT ON USR_ADMIN_ESQUINITA.DIM_CLIENTE_BAK,
    UPDATE ON USR_ADMIN_ESQUINITA.DIM_CLIENTE_BAK,
    DELETE ON USR_ADMIN_ESQUINITA.DIM_CLIENTE_BAK;

CREATE AUDIT POLICY POL_AUDIT_DIM_EMPLEADO
ACTIONS
    SELECT ON USR_ADMIN_ESQUINITA.DIM_EMPLEADO,
    INSERT ON USR_ADMIN_ESQUINITA.DIM_EMPLEADO,
    UPDATE ON USR_ADMIN_ESQUINITA.DIM_EMPLEADO,
    DELETE ON USR_ADMIN_ESQUINITA.DIM_EMPLEADO;

CREATE AUDIT POLICY POL_AUDIT_DIM_EMPLEADO_BAK
ACTIONS
    SELECT ON USR_ADMIN_ESQUINITA.DIM_EMPLEADO_BAK,
    INSERT ON USR_ADMIN_ESQUINITA.DIM_EMPLEADO_BAK,
    UPDATE ON USR_ADMIN_ESQUINITA.DIM_EMPLEADO_BAK,
    DELETE ON USR_ADMIN_ESQUINITA.DIM_EMPLEADO_BAK;

CREATE AUDIT POLICY POL_AUDIT_DIM_INGREDIENTE
ACTIONS
    SELECT ON USR_ADMIN_ESQUINITA.DIM_INGREDIENTE,
    INSERT ON USR_ADMIN_ESQUINITA.DIM_INGREDIENTE,
    UPDATE ON USR_ADMIN_ESQUINITA.DIM_INGREDIENTE,
    DELETE ON USR_ADMIN_ESQUINITA.DIM_INGREDIENTE;

CREATE AUDIT POLICY POL_AUDIT_DIM_PRODUCTO
ACTIONS
    SELECT ON USR_ADMIN_ESQUINITA.DIM_PRODUCTO,
    INSERT ON USR_ADMIN_ESQUINITA.DIM_PRODUCTO,
    UPDATE ON USR_ADMIN_ESQUINITA.DIM_PRODUCTO,
    DELETE ON USR_ADMIN_ESQUINITA.DIM_PRODUCTO;

CREATE AUDIT POLICY POL_AUDIT_DIM_PROVEEDOR
ACTIONS
    SELECT ON USR_ADMIN_ESQUINITA.DIM_PROVEEDOR,
    INSERT ON USR_ADMIN_ESQUINITA.DIM_PROVEEDOR,
    UPDATE ON USR_ADMIN_ESQUINITA.DIM_PROVEEDOR,
    DELETE ON USR_ADMIN_ESQUINITA.DIM_PROVEEDOR;

CREATE AUDIT POLICY POL_AUDIT_DIM_PROVEEDOR_BAK
ACTIONS
    SELECT ON USR_ADMIN_ESQUINITA.DIM_PROVEEDOR_BAK,
    INSERT ON USR_ADMIN_ESQUINITA.DIM_PROVEEDOR_BAK,
    UPDATE ON USR_ADMIN_ESQUINITA.DIM_PROVEEDOR_BAK,
    DELETE ON USR_ADMIN_ESQUINITA.DIM_PROVEEDOR_BAK;

CREATE AUDIT POLICY POL_AUDIT_DIM_TIEMPO
ACTIONS
    SELECT ON USR_ADMIN_ESQUINITA.DIM_TIEMPO,
    INSERT ON USR_ADMIN_ESQUINITA.DIM_TIEMPO,
    UPDATE ON USR_ADMIN_ESQUINITA.DIM_TIEMPO,
    DELETE ON USR_ADMIN_ESQUINITA.DIM_TIEMPO;


/* ============================================================
   2. TABLAS FACT
   ============================================================ */

CREATE AUDIT POLICY POL_AUDIT_FACT_COMPRA
ACTIONS
    SELECT ON USR_ADMIN_ESQUINITA.FACT_COMPRA,
    INSERT ON USR_ADMIN_ESQUINITA.FACT_COMPRA,
    UPDATE ON USR_ADMIN_ESQUINITA.FACT_COMPRA,
    DELETE ON USR_ADMIN_ESQUINITA.FACT_COMPRA;

CREATE AUDIT POLICY POL_AUDIT_FACT_DETALLE_COMPRA
ACTIONS
    SELECT ON USR_ADMIN_ESQUINITA.FACT_DETALLE_COMPRA,
    INSERT ON USR_ADMIN_ESQUINITA.FACT_DETALLE_COMPRA,
    UPDATE ON USR_ADMIN_ESQUINITA.FACT_DETALLE_COMPRA,
    DELETE ON USR_ADMIN_ESQUINITA.FACT_DETALLE_COMPRA;

CREATE AUDIT POLICY POL_AUDIT_FACT_DETALLE_VENTA
ACTIONS
    SELECT ON USR_ADMIN_ESQUINITA.FACT_DETALLE_VENTA,
    INSERT ON USR_ADMIN_ESQUINITA.FACT_DETALLE_VENTA,
    UPDATE ON USR_ADMIN_ESQUINITA.FACT_DETALLE_VENTA,
    DELETE ON USR_ADMIN_ESQUINITA.FACT_DETALLE_VENTA;

CREATE AUDIT POLICY POL_AUDIT_FACT_DETALLE_VENTA_BAK
ACTIONS
    SELECT ON USR_ADMIN_ESQUINITA.FACT_DETALLE_VENTA_BAK,
    INSERT ON USR_ADMIN_ESQUINITA.FACT_DETALLE_VENTA_BAK,
    UPDATE ON USR_ADMIN_ESQUINITA.FACT_DETALLE_VENTA_BAK,
    DELETE ON USR_ADMIN_ESQUINITA.FACT_DETALLE_VENTA_BAK;

CREATE AUDIT POLICY POL_AUDIT_FACT_INVENTARIO_BAK
ACTIONS
    SELECT ON USR_ADMIN_ESQUINITA.FACT_INVENTARIO_BAK,
    INSERT ON USR_ADMIN_ESQUINITA.FACT_INVENTARIO_BAK,
    UPDATE ON USR_ADMIN_ESQUINITA.FACT_INVENTARIO_BAK,
    DELETE ON USR_ADMIN_ESQUINITA.FACT_INVENTARIO_BAK;

CREATE AUDIT POLICY POL_AUDIT_FACT_INVENTARIO_ING
ACTIONS
    SELECT ON USR_ADMIN_ESQUINITA.FACT_INVENTARIO_INGREDIENTE,
    INSERT ON USR_ADMIN_ESQUINITA.FACT_INVENTARIO_INGREDIENTE,
    UPDATE ON USR_ADMIN_ESQUINITA.FACT_INVENTARIO_INGREDIENTE,
    DELETE ON USR_ADMIN_ESQUINITA.FACT_INVENTARIO_INGREDIENTE;

CREATE AUDIT POLICY POL_AUDIT_FACT_PRODUCCION
ACTIONS
    SELECT ON USR_ADMIN_ESQUINITA.FACT_PRODUCCION,
    INSERT ON USR_ADMIN_ESQUINITA.FACT_PRODUCCION,
    UPDATE ON USR_ADMIN_ESQUINITA.FACT_PRODUCCION,
    DELETE ON USR_ADMIN_ESQUINITA.FACT_PRODUCCION;

CREATE AUDIT POLICY POL_AUDIT_FACT_PRODUCCION_BAK
ACTIONS
    SELECT ON USR_ADMIN_ESQUINITA.FACT_PRODUCCION_BAK,
    INSERT ON USR_ADMIN_ESQUINITA.FACT_PRODUCCION_BAK,
    UPDATE ON USR_ADMIN_ESQUINITA.FACT_PRODUCCION_BAK,
    DELETE ON USR_ADMIN_ESQUINITA.FACT_PRODUCCION_BAK;


/* ============================================================
   NOTA:
   FACT_VENTA YA TIENE LA POLÍTICA:

   POL_AUDIT_VENTAS

   Por lo tanto NO se vuelve a crear aquí.
   ============================================================ */


/* ============================================================
   3. TABLAS DE LOG
   ============================================================ */

CREATE AUDIT POLICY POL_AUDIT_LOG_DETALLE_COMPRA
ACTIONS
    SELECT ON USR_ADMIN_ESQUINITA.LOG_DETALLE_COMPRA_ESQUINITA,
    INSERT ON USR_ADMIN_ESQUINITA.LOG_DETALLE_COMPRA_ESQUINITA,
    UPDATE ON USR_ADMIN_ESQUINITA.LOG_DETALLE_COMPRA_ESQUINITA,
    DELETE ON USR_ADMIN_ESQUINITA.LOG_DETALLE_COMPRA_ESQUINITA;

CREATE AUDIT POLICY POL_AUDIT_LOG_DETALLE_VENTA
ACTIONS
    SELECT ON USR_ADMIN_ESQUINITA.LOG_DETALLE_VENTA_ESQUINITA,
    INSERT ON USR_ADMIN_ESQUINITA.LOG_DETALLE_VENTA_ESQUINITA,
    UPDATE ON USR_ADMIN_ESQUINITA.LOG_DETALLE_VENTA_ESQUINITA,
    DELETE ON USR_ADMIN_ESQUINITA.LOG_DETALLE_VENTA_ESQUINITA;

CREATE AUDIT POLICY POL_AUDIT_LOG_DIM_CLIENTE
ACTIONS
    SELECT ON USR_ADMIN_ESQUINITA.LOG_DIM_CLIENTE_ESQUINITA,
    INSERT ON USR_ADMIN_ESQUINITA.LOG_DIM_CLIENTE_ESQUINITA,
    UPDATE ON USR_ADMIN_ESQUINITA.LOG_DIM_CLIENTE_ESQUINITA,
    DELETE ON USR_ADMIN_ESQUINITA.LOG_DIM_CLIENTE_ESQUINITA;

CREATE AUDIT POLICY POL_AUDIT_LOG_DIM_EMPLEADO
ACTIONS
    SELECT ON USR_ADMIN_ESQUINITA.LOG_DIM_EMPLEADO_ESQUINITA,
    INSERT ON USR_ADMIN_ESQUINITA.LOG_DIM_EMPLEADO_ESQUINITA,
    UPDATE ON USR_ADMIN_ESQUINITA.LOG_DIM_EMPLEADO_ESQUINITA,
    DELETE ON USR_ADMIN_ESQUINITA.LOG_DIM_EMPLEADO_ESQUINITA;

CREATE AUDIT POLICY POL_AUDIT_LOG_DIM_PROVEEDOR
ACTIONS
    SELECT ON USR_ADMIN_ESQUINITA.LOG_DIM_PROVEEDOR_ESQUINITA,
    INSERT ON USR_ADMIN_ESQUINITA.LOG_DIM_PROVEEDOR_ESQUINITA,
    UPDATE ON USR_ADMIN_ESQUINITA.LOG_DIM_PROVEEDOR_ESQUINITA,
    DELETE ON USR_ADMIN_ESQUINITA.LOG_DIM_PROVEEDOR_ESQUINITA;

CREATE AUDIT POLICY POL_AUDIT_LOG_ESTADO_COMPRA
ACTIONS
    SELECT ON USR_ADMIN_ESQUINITA.LOG_ESTADO_COMPRA_ESQUINITA,
    INSERT ON USR_ADMIN_ESQUINITA.LOG_ESTADO_COMPRA_ESQUINITA,
    UPDATE ON USR_ADMIN_ESQUINITA.LOG_ESTADO_COMPRA_ESQUINITA,
    DELETE ON USR_ADMIN_ESQUINITA.LOG_ESTADO_COMPRA_ESQUINITA;

CREATE AUDIT POLICY POL_AUDIT_LOG_ESTADO_VENTA
ACTIONS
    SELECT ON USR_ADMIN_ESQUINITA.LOG_ESTADO_VENTA_ESQUINITA,
    INSERT ON USR_ADMIN_ESQUINITA.LOG_ESTADO_VENTA_ESQUINITA,
    UPDATE ON USR_ADMIN_ESQUINITA.LOG_ESTADO_VENTA_ESQUINITA,
    DELETE ON USR_ADMIN_ESQUINITA.LOG_ESTADO_VENTA_ESQUINITA;

CREATE AUDIT POLICY POL_AUDIT_LOG_FACT_COMPRA
ACTIONS
    SELECT ON USR_ADMIN_ESQUINITA.LOG_FACT_COMPRA_ESQUINITA,
    INSERT ON USR_ADMIN_ESQUINITA.LOG_FACT_COMPRA_ESQUINITA,
    UPDATE ON USR_ADMIN_ESQUINITA.LOG_FACT_COMPRA_ESQUINITA,
    DELETE ON USR_ADMIN_ESQUINITA.LOG_FACT_COMPRA_ESQUINITA;

CREATE AUDIT POLICY POL_AUDIT_LOG_FACT_PRODUCCION
ACTIONS
    SELECT ON USR_ADMIN_ESQUINITA.LOG_FACT_PRODUCCION_ESQUINITA,
    INSERT ON USR_ADMIN_ESQUINITA.LOG_FACT_PRODUCCION_ESQUINITA,
    UPDATE ON USR_ADMIN_ESQUINITA.LOG_FACT_PRODUCCION_ESQUINITA,
    DELETE ON USR_ADMIN_ESQUINITA.LOG_FACT_PRODUCCION_ESQUINITA;

CREATE AUDIT POLICY POL_AUDIT_LOG_FACT_VENTA
ACTIONS
    SELECT ON USR_ADMIN_ESQUINITA.LOG_FACT_VENTA_ESQUINITA,
    INSERT ON USR_ADMIN_ESQUINITA.LOG_FACT_VENTA_ESQUINITA,
    UPDATE ON USR_ADMIN_ESQUINITA.LOG_FACT_VENTA_ESQUINITA,
    DELETE ON USR_ADMIN_ESQUINITA.LOG_FACT_VENTA_ESQUINITA;

CREATE AUDIT POLICY POL_AUDIT_LOG_INVENTARIO
ACTIONS
    SELECT ON USR_ADMIN_ESQUINITA.LOG_INVENTARIO_INGREDIENTE_ESQUINITA,
    INSERT ON USR_ADMIN_ESQUINITA.LOG_INVENTARIO_INGREDIENTE_ESQUINITA,
    UPDATE ON USR_ADMIN_ESQUINITA.LOG_INVENTARIO_INGREDIENTE_ESQUINITA,
    DELETE ON USR_ADMIN_ESQUINITA.LOG_INVENTARIO_INGREDIENTE_ESQUINITA;

CREATE AUDIT POLICY POL_AUDIT_LOG_METODO_PAGO
ACTIONS
    SELECT ON USR_ADMIN_ESQUINITA.LOG_METODO_PAGO_ESQUINITA,
    INSERT ON USR_ADMIN_ESQUINITA.LOG_METODO_PAGO_ESQUINITA,
    UPDATE ON USR_ADMIN_ESQUINITA.LOG_METODO_PAGO_ESQUINITA,
    DELETE ON USR_ADMIN_ESQUINITA.LOG_METODO_PAGO_ESQUINITA;


/* ============================================================
   5. HABILITAR LAS POLÍTICAS
   ============================================================ */

AUDIT POLICY POL_AUDIT_DIM_CATEGORIA
BY USR_ADMIN_ESQUINITA, USR_CAJERO_ESQUINITA, USR_PRODUCCION_ESQUINITA;

AUDIT POLICY POL_AUDIT_DIM_CLIENTE
BY USR_ADMIN_ESQUINITA, USR_CAJERO_ESQUINITA, USR_PRODUCCION_ESQUINITA;

AUDIT POLICY POL_AUDIT_DIM_CLIENTE_BAK
BY USR_ADMIN_ESQUINITA, USR_CAJERO_ESQUINITA, USR_PRODUCCION_ESQUINITA;

AUDIT POLICY POL_AUDIT_DIM_EMPLEADO
BY USR_ADMIN_ESQUINITA, USR_CAJERO_ESQUINITA, USR_PRODUCCION_ESQUINITA;

AUDIT POLICY POL_AUDIT_DIM_EMPLEADO_BAK
BY USR_ADMIN_ESQUINITA, USR_CAJERO_ESQUINITA, USR_PRODUCCION_ESQUINITA;

AUDIT POLICY POL_AUDIT_DIM_INGREDIENTE
BY USR_ADMIN_ESQUINITA, USR_CAJERO_ESQUINITA, USR_PRODUCCION_ESQUINITA;

AUDIT POLICY POL_AUDIT_DIM_PRODUCTO
BY USR_ADMIN_ESQUINITA, USR_CAJERO_ESQUINITA, USR_PRODUCCION_ESQUINITA;

AUDIT POLICY POL_AUDIT_DIM_PROVEEDOR
BY USR_ADMIN_ESQUINITA, USR_CAJERO_ESQUINITA, USR_PRODUCCION_ESQUINITA;

AUDIT POLICY POL_AUDIT_DIM_PROVEEDOR_BAK
BY USR_ADMIN_ESQUINITA, USR_CAJERO_ESQUINITA, USR_PRODUCCION_ESQUINITA;

AUDIT POLICY POL_AUDIT_DIM_TIEMPO
BY USR_ADMIN_ESQUINITA, USR_CAJERO_ESQUINITA, USR_PRODUCCION_ESQUINITA;

AUDIT POLICY POL_AUDIT_FACT_COMPRA
BY USR_ADMIN_ESQUINITA, USR_CAJERO_ESQUINITA, USR_PRODUCCION_ESQUINITA;

AUDIT POLICY POL_AUDIT_FACT_DETALLE_COMPRA
BY USR_ADMIN_ESQUINITA, USR_CAJERO_ESQUINITA, USR_PRODUCCION_ESQUINITA;

AUDIT POLICY POL_AUDIT_FACT_DETALLE_VENTA
BY USR_ADMIN_ESQUINITA, USR_CAJERO_ESQUINITA, USR_PRODUCCION_ESQUINITA;

AUDIT POLICY POL_AUDIT_FACT_DETALLE_VENTA_BAK
BY USR_ADMIN_ESQUINITA, USR_CAJERO_ESQUINITA, USR_PRODUCCION_ESQUINITA;

AUDIT POLICY POL_AUDIT_FACT_INVENTARIO_BAK
BY USR_ADMIN_ESQUINITA, USR_CAJERO_ESQUINITA, USR_PRODUCCION_ESQUINITA;

AUDIT POLICY POL_AUDIT_FACT_INVENTARIO_ING
BY USR_ADMIN_ESQUINITA, USR_CAJERO_ESQUINITA, USR_PRODUCCION_ESQUINITA;

AUDIT POLICY POL_AUDIT_FACT_PRODUCCION
BY USR_ADMIN_ESQUINITA, USR_CAJERO_ESQUINITA, USR_PRODUCCION_ESQUINITA;

AUDIT POLICY POL_AUDIT_FACT_PRODUCCION_BAK
BY USR_ADMIN_ESQUINITA, USR_CAJERO_ESQUINITA, USR_PRODUCCION_ESQUINITA;

AUDIT POLICY POL_AUDIT_LOG_DETALLE_COMPRA
BY USR_ADMIN_ESQUINITA, USR_CAJERO_ESQUINITA, USR_PRODUCCION_ESQUINITA;

AUDIT POLICY POL_AUDIT_LOG_DETALLE_VENTA
BY USR_ADMIN_ESQUINITA, USR_CAJERO_ESQUINITA, USR_PRODUCCION_ESQUINITA;

AUDIT POLICY POL_AUDIT_LOG_DIM_CLIENTE
BY USR_ADMIN_ESQUINITA, USR_CAJERO_ESQUINITA, USR_PRODUCCION_ESQUINITA;

AUDIT POLICY POL_AUDIT_LOG_DIM_EMPLEADO
BY USR_ADMIN_ESQUINITA, USR_CAJERO_ESQUINITA, USR_PRODUCCION_ESQUINITA;

AUDIT POLICY POL_AUDIT_LOG_DIM_PROVEEDOR
BY USR_ADMIN_ESQUINITA, USR_CAJERO_ESQUINITA, USR_PRODUCCION_ESQUINITA;

AUDIT POLICY POL_AUDIT_LOG_ESTADO_COMPRA
BY USR_ADMIN_ESQUINITA, USR_CAJERO_ESQUINITA, USR_PRODUCCION_ESQUINITA;

AUDIT POLICY POL_AUDIT_LOG_ESTADO_VENTA
BY USR_ADMIN_ESQUINITA, USR_CAJERO_ESQUINITA, USR_PRODUCCION_ESQUINITA;

AUDIT POLICY POL_AUDIT_LOG_FACT_COMPRA
BY USR_ADMIN_ESQUINITA, USR_CAJERO_ESQUINITA, USR_PRODUCCION_ESQUINITA;

AUDIT POLICY POL_AUDIT_LOG_FACT_PRODUCCION
BY USR_ADMIN_ESQUINITA, USR_CAJERO_ESQUINITA, USR_PRODUCCION_ESQUINITA;

AUDIT POLICY POL_AUDIT_LOG_FACT_VENTA
BY USR_ADMIN_ESQUINITA, USR_CAJERO_ESQUINITA, USR_PRODUCCION_ESQUINITA;

AUDIT POLICY POL_AUDIT_LOG_INVENTARIO
BY USR_ADMIN_ESQUINITA, USR_CAJERO_ESQUINITA, USR_PRODUCCION_ESQUINITA;

AUDIT POLICY POL_AUDIT_LOG_METODO_PAGO
BY USR_ADMIN_ESQUINITA, USR_CAJERO_ESQUINITA, USR_PRODUCCION_ESQUINITA;

AUDIT POLICY POL_AUDIT_MV_ALERTA_INVENTARIO
BY USR_ADMIN_ESQUINITA, USR_CAJERO_ESQUINITA, USR_PRODUCCION_ESQUINITA;

AUDIT POLICY POL_AUDIT_MV_VENTAS_PRODUCTO
BY USR_ADMIN_ESQUINITA, USR_CAJERO_ESQUINITA, USR_PRODUCCION_ESQUINITA;


/* ============================================================
   6. VERIFICAR TODAS LAS POLÍTICAS CREADAS
   ============================================================ */

SELECT
    POLICY_NAME,
    AUDIT_OPTION,
    AUDIT_OPTION_TYPE
FROM AUDIT_UNIFIED_POLICIES
WHERE POLICY_NAME LIKE 'POL_AUDIT_%'
ORDER BY POLICY_NAME;


/* ============================================================
   7. VERIFICAR POLÍTICAS HABILITADAS
   ============================================================ */

SELECT
    POLICY_NAME,
    ENABLED_OPTION,
    ENTITY_NAME
FROM AUDIT_UNIFIED_ENABLED_POLICIES
WHERE POLICY_NAME LIKE 'POL_AUDIT_%'
ORDER BY POLICY_NAME, ENTITY_NAME;


/* ============================================================
   8. CONSULTAR ACTIVIDADES AUDITADAS
   ============================================================ */

SELECT
    EVENT_TIMESTAMP,
    DBUSERNAME,
    ACTION_NAME,
    OBJECT_SCHEMA,
    OBJECT_NAME
FROM UNIFIED_AUDIT_TRAIL
WHERE OBJECT_SCHEMA = 'USR_ADMIN_ESQUINITA'
ORDER BY EVENT_TIMESTAMP DESC;
