--====================================================
-- TRANSACCIONES DEL PROYECTO RESTARURANT 2025
--====================================================


--==============================================================
--TRANSANCCION CREACION DE RESERVA//Inserta en tabla reserva y reserva_mesa
--==============================================================
-- DECLARACION DE PARAMETROS
-- Datos Reserva Principal
DECLARE @fecha_reserva_nueva DATETIME = '2026-10-10 18:00:00';
DECLARE @cant_personas INT = 4;
DECLARE @id_estado_reserva INT = 1; -- 1=Confirmado,2=Cancelado,3=Pagado
DECLARE @id_evento INT = 1; -- 1=cumple,2=Despedida,3=EventoPrivado,...,6=Cena normal
DECLARE @dni_cliente_nuevo BIGINT = 15676587; 	-- Dni Cliente
DECLARE @dni_empleado_asigna BIGINT = 11508431; -- Dni Empleado
DECLARE @id_rol_empleado INT = 3; --1=Cocinero,2=Bachero,3=Mozo,4=Bartender....
-- Datos Asignacion de Mesa
DECLARE @id_mesa_asignada INT = 1;-- Nro de mesa de asignado a la reserva
-- (1-4 Terraza,5-7 2doPiso,8-10=PB,11-12=Patio)
DECLARE @id_ubicacion_mesa INT = 1;-- 1=Terraza,2=2doPiso,3=PlantaBaja,4=Patio
-- VERIFICACION DE DUPLICIDAD RESERVA
IF EXISTS (
    SELECT 1 
    FROM reserva
    -- Criterio de unicidad: Mismo cliente Y misma fecha/hora
    WHERE dni_cliente = @dni_cliente_nuevo
      AND fecha_reserva = @fecha_reserva_nueva
)
BEGIN
    -- Si existe, se emite un error/advertencia y se detiene el proceso
   RAISERROR('ERROR: El cliente ya tiene una reserva  para esta fecha y hora.', 16, 1);
    RETURN; 
END
--VERIFICACION DE ROL CORRECTO DEL EMPLEADO
IF NOT EXISTS(
	SELECT 1
	FROM empleado
	WHERE dni_empleado = @dni_empleado_asigna
		AND id_rol = @id_rol_empleado)
		BEGIN
    RAISERROR('ERROR: El empleado asignado no tiene el ID de rol especificado o no existe.', 16, 1);
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
	-- Asignar la(s) mesa(s)
	--(En teoria se podria asignar mas de 1 mesa a una reserva)
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
--TRANSACCION REGISTRO DE PAGO DE MESA//Inserta en tabla pago 
--=================================================
-- DECLARACION DE PARAMETROS 
DECLARE @id_reserva_pago INT =4 ;--ID de la mesa reservada en reserva_mesa
DECLARE @monto_pago DECIMAL(10, 2) = 60000.00;
DECLARE @id_metodo_pago INT = 2;--1=Credito, 2=Debito, 3=Efectivo
DECLARE @id_estado_pagado INT;
-- Obtener el ID de estado 'Pagado' de forma segura
SELECT @id_estado_pagado = id_estado FROM estado_reserva WHERE estado = 'Pagado';
-- VERIFICACION DE UNICIDAD (Evita pagos duplicados)
IF EXISTS (SELECT 1 FROM pagos WHERE id_reserva = @id_reserva_pago)
BEGIN
    RAISERROR('ERROR: La reserva %d ya tiene un pago registrado.', 16, 1, @id_reserva_pago);
    RETURN; -- Detiene la ejecucion si el pago ya existe
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
-- CANCELACION DE RESERVA//TRANSACCION APLICADA
-- ================================================
-- DECLARACION DE PARAMETROS 
DECLARE @id_reserva_a_cancelar INT =5;
DECLARE @id_estado_cancelado INT;
-- Obtener el ID del estado 'Cancelada' de forma segura (para evitar errores si el nombre cambia)
SELECT @id_estado_cancelado = id_estado 
FROM estado_reserva 
WHERE estado = 'Cancelado';
BEGIN TRY
  BEGIN TRANSACTION;
    --Actualiza el estado de la reserva a "Cancelado"
    UPDATE reserva
    SET id_estado = @id_estado_cancelado
    WHERE id_reserva = @id_reserva_a_cancelar;

    -- Elimina las asignaciones de mesas
    -- Esto libera las mesas para otras reservas
    DELETE FROM reserva_mesa
    WHERE id_reserva = @id_reserva_a_cancelar;

  COMMIT TRANSACTION;
  SELECT 'Reserva ' + CAST(@id_reserva_a_cancelar AS VARCHAR) + ' cancelada y mesas liberadas exitosamente.' AS Resultado;

END TRY
BEGIN CATCH
  -- Si algo falla, revertir todos los cambios
  IF @@TRANCOUNT > 0
    ROLLBACK TRANSACTION;
END CATCH







-- ================================================
-- ASIGNACION/CAMBIO DE ROL DEL EMPLEADO//TRANSACCION APLICADA
-- ================================================
-- DECLARACION DE PARAMETROS
DECLARE @dni_empleado_a_actualizar INT = 10506289; 
DECLARE @nuevo_id_rol INT = 3; --1=Cocinero,2=Bachero,3=Mozo,4=Bartender....
DECLARE @nuevo_id_turno INT = 2; --1=19PM-02AM,2=16PM-01AM,3=17PM-1AM,.....
BEGIN TRY
    BEGIN TRANSACTION;
        -- Cambia el turno y el rol de un empleado 
        UPDATE empleado
        SET 
            id_rol = @nuevo_id_rol,
            id_turno = @nuevo_id_turno
        WHERE dni_empleado = @dni_empleado_a_actualizar;
    -- Si el UPDATE fue exitoso, confirmar los cambios
    COMMIT TRANSACTION;
  
    SELECT 'Asignación de rol y turno actualizada con éxito para el empleado ' + @dni_empleado_a_actualizar AS Resultado;
END TRY
BEGIN CATCH
    -- Si ocurre cualquier error, entra al bloque CATCH
    -- Verifica si existe una transaccion activa
    IF @@TRANCOUNT > 0
    BEGIN
        -- Deshace todos los cambios realizados desde el BEGIN TRANSACTION
        ROLLBACK TRANSACTION; 
    END
END CATCH
