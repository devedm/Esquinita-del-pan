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