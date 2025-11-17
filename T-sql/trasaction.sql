--====================================================
-- TRANSACCIONES DEL PROYECTO RESTARURANT 2025
--====================================================


--==============================================================
--TRANSANCCION CREACION DE RESERVA//Inserta en tabla reserva y reserva_mesa
--==============================================================
-- DECLARACION DE PARAMETROS

-- Datos Reserva Principal
DECLARE @fecha_reserva_nueva DATETIME = '2026-10-14 20:00:00';
DECLARE @cant_personas INT = 8;
DECLARE @id_estado_reserva INT = 1; -- Default 1 
-- 1=Confirmado,2=Cancelado,3=Pagado
DECLARE @id_evento INT = 1;
-- 1=cumple,2=Despedida,3=EventoPrivado,...,6=Cena normal
DECLARE @dni_cliente_nuevo BIGINT = 15676587; 	-- Dni Cliente
DECLARE @dni_empleado_asigna BIGINT = 11508431; -- Dni Empleado
DECLARE @id_rol_empleado INT = 3;  --Default 3 porque solo un mozo puede registrar una reserva
--1=Cocinero,2=Bachero,3=Mozo,4=Bartender....
-- Datos Asignacion de Mesa
DECLARE @id_mesa_asignada INT = 1;
-- (1-4 Terraza,5-7 2doPiso,8-10=PB,11-12=Patio)
DECLARE @id_ubicacion_mesa INT = 1;
-- 1=Terraza,2=2doPiso,3=PlantaBaja,4=Patio

-- VALIDACION DE DUPLICIDAD RESERVA
IF EXISTS (
    SELECT 1 
    FROM reserva
    -- Criterio de unicidad: Mismo cliente Y misma fecha/hora
    WHERE dni_cliente = @dni_cliente_nuevo
      AND fecha_reserva = @fecha_reserva_nueva
)
BEGIN
    -- Si existe, se emite un error y se detiene el proceso
   RAISERROR('ERROR: El cliente ya tiene una reserva  para esta fecha y hora.', 16, 1);
    RETURN; 
END
-- VALIDACION DE HORARIO DE NEGOCIO
DECLARE @hora_reserva TIME = CAST(@fecha_reserva_nueva AS TIME);
DECLARE @hora_apertura TIME = '18:00:00';
DECLARE @hora_cierre TIME = '00:00:00';
IF NOT (@hora_reserva >= @hora_apertura AND @hora_reserva > '00:00:00')
BEGIN
    IF (@hora_reserva < @hora_apertura OR @hora_reserva > @hora_cierre)
    BEGIN
        RAISERROR('ERROR: La hora de reserva debe estar entre las 18:00 y las 00:00.', 16, 1);
        RETURN;
    END
END
-- VALIDACION DE ROL CORRECTO DEL EMPLEADO
IF NOT EXISTS(
	SELECT 1
	FROM empleado
	WHERE dni_empleado = @dni_empleado_asigna
		AND id_rol = @id_rol_empleado)
		BEGIN
    RAISERROR('ERROR: El empleado asignado no tiene el ID de rol especificado o no existe.', 16, 1);
    RETURN;
END
-- VALIDACION DE EXISTENCIA DE CLIENTE
IF NOT EXISTS(SELECT 1 FROM cliente WHERE dni_cliente = @dni_cliente_nuevo)
BEGIN
    RAISERROR('ERROR: El DNI del cliente (%I64d) no existe en el sistema.', 16, 1, @dni_cliente_nuevo);
    RETURN;
END
-- VALIDACION DE EXISTENCIA DE ESTADO DE RESERVA
IF NOT EXISTS(SELECT 1 FROM estado_reserva WHERE id_estado = @id_estado_reserva)
BEGIN
    RAISERROR('ERROR: El ID de estado de reserva (%d) no es válido.', 16, 1, @id_estado_reserva);
    RETURN;
END
-- VALIDACION DE EXISTENCIA DE EVENTO
IF NOT EXISTS(SELECT 1 FROM evento WHERE id_evento = @id_evento)
BEGIN
    RAISERROR('ERROR: El ID de evento (%d) no es válido.', 16, 1, @id_evento);
    RETURN;
END
-- VALIDACION DE EXISTENCIA DE MESA
IF NOT EXISTS(SELECT 1 FROM mesa WHERE id_mesa = @id_mesa_asignada)
BEGIN
    RAISERROR('ERROR: El ID de mesa (%d) no existe.', 16, 1, @id_mesa_asignada);
    RETURN;
END
--VALIDACION DE MESA CORRECTA 
IF NOT (@id_mesa_asignada BETWEEN 1 AND 4 AND @id_ubicacion_mesa = 1) 
   AND NOT (@id_mesa_asignada BETWEEN 5 AND 7 AND @id_ubicacion_mesa = 2)
   AND NOT (@id_mesa_asignada BETWEEN 8 AND 10 AND @id_ubicacion_mesa = 3)
   AND NOT (@id_mesa_asignada BETWEEN 11 AND 12 AND @id_ubicacion_mesa = 4)
BEGIN
    RAISERROR('ERROR: El número de mesa asignado no corresponde a la ubicación especificada.', 16, 1);
    RETURN;
END
-- VALIDACION DE MESA DISPONIBLE
IF EXISTS (
    SELECT 1
    FROM reserva_mesa rm
    INNER JOIN reserva r ON rm.id_reserva = r.id_reserva
    -- La mesa debe estar libre en la fecha y hora de la nueva reserva
    WHERE rm.id_mesa = @id_mesa_asignada
      AND r.fecha_reserva = @fecha_reserva_nueva 
      -- Verifica si la reserva existente NO está 'Cancelada'
      AND r.id_estado NOT IN (SELECT id_estado FROM estado_reserva WHERE estado = 'Cancelado') 
)
BEGIN
    RAISERROR('ERROR: La mesa %d ya está reservada para la fecha y hora especificada.', 16, 1, @id_mesa_asignada);
    RETURN;
END
-- VALIDACION DE CAPACIDAD DE MESA
DECLARE @capacidad_mesa INT;
SELECT @capacidad_mesa = capacidad 
FROM mesa 
WHERE id_mesa = @id_mesa_asignada;
IF @cant_personas > @capacidad_mesa
BEGIN
    RAISERROR('ERROR: La cantidad de personas (%d) excede la capacidad máxima de la mesa %d (%d).', 16, 1, @cant_personas, @id_mesa_asignada, @capacidad_mesa);
    RETURN;
END
-- TRANSACCION DE INSERCION (solo si no hay duplicados)
BEGIN TRY
	BEGIN TRANSACTION; 
	-- Insertar la reserva nueva
	INSERT INTO reserva (fecha_reserva, cant_personas, id_estado, id_evento, dni_cliente, dni_empleado, id_rol)
    VALUES (@fecha_reserva_nueva, @cant_personas, @id_estado_reserva, @id_evento, @dni_cliente_nuevo, @dni_empleado_asigna, @id_rol_empleado);
	-- Obtiene el ID de la reserva recien creada
	DECLARE @id_reserva INT = SCOPE_IDENTITY();   
	-- Asignar la mesa
	INSERT INTO reserva_mesa (id_reserva, id_mesa, id_ubicacion)
    VALUES (@id_reserva, @id_mesa_asignada, @id_ubicacion_mesa);
	-- Si todo salio bien, confirma
	COMMIT TRANSACTION;
	SELECT 'Nueva reserva creada con éxito, ID: ' + CAST(@id_reserva AS VARCHAR);
END TRY
BEGIN CATCH
    -- Manejo de error y rollback
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
END CATCH




--=================================================
--TRANSACCION REGISTRO DE PAGO DE MESA//Inserta en tabla pago y actualiza estado a 'Pagado'
--=================================================
-- DECLARACION DE PARAMETROS 
DECLARE @id_reserva_pago INT =4 ;--ID de la mesa reservada en reserva_mesa
DECLARE @monto_pago DECIMAL(10, 2) = 60000.00;
DECLARE @id_metodo_pago INT = 2;--1=Credito, 2=Debito, 3=Efectivo
DECLARE @id_estado_pagado INT;

	-- Obtiene el ID de estado 'Pagado'
	SELECT @id_estado_pagado = id_estado FROM estado_reserva WHERE estado = 'Pagado';
	-- VALIDACION DE EXISTENCIA DE ESTADO 'PAGADO'
	IF @id_estado_pagado IS NULL
	BEGIN
	    RAISERROR('ERROR: No se encontro el estado "Pagado" en la tabla estado_reserva.', 16, 1);
	    RETURN;
	END
	-- VALIDACION DE EXISTENCIA DE LA RESERVA
	IF NOT EXISTS (SELECT 1 FROM reserva WHERE id_reserva = @id_reserva_pago)
	BEGIN
	    RAISERROR('ERROR: La reserva %d no existe.', 16, 1, @id_reserva_pago);
	    RETURN;
	END
	-- VALIDACION DE EXISTENCIA DEL MÉTODO DE PAGO
	IF NOT EXISTS (SELECT 1 FROM metodo_pago WHERE id_metodo = @id_metodo_pago)
	BEGIN
	     RAISERROR('ERROR: El metodo de pago %d no es válido.', 16, 1, @id_metodo_pago);
	     RETURN;
	END
	-- VALIDACION DE UNICIDAD (Evita pagos duplicados)
	IF EXISTS (SELECT 1 FROM pagos WHERE id_reserva = @id_reserva_pago)
	BEGIN
	     RAISERROR('ERROR: La reserva %d ya tiene un pago registrado.', 16, 1, @id_reserva_pago);
	     RETURN;
	END
	-- VALIDACION DEL ESTADO ACTUAL (Evita pagar algo ya cancelado)
	SELECT @estado_actual_reserva = id_estado FROM reserva WHERE id_reserva = @id_reserva_pago;
	IF (SELECT estado FROM estado_reserva WHERE id_estado = @estado_actual_reserva) = 'Cancelado'
	BEGIN
	     RAISERROR('ERROR: No se puede pagar una reserva que ha sido cancelada.', 16, 1);
	     RETURN;
	END
	
BEGIN TRY
    BEGIN TRANSACTION;
    -- Inserta el pago
    INSERT INTO pagos (id_reserva, monto, fecha_pago, id_metodo)
    VALUES (@id_reserva_pago, @monto_pago, GETDATE(), @id_metodo_pago);
    -- Actualiza el estado de la reserva
    UPDATE reserva
    SET id_estado = @id_estado_pagado 
    WHERE id_reserva = @id_reserva_pago;
    -- Si todo fue exitoso, confirma
    COMMIT TRANSACTION;
    SELECT 'Pago registrado y estado de reserva actualizado con éxito.' AS Resultado;
END TRY
BEGIN CATCH
    -- Si ocurre cualquier error, entra al bloque CATCH
    IF @@TRANCOUNT > 0
    BEGIN
        -- Deshacer todos los cambios realizados desde el BEGIN TRANSACTION
        ROLLBACK TRANSACTION; 
    END
END CATCH






-- ================================================
-- TRANSACCION CANCELACION DE RESERVA// Actualiza estado de reserva a 'Cancelado'
-- ================================================
-- DECLARACION DE PARAMETROS 
DECLARE @id_reserva_a_cancelar INT =1001466;
DECLARE @id_estado_cancelado INT;
DECLARE @estado_actual VARCHAR(30);

	-- Obtener el ID del estado 'Cancelado'
    SELECT @id_estado_cancelado = id_estado
    FROM estado_reserva
    WHERE estado = 'Cancelado';
    -- VALIDACION DE EXISTENCIA DE ESTADO 'CANCELADO'
    IF @id_estado_cancelado IS NULL
    BEGIN
        RAISERROR('ERROR: No se encontro el estado "Cancelado" en la tabla estado_reserva.', 16, 1);
        RETURN;
    END
    -- VALIDACION DE EXISTENCIA DE LA RESERVA
    IF NOT EXISTS (SELECT 1 FROM reserva WHERE id_reserva = @id_reserva_a_cancelar)
    BEGIN
        RAISERROR('ERROR: La reserva %d no existe.', 16, 1, @id_reserva_a_cancelar);
        RETURN;
    END
    -- VALIDACION DEL ESTADO ACTUAL (Evita cancelar dos veces o estados finales)
    SELECT @estado_actual = E.estado
    FROM reserva R
    JOIN estado_reserva E ON R.id_estado = E.id_estado
    WHERE R.id_reserva = @id_reserva_a_cancelar;

    IF @estado_actual = 'Cancelado'
    BEGIN
        RAISERROR('ERROR: La reserva %d ya se encuentra en estado Cancelado.', 16, 1, @id_reserva_a_cancelar);
        RETURN;
    END
    		
BEGIN TRY
        BEGIN TRANSACTION;
       -- Actualiza el estado de la reserva a "Cancelado"
        UPDATE reserva
        SET id_estado = @id_estado_cancelado
        WHERE id_reserva = @id_reserva_a_cancelar;
        --Elimina las asignaciones de mesas
        DELETE FROM reserva_mesa
        WHERE id_reserva = @id_reserva_a_cancelar;
        COMMIT TRANSACTION;
        SELECT 'Reserva ' + CAST(@id_reserva_a_cancelar AS VARCHAR) + ' cancelada y mesas liberadas exitosamente.' AS Resultado;
