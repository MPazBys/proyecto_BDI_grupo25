USE proyecto2025;
GO

---------------------------------------------------------------------------------------------------------------------
-- 1. Creamos una nueva tabla, tomaremos como referencia a la tabla 'reserva' para crear la tabla reserva_columnares
---------------------------------------------------------------------------------------------------------------------
CREATE TABLE reserva_columnares (
    id_reserva INT NOT NULL,
    fecha_reserva DATETIME NOT NULL,
    cant_personas INT NOT NULL,
    fecha_max_cancelacion AS DATEADD(hour, -48, fecha_reserva), --Columna calculada en base a la fecha ingresada para la reserva
    id_estado INT NOT NULL,
    id_evento INT NOT NULL,
    dni_cliente BIGINT NOT NULL,
    dni_empleado BIGINT NOT NULL,
    id_rol INT NOT NULL,
    CONSTRAINT fk_reserva_estado_c FOREIGN KEY (id_estado) REFERENCES estado_reserva(id_estado),
    CONSTRAINT fk_reserva_evento_c FOREIGN KEY (id_evento) REFERENCES evento(id_evento),
    CONSTRAINT fk_reserva_empleado_c FOREIGN KEY (dni_empleado, id_rol) REFERENCES empleado(dni_empleado, id_rol),
    CONSTRAINT chk_rol_permitido_c CHECK (id_rol = 3)
);



---------------------------------------------------------------------------------
-- 2. Carga masiva de datos (copiados de reserva)
---------------------------------------------------------------------------------

INSERT INTO reserva_columnares (id_reserva, fecha_reserva, cant_personas, id_estado, id_evento, dni_cliente, dni_empleado, id_rol)
    SELECT id_reserva, fecha_reserva, cant_personas, id_estado, id_evento, dni_cliente, dni_empleado, id_rol
    FROM reserva;

SELECT COUNT(*) AS 'Cant. Registros Reserva Columnares' FROM reserva_columnares; --verificación de que se cargaron los datos
GO



---------------------------------------------------------------------------------
-- 3. Índice columnar sobre reserva_columnares
---------------------------------------------------------------------------------

/*
Breve explicación de la siguiente instrucción:
**CREATE INDEX: es la instrucción estándar para crear un índice
**CLUSTERED: define que este índice es la estructura física principal de la tabla, pasa de una estructura
Rowstore a una estructura Columnstore
**COLUMNSTORE: especifica la tecnología de almacenamiento, guarda los registros en columnas
**CCI_reserva_columnares: CCI convención para Clustered Columnstore Index, nombre del nuevo índice

En conclusión, crea el índice primario de tabla, reorganiza y comprime los registros en columnas para la tabla reserva_columnares
*/
CREATE CLUSTERED COLUMNSTORE INDEX CCI_reserva_columnares 
ON reserva_columnares
GO



----------------------------------------------------------------------------------------
-- 4. Ejecución y evaluación de los tiempos de respuesta entre ambas tablas (PRUEBAS)
----------------------------------------------------------------------------------------

-- PRUEBA A: listar 1 los registros de reserva y reserva_columnares
--Tabla Origen (reserva) - Rowstore (PK tradicional)
SELECT TOP 1 *
FROM reserva;

--Tabla Nueva (reserva_columnares) - Columnstore (CCI)
SELECT TOP 1 *
FROM reserva_columnares;


-- PRUEBA B: Escaneo Completo y Conteo Rápido (COUNT(*))
-- Tabla Origen (reserva) - Rowstore (PK tradicional)
SELECT COUNT(*) AS TotalReservas
FROM reserva;
GO

-- Tabla Nueva (reserva_columnares) - Columnstore (CCI)
SELECT COUNT(*) AS TotalReservas
FROM reserva_columnares;
GO


-- PRUEBA C: filtrado por fecha y cantidad de personas
-- Tabla Origen (reserva) - Rowstore (PK tradicional)
SELECT dni_cliente, fecha_reserva, cant_personas
FROM reserva 
WHERE fecha_reserva BETWEEN '2025-12-01' AND '2025-12-31' AND cant_personas > 6 AND id_evento IN (1, 4) -- Cumpleaños o Cena de fin de año
ORDER BY fecha_reserva;
GO

-- Tabla Nueva (reserva_columnares) - Columnstore (CCI)
SELECT dni_cliente, fecha_reserva, cant_personas
FROM reserva_columnares
WHERE fecha_reserva BETWEEN '2025-12-01' AND '2025-12-31' AND cant_personas > 6 AND id_evento IN (1, 4) -- Cumpleaños o Cena de fin de año
ORDER BY fecha_reserva;
GO


-- PRUEBA D: Total de reservas tomadas y cantidad de personas por reservas según empleados
-- Tabla Origen (reserva) - Rowstore (PK tradicional)
SELECT dni_empleado, COUNT(id_reserva) AS 'Total de Reservas Tomadas', SUM(cant_personas) AS 'Total de Personas Atendidas'
FROM reserva
GROUP BY dni_empleado
ORDER BY 'Total de Reservas Tomadas' DESC;
GO

-- Tabla Nueva (reserva_columnares) - Columnstore (CCI)
SELECT dni_empleado, COUNT(r.id_reserva) AS 'Total de Reservas Tomadas', SUM(r.cant_personas) AS 'Total de Personas Atendidas'
FROM reserva_columnares r
GROUP BY r.dni_empleado
ORDER BY 'Total de Reservas Tomadas' DESC;
GO


-- PRUEBA E: total de persona y reservas (confirmadas y canceladas) por evento
--Tabla Origen (reserva) - Rowstore (PK tradicional)
SELECT e.nombre_evento, SUM(r.cant_personas) AS 'Total de Personas',
    COUNT(CASE WHEN r.id_estado = 1 THEN 1 END) AS 'Reservas Confirmadas',
    COUNT(CASE WHEN r.id_estado = 2 THEN 1 END) AS 'Reservas Canceladas'
FROM reserva r
INNER JOIN evento e ON r.id_evento = e.id_evento 
GROUP BY e.nombre_evento
ORDER BY 'Total de Personas' DESC;
GO

--Tabla Nueva (reserva_columnares) - Columnstore (CCI)
SELECT e.nombre_evento, SUM(r.cant_personas) AS 'Total de Personas',
    COUNT(CASE WHEN r.id_estado = 1 THEN 1 END) AS 'Reservas Confirmadas',
    COUNT(CASE WHEN r.id_estado = 2 THEN 1 END) AS 'Reservas Canceladas'
FROM reserva_columnares r
INNER JOIN evento e ON r.id_evento = e.id_evento
GROUP BY e.nombre_evento
ORDER BY 'Total de Personas' DESC;
GO


-- PRUEBA F: Reservas con más personas que el promedio
--Tabla Origen (reserva) - Rowstore (PK tradicional)
SELECT r.id_reserva, r.cant_personas, r.dni_cliente
FROM reserva r
WHERE r.cant_personas > (
    --obtiene el promedio general de personas en toda la tabla
    SELECT AVG(cant_personas)
    FROM reserva
)
ORDER BY r.cant_personas DESC
GO

--Tabla Nueva (reserva_columnares) - Columnstore (CCI)
SELECT r.id_reserva, r.cant_personas, r.dni_cliente
FROM reserva_columnares r
WHERE r.cant_personas > (
    --obtiene el promedio general de personas en toda la tabla
    SELECT AVG(cant_personas)
    FROM reserva_columnares
)
ORDER BY r.cant_personas DESC
GO
