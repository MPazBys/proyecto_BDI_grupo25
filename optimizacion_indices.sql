USE proyecto2025
SET STATISTICS TIME ON
SET STATISTICS IO ON
-----------------

--Se eliminan la clave primaria de la tabla reserva 
--y sus relaciones con otras tablas
ALTER TABLE pagos
DROP CONSTRAINT fk_pago_reserva
ALTER TABLE reserva_mesa
DROP CONSTRAINT fk_reserva
ALTER TABLE reserva
DROP CONSTRAINT PK_reserva
----------------

--Se verifica que no exista 
--algun indice en la tabla reserva
EXECUTE sp_helpindex 'reserva'
-----------------




SELECT * ----Nro de registros devueltos:530375 
FROM reserva
WHERE fecha_reserva BETWEEN '2022-03-14' AND '2024-11-07' 
---- Tiempos de Ejecucion: 
						----Primer Intento 2062ms/2,062seg
						----Segundo Intento 2051ms/2,051seg
						----Tercer Intento 2089ms/2,089sef

-----------------

SELECT * ---Nro de registros devueltos:423804
FROM reserva
WHERE fecha_reserva BETWEEN '2022-03-14' AND '2024-11-07'
AND cant_personas BETWEEN '2' AND '9'
---- Tiempos de Ejecucion: 
						----Primer Intento 1706 ms/1,706 seg
						----Segundo Intento 1715 ms/1,715 seg
						----Tercer Intento 1558 ms/1,558 seg
-----------------

SELECT * ----Nro de registros devueltos:356175
FROM reserva
WHERE fecha_reserva BETWEEN '2022-03-14' AND '2024-11-07'
AND cant_personas BETWEEN '2' AND '9'
AND dni_cliente BETWEEN '11000000' AND '15000000'
---- Tiempos de Ejecucion: 
						----Primer Intento 1435 ms/1,435 seg
						----Segundo Intento 1501 ms/1,501 seg
						----Tercer Intento 1551 ms/1,551 seg
-----------------

---Creamos un indice agrupado sobre la columna fecha_reserva
CREATE CLUSTERED INDEX IX_fecha_reserva ON reserva(fecha_reserva);
-----------------

--Se verifica que el indice esté
--creado correctamente en la tabla reserva
EXECUTE sp_helpindex 'reserva'

--Se repiten las consultas previas sobre la tabla reserva
SELECT * ----Nro de registros devueltos:530375 
FROM reserva
WHERE fecha_reserva BETWEEN '2022-03-14' AND '2024-11-07' 
---- Tiempos de Ejecucion: 
						----Primer Intento 1974 ms/1,974 seg
						----Segundo Intento 2006 ms/2,006 seg
						----Tercer Intento 2001 ms/2,001 seg

-----------------

SELECT * ---Nro de registros devueltos:423804
FROM reserva
WHERE fecha_reserva BETWEEN '2022-03-14' AND '2024-11-07'
AND cant_personas BETWEEN '2' AND '9'
---- Tiempos de Ejecucion: 
						----Primer Intento 1711 ms ms/1,711 seg
						----Segundo Intento 1669 ms/1,669 seg
						----Tercer Intento 1668 ms/1,668 seg
-----------------

SELECT * ----Nro de registros devueltos:356175
FROM reserva
WHERE fecha_reserva BETWEEN '2022-03-14' AND '2024-11-07'
AND cant_personas BETWEEN '2' AND '9'
AND dni_cliente BETWEEN '11000000' AND '15000000'
---- Tiempos de Ejecucion: 
						----Primer Intento 1420 ms./1,420 seg
						----Segundo Intento 1400 ms/1,400 seg
						----Tercer Intento 1398 ms/1,398 seg
-----------------

--Se elimina nuevamente el indice en la tabla reserva
DROP INDEX IX_fecha_reserva ON reserva;
-----------------


--Se verifica que el indice se
--haya eliminado correctamente
EXECUTE sp_helpindex 'reserva'
-----------------

---Creamos un indice agrupado sobre la columna fecha_reserva
CREATE CLUSTERED INDEX IX_fecha_reserva ON reserva(fecha_reserva, cant_personas,dni_cliente);
-----------------


--Se repiten las consultas previas sobre la tabla reserva
SELECT * ----Nro de registros devueltos:530375 
FROM reserva
WHERE fecha_reserva BETWEEN '2022-03-14' AND '2024-11-07' 
---- Tiempos de Ejecucion: 
						----Primer Intento 2009 ms/2,009 seg
						----Segundo Intento 2010 ms/2,010 seg
						----Tercer Intento 2018 ms/2,018 seg

-----------------

SELECT * ---Nro de registros devueltos:423804
FROM reserva
WHERE fecha_reserva BETWEEN '2022-03-14' AND '2024-11-07'
AND cant_personas BETWEEN '2' AND '9'
---- Tiempos de Ejecucion: 
						----Primer Intento 1634 ms/1,634 seg
						----Segundo Intento 1647 ms/1,647 seg
						----Tercer Intento 1656 ms./1,656 seg
-----------------

SELECT * ----Nro de registros devueltos:356175
FROM reserva
WHERE fecha_reserva BETWEEN '2022-03-14' AND '2024-11-07'
AND cant_personas BETWEEN '2' AND '9'
AND dni_cliente BETWEEN '11000000' AND '15000000'
---- Tiempos de Ejecucion: 
						----Primer Intento 1418 ms./1,418 seg
						----Segundo Intento 1385 ms/1,385 seg
						----Tercer Intento 1406 ms/1,406 seg
-----------------

SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;