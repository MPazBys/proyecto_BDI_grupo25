--CREATE DATABASE proyecto2025
--USE proyecto2025

CREATE TABLE persona
(
  dni BIGINT NOT NULL,
  nombre VARCHAR(50) NOT NULL,
  apellido VARCHAR(50) NOT NULL,
  email VARCHAR(50) NOT NULL,
  telefono BIGINT NOT NULL,
  CONSTRAINT pk_persona PRIMARY KEY (dni)
);
ALTER TABLE persona
ADD CONSTRAINT chk_persona_dni_pos CHECK (dni > 0),
    CONSTRAINT chk_persona_telefono_pos CHECK (telefono > 0),
    CONSTRAINT chk_persona_email_formato CHECK (email LIKE '%@%.%');
--ALTER TABLE persona ADD CONSTRAINT uq_persona_email UNIQUE (email);
--Importante restriccion pero en el lote de datos hay emails repetidos
--ALTER TABLE persona ADD CONSTRAINT UQ_Persona_Tel UNIQUE (telefono);
--Mismo caso para el telefono

CREATE TABLE ubicacion_mesa
(
  id_ubicacion INT IDENTITY(1,1) NOT NULL,
  ubicacion VARCHAR(30) NOT NULL,
  CONSTRAINT pk_ubicacion PRIMARY KEY (id_ubicacion)
);
ALTER TABLE ubicacion_mesa 
ADD CONSTRAINT uq_ubicacion_name UNIQUE (ubicacion);

CREATE TABLE mesa
(
  id_mesa INT NOT NULL,
  capacidad INT NOT NULL,
  id_ubicacion INT NOT NULL,
  CONSTRAINT pk_mesa PRIMARY KEY (id_mesa, id_ubicacion),
  CONSTRAINT fk_mesa_ubicacion FOREIGN KEY (id_ubicacion) REFERENCES ubicacion_mesa(id_ubicacion)
);
ALTER TABLE mesa
ADD CONSTRAINT chk_mesa_capacidad_pos CHECK (capacidad > 0);



CREATE TABLE estado_reserva
(
  id_estado INT NOT NULL,
  estado VARCHAR(30) NOT NULL,
  CONSTRAINT pk_estado PRIMARY KEY (id_estado)
);
ALTER TABLE estado_reserva
ADD CONSTRAINT chk_estado_id_pos CHECK (id_estado > 0);
ALTER TABLE estado_reserva
ADD CONSTRAINT uq_estado_name UNIQUE (estado);

CREATE TABLE evento
(
  id_evento INT NOT NULL,
  nombre_evento VARCHAR(30) NOT NULL,
  CONSTRAINT pk_evento PRIMARY KEY (id_evento)
);
ALTER TABLE evento
ADD CONSTRAINT chk_evento_id_pos CHECK (id_evento > 0);
ALTER TABLE evento 
ADD CONSTRAINT uq_evento_name UNIQUE (nombre_evento);


CREATE TABLE cliente
(
  dni_cliente BIGINT NOT NULL,
  CONSTRAINT pk_cliente PRIMARY KEY (dni_cliente),
  CONSTRAINT fk_cliente_persona FOREIGN KEY (dni_cliente) REFERENCES persona(dni)
);


CREATE TABLE rol_empleado
(
  id_rol INT NOT NULL,
  descripcion VARCHAR(30) NOT NULL,
  CONSTRAINT pk_rolempleado PRIMARY KEY (id_rol)
);
ALTER TABLE rol_empleado
ADD CONSTRAINT chk_rol_id_pos CHECK (id_rol > 0);
ALTER TABLE rol_empleado 
ADD CONSTRAINT uq_rol UNIQUE (descripcion);


CREATE TABLE turno_empleado
(
  id_turno INT IDENTITY(1,1) NOT NULL ,
  inicio_turno TIME NOT NULL,
  fin_turno TIME NOT NULL,
  CONSTRAINT pk_turno PRIMARY KEY (id_turno)
);
ALTER TABLE turno_empleado
ADD CONSTRAINT chk_turno_valido CHECK (fin_turno > inicio_turno OR inicio_turno > fin_turno);


CREATE TABLE empleado
(
  dni_empleado BIGINT NOT NULL,
  id_rol INT NOT NULL,
  id_turno INT NOT NULL,
  CONSTRAINT pk_empleado PRIMARY KEY (dni_empleado, id_rol),
  CONSTRAINT fk_persona_empleado FOREIGN KEY (dni_empleado) REFERENCES persona(dni),
  CONSTRAINT fk_rol_empleado FOREIGN KEY (id_rol) REFERENCES rol_empleado(id_rol),
  CONSTRAINT fk_turno_empleado FOREIGN KEY (id_turno) REFERENCES turno_empleado(id_turno)
);
-- Asigna a cada empleado 1 si esta usando ese rol y 0 si ya no lo usa
ALTER TABLE empleado
ADD activo_en_rol BIT NOT NULL DEFAULT 1;
-- Restriccion unica condicional
-- Esto asegura que no pueda haber dos filas con el mismo DNI y activo_en_rol = 1
CREATE UNIQUE NONCLUSTERED INDEX UQ_Empleado_RolActivo
ON empleado (dni_empleado)
WHERE (activo_en_rol = 1);

CREATE TABLE reserva
(
  id_reserva INT IDENTITY(1,1) NOT NULL,
  fecha_reserva DATETIME NOT NULL,
  cant_personas INT NOT NULL,
  fecha_max_cancelacion AS DATEADD(hour, -48, fecha_reserva), --Columna calculada en base a la fecha ingresada para la reserva
  id_estado INT NOT NULL,
  id_evento INT NOT NULL,
  dni_cliente BIGINT NOT NULL,
  dni_empleado BIGINT NOT NULL,
  id_rol INT NOT NULL,
  CONSTRAINT pk_reserva PRIMARY KEY (id_reserva),
  CONSTRAINT fk_reserva_estado FOREIGN KEY (id_estado) REFERENCES estado_reserva(id_estado),
  CONSTRAINT fk_reserva_evento FOREIGN KEY (id_evento) REFERENCES evento(id_evento),
  CONSTRAINT fk_reserva_cliente FOREIGN KEY (dni_cliente) REFERENCES cliente(dni_cliente),
  CONSTRAINT fk_reserva_empleado FOREIGN KEY (dni_empleado, id_rol) REFERENCES empleado(dni_empleado, id_rol),
);
ALTER TABLE reserva
ADD CONSTRAINT chk_rol_permitido
CHECK (id_rol = 3);
ALTER TABLE reserva
ADD CONSTRAINT chk_reserva_cant CHECK (cant_personas > 0),
    CONSTRAINT chk_reserva_fecha_futura CHECK (fecha_reserva >= GETDATE());
  


CREATE TABLE reserva_mesa
(
  id_reserva INT NOT NULL,
  id_mesa INT NOT NULL,
  id_ubicacion INT NOT NULL,
  CONSTRAINT pk_reserva_mesa PRIMARY KEY (id_reserva, id_mesa, id_ubicacion),
  CONSTRAINT fk_reserva FOREIGN KEY (id_reserva) REFERENCES reserva(id_reserva) ON DELETE CASCADE,
  CONSTRAINT fk_mesa FOREIGN KEY (id_mesa, id_ubicacion) REFERENCES mesa(id_mesa, id_ubicacion)
);
ALTER TABLE reserva_mesa
ADD CONSTRAINT uq_reservaMesa_asignacion UNIQUE (id_reserva, id_mesa,id_ubicacion);

CREATE TABLE metodo_pago
(
  id_metodo INT NOT NULL,
  forma_pago VARCHAR(30) NOT NULL,
  CONSTRAINT pk_metodo_pago PRIMARY KEY (id_metodo)
);
ALTER TABLE metodo_pago
ADD CONSTRAINT chk_metodo_id_pos CHECK (id_metodo > 0);
ALTER TABLE metodo_pago
ADD CONSTRAINT uq_metodo_name UNIQUE (forma_pago);

CREATE TABLE pagos
(
  id_pago INT IDENTITY(1,1) NOT NULL,
  monto FLOAT NOT NULL,
  fecha_pago DATE NOT NULL,
  id_metodo INT NOT NULL,
  id_reserva INT NOT NULL,
  CONSTRAINT pk_pagos PRIMARY KEY (id_pago, id_reserva),
  CONSTRAINT fk_pago_metodo FOREIGN KEY (id_metodo) REFERENCES metodo_pago(id_metodo),
  CONSTRAINT fk_pago_reserva FOREIGN KEY (id_reserva) REFERENCES reserva(id_reserva) ON DELETE CASCADE  
);
ALTER TABLE pagos
ADD CONSTRAINT UQ_Pago_Reserva UNIQUE (id_reserva);
ALTER TABLE pagos
ADD CONSTRAINT chk_pagos_monto CHECK (monto > 0),
    CONSTRAINT chk_pagos_fecha_actual CHECK (fecha_pago <= GETDATE());

-- =================================================================================






    




 


