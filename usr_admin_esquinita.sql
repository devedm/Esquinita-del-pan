
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
