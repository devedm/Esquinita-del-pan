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