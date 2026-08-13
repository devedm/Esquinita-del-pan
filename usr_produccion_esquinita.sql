
-- PROYECTO La Esquinita del Pan
-- Pruebas de acceso de produccion
-- Ejecutar como: usr_produccion_esquinita

-- Tablas a las que tiene acceso de lectura
SELECT * FROM DIM_PRODUCTO;
SELECT * FROM DIM_INGREDIENTE;
SELECT * FROM DIM_PROVEEDOR;
SELECT * FROM DIM_TIEMPO;

-- Tablas a las que puede insertar y modificar
SELECT * FROM FACT_PRODUCCION;
SELECT * FROM FACT_COMPRA;
SELECT * FROM FACT_DETALLE_COMPRA;
SELECT * FROM FACT_INVENTARIO_INGREDIENTE;
