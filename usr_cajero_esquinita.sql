
-- PROYECTO La Esquinita del Pan
-- Pruebas de acceso del cajero
-- Ejecutar como: usr_cajero_esquinita


-- Tablas a las que tiene acceso de lectura
SELECT * FROM DIM_PRODUCTO;
SELECT * FROM DIM_CATEGORIA_PRODUCTO;
SELECT * FROM DIM_TIEMPO;
SELECT * FROM DIM_CLIENTE;

-- Tablas a las que puede insertar y modificar
SELECT * FROM FACT_VENTA;
SELECT * FROM FACT_DETALLE_VENTA;