END TRY
BEGIN CATCH
        -- Manejo de errores avanzado con THROW
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END
END CATCH







-- =================================================
-- TRANSACCION ASIGNACION/CAMBIO DE ROL DEL EMPLEADO// Gestiona activo_en_rol y la PK compuesta
-- =================================================
-- DECLARACION DE PARAMETROS
DECLARE @dni_empleado_a_actualizar BIGINT = 10370554;
DECLARE @nuevo_id_rol INT = 3;
DECLARE @nuevo_id_turno INT = 1;

-- DECLARACION PARA VALIDACIONES INTERNAS
DECLARE @dni_persona BIGINT;
DECLARE @id_rol_valido INT;
DECLARE @id_turno_valido INT;
DECLARE @rol_activo_coincide INT;
DECLARE @filas_actualizadas INT;

-- Obtener el DNI de la persona/empleado
SELECT @dni_persona = dni FROM persona WHERE dni = @dni_empleado_a_actualizar;
-- VALIDACION DE EXISTENCIA DE EMPLEADO
IF @dni_persona IS NULL
BEGIN
    RAISERROR('ERROR: El DNI de empleado %I64d no existe en la tabla persona.', 16, 1, @dni_empleado_a_actualizar);
    RETURN;
END
-- Obtener el ID del Rol
SELECT @id_rol_valido = id_rol FROM rol_empleado WHERE id_rol = @nuevo_id_rol;
-- VALIDACION DE EXISTENCIA DE ROL
IF @id_rol_valido IS NULL
BEGIN
    RAISERROR('ERROR: El ID de rol %d no es valido.', 16, 1, @nuevo_id_rol);
    RETURN;
END
-- Obtener el ID del Turno
SELECT @id_turno_valido = id_turno FROM turno_empleado WHERE id_turno = @nuevo_id_turno;
-- VALIDACION DE EXISTENCIA DE TURNO
IF @id_turno_valido IS NULL
BEGIN
    RAISERROR('ERROR: El ID de turno %d no es valido.', 16, 1, @nuevo_id_turno);
    RETURN;
END
-- VALIDACION DE ROL DUPLICADO/YA ACTIVO(verifica si ya tiene el rol y turno activos)
SELECT @rol_activo_coincide = 1
FROM empleado
WHERE dni_empleado = @dni_empleado_a_actualizar
  AND id_rol = @nuevo_id_rol
  AND id_turno = @nuevo_id_turno
  AND activo_en_rol = 1;
  
IF @rol_activo_coincide IS NOT NULL
BEGIN
    RAISERROR('AVISO: El empleado ya tiene asignado y activo este rol con el mismo turno. No se realizaron cambios.', 10, 1);
    RETURN;
END

-- =================================================
-- LOGICA TRANSACCIONAL
-- =================================================
BEGIN TRY
    BEGIN TRANSACTION;

    -- Desactiva el rol activo actual 
    UPDATE empleado
    SET activo_en_rol = 0
    WHERE dni_empleado = @dni_empleado_a_actualizar
      AND activo_en_rol = 1;
      
    -- Intentar actualizar el registro con el nuevo rol (si ya existe pero estaba inactivo o con otro turno)
    UPDATE empleado
    SET
        id_turno = @nuevo_id_turno,
        activo_en_rol = 1 -- Marcar como activo
    WHERE dni_empleado = @dni_empleado_a_actualizar
      AND id_rol = @nuevo_id_rol;
      
    SELECT @filas_actualizadas = @@ROWCOUNT;
    
    -- Si no se actualizo ninguna fila (es un rol totalmente nuevo para el empleado),INSERTAR
    IF @filas_actualizadas = 0
    BEGIN
        INSERT INTO empleado (dni_empleado, id_rol, id_turno, activo_en_rol)
        VALUES (@dni_empleado_a_actualizar, @nuevo_id_rol, @nuevo_id_turno, 1);
    END
    
    -- Confirmar los cambios
    COMMIT TRANSACTION;
    
    SELECT 'Asignacion de rol y turno principal actualizada con exito para el empleado ' + CAST(@dni_empleado_a_actualizar AS VARCHAR) AS Resultado;
END TRY
BEGIN CATCH
    -- Si ocurre cualquier error, deshacer la transaccion
    IF @@TRANCOUNT > 0
    BEGIN
        ROLLBACK TRANSACTION;
    END
END CATCH

