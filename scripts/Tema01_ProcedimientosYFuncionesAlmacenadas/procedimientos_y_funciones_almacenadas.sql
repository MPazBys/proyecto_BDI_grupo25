USE proyecto2025;
GO

-- =============================================================================
-- 1. PROCEDIMIENTO: Insertar una nueva Persona
-- =============================================================================
CREATE PROCEDURE sp_InsertarPersona
    @dni BIGINT,
    @nombre VARCHAR(50),
    @apellido VARCHAR(50),
    @email VARCHAR(50),
    @telefono BIGINT
AS
BEGIN
    -- Encapsulamos el INSERT. Si cambia la tabla, solo tocamos aquí.
    INSERT INTO persona (dni, nombre, apellido, email, telefono)
    VALUES (@dni, @nombre, @apellido, @email, @telefono);
END
GO

-- =============================================================================
-- 2. PROCEDIMIENTO: Modificar datos de contacto
-- =============================================================================
CREATE PROCEDURE sp_ModificarPersona
    @dni BIGINT,
    @nuevo_email VARCHAR(50),
    @nuevo_telefono BIGINT
AS
BEGIN
    UPDATE persona
    SET 
        email = @nuevo_email,
        telefono = @nuevo_telefono
    WHERE 
        dni = @dni;
END
GO 

-- =============================================================================
-- 3. PROCEDIMIENTO: Borrar una persona
-- =============================================================================
CREATE PROCEDURE sp_EliminarPersona
    @dni BIGINT
AS
BEGIN
    DELETE FROM persona
    WHERE dni = @dni;
END
GO 

-- =============================================================================
-- PRUEBAS DE INSERT (Lotes A y B)
-- =============================================================================
-- LOTE A: Inserción con Sentencias INSERT Directas (Forma manual)
INSERT INTO persona (dni, nombre, apellido, email, telefono)
VALUES (11111111, 'Juan', 'Manual', 'juan.manual@mail.com', 3794111111);

INSERT INTO persona (dni, nombre, apellido, email, telefono)
VALUES (22222222, 'Maria', 'Directa', 'maria.directa@mail.com', 3794222222);

-- LOTE B: Inserción invocando PROCEDIMIENTOS ALMACENADOS (Forma profesional)
EXEC sp_InsertarPersona 
    @dni = 33333333, 
    @nombre = 'Carlos', 
    @apellido = 'Procedimiento', 
    @email = 'carlos.sp@mail.com', 
    @telefono = 3794333333;

EXEC sp_InsertarPersona 
    @dni = 44444444, 
    @nombre = 'Ana', 
    @apellido = 'Stored', 
    @email = 'ana.sp@mail.com', 
    @telefono = 3794444444;
GO 

-- =============================================================================
-- PRUEBAS DE UPDATE Y DELETE
-- =============================================================================
PRINT 'Modificando a Carlos...';
EXEC sp_ModificarPersona 
    @dni = 33333333, 
    @nuevo_email = 'carlos.nuevo@gmail.com', 
    @nuevo_telefono = 3794999999;

PRINT 'Eliminando a Juan...';
EXEC sp_EliminarPersona @dni = 11111111;
GO 

-- =============================================================================
-- FUNCIÓN 1: fn_NombreCompleto
-- =============================================================================
CREATE FUNCTION fn_NombreCompleto 
(
    @dni BIGINT 
)
RETURNS VARCHAR(150) 
AS
BEGIN
    DECLARE @Resultado VARCHAR(150);
    SELECT @Resultado = UPPER(apellido) + ', ' + nombre
    FROM persona
    WHERE dni = @dni;

    IF @Resultado IS NULL 
        SET @Resultado = 'DESCONOCIDO / NO ENCONTRADO';
    
    RETURN @Resultado;
END
GO 

-- =============================================================================
-- FUNCIÓN 2: fn_DiasParaReserva
-- =============================================================================
CREATE FUNCTION fn_DiasParaReserva 
(
    @fecha_reserva DATETIME 
)
RETURNS INT 
AS
BEGIN
    RETURN DATEDIFF(DAY, GETDATE(), @fecha_reserva);
END
GO 

-- =============================================================================
-- FUNCIÓN 3: fn_EsCapacidadSuficiente
-- =============================================================================
CREATE FUNCTION fn_EsCapacidadSuficiente 
(
    @id_mesa INT,        
    @cant_personas INT   
)
RETURNS VARCHAR(2) 
AS
BEGIN
    DECLARE @capacidad_mesa INT;
    DECLARE @respuesta VARCHAR(2);

    SELECT TOP 1 @capacidad_mesa = capacidad 
    FROM mesa 
    WHERE id_mesa = @id_mesa;

    IF @capacidad_mesa >= @cant_personas
        SET @respuesta = 'SI';
    ELSE
        SET @respuesta = 'NO'; 

    RETURN @respuesta;
END
GO 

-- =============================================================================
-- PRUEBA FINAL DE RENDIMIENTO (Base de datos con 1 Millón de filas)
-- =============================================================================
-- (Primero limpiamos los datos de prueba para que no dé error de duplicado)
DELETE FROM persona WHERE dni IN (99000001, 99000002);
GO

SET STATISTICS TIME ON; 

-- 1. MÉTODO: INSERT DIRECTO 
PRINT '>>> INICIO PRUEBA 1: INSERT DIRECTO...';
INSERT INTO persona (dni, nombre, apellido, email, telefono)
VALUES (99000001, 'Prueba', 'Directa', 'directa@test.com', 999000001);

-- 2. MÉTODO: PROCEDIMIENTO ALMACENADO 
PRINT ' ';
PRINT '>>> INICIO PRUEBA 2: STORED PROCEDURE...';
EXEC sp_InsertarPersona 
    @dni = 99000002, 
    @nombre = 'Prueba', 
    @apellido = 'StoredProc', 
    @email = 'sp@test.com', 
    @telefono = 999000002;

-- 3. MÉTODO: USO DE FUNCIÓN 
PRINT ' ';
PRINT '>>> INICIO PRUEBA 3: LECTURA CON FUNCIÓN ESCALAR...';
SELECT dbo.fn_NombreCompleto(99000002) AS Resultado_Funcion;

SET STATISTICS TIME OFF;
GO