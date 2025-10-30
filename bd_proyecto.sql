CREATE DATABASE proyecto2025
USE proyecto2025
CREATE TABLE cliente
(
  dni INT NOT NULL,
  nombre VARCHAR(50) NOT NULL,
  apellido VARCHAR(50) NOT NULL,
  email VARCHAR(50) NOT NULL,
  CONSTRAINT pk_cliente PRIMARY KEY (DNI)
);

CREATE TABLE ubicacion_mesa
(
  id_ubicacion INT NOT NULL,
  ubicacion VARCHAR(30) NOT NULL,
  CONSTRAINT pk_ubicacion PRIMARY KEY (id_ubicacion)
);

CREATE TABLE mesa
(
  id_mesa INT NOT NULL,
  nro_mesa INT NOT NULL,
  capacidad INT NOT NULL,
  id_ubicacion INT NOT NULL,
  CONSTRAINT pk_mesa PRIMARY KEY (id_mesa),
  CONSTRAINT fk_mesa_ubicacion FOREIGN KEY (id_ubicacion) REFERENCES Ubicacion_Mesa(id_ubicacion)
);

CREATE TABLE estado_reserva
(
  id_estado INT NOT NULL,
  estado VARCHAR(30) NOT NULL,
  CONSTRAINT pk_estado PRIMARY KEY (id_estado)
);

CREATE TABLE rol_empleado
(
  id_rol INT NOT NULL,
  nombre_rol VARCHAR(50) NOT NULL,
  CONSTRAINT pk_rolempleado PRIMARY KEY (id_rol)
);

CREATE TABLE empleado
(
  dni_empleado INT NOT NULL,
  nombre VARCHAR(50) NOT NULL,
  id_rol INT NOT NULL,
  CONSTRAINT pk_empleado PRIMARY KEY (dni_empleado),
  CONSTRAINT fk_empleado_rol FOREIGN KEY (id_rol) REFERENCES rol_empleado(id_rol)
);

CREATE TABLE turno_empleado
(
  id_turno INT  NOT NULL,
  fecha_turno DATE NOT NULL,
  inicio_turno DATE NOT NULL,
  fin_turno DATE NOT NULL,
  dni_empleado INT NOT NULL,
  CONSTRAINT pk_turno PRIMARY KEY (id_turno, dni_empleado),
  CONSTRAINT fk_turno_empleado FOREIGN KEY (dni_empleado) REFERENCES empleado(dni_empleado)
);

CREATE TABLE reserva
(
  id_reserva INT NOT NULL,
  fecha_reserva DATE NOT NULL,
  hora_reserva DATE NOT NULL,
  cant_persona INT NOT NULL,
  dni INT NOT NULL,
  id_estado INT NOT NULL,
  id_turno INT NOT NULL,
  dni_empleado INT NOT NULL,
  CONSTRAINT pk_reserva PRIMARY KEY (id_reserva),
  CONSTRAINT fk_reserva_cliente FOREIGN KEY (dni) REFERENCES cliente(dni),
  CONSTRAINT fk_reserva_estado FOREIGN KEY (ID_estado) REFERENCES estado_reserva(id_estado),
  CONSTRAINT fk_turno_reserva FOREIGN KEY (id_turno, dni_empleado) REFERENCES turno_empleado(id_turno, dni_empleado)
);

CREATE TABLE disponibilidad_reserva
(
  inicio_dispo DATE NOT NULL,
  fin_dispo DATE NOT NULL,
  fecha_dispo DATE NOT NULL,
  id_mesa INT NOT NULL,
  id_reserva INT NOT NULL,
  CONSTRAINT pk_disponibilidad_reserva PRIMARY KEY (id_mesa, id_reserva),
  CONSTRAINT fk_disreserva_mesa FOREIGN KEY (id_mesa) REFERENCES mesa(id_mesa),
  CONSTRAINT fk_disreserva_reserva FOREIGN KEY (id_reserva) REFERENCES reserva(id_reserva)
);

CREATE TABLE metodo_pago
(
  id_metodo INT NOT NULL,
  formaPago VARCHAR(30) NOT NULL,
  CONSTRAINT pk_metodo_pago PRIMARY KEY (ID_metodo)
);

CREATE TABLE pagos
(
  id_pago INT NOT NULL,
  monto INT NOT NULL,
  fecha_pago DATE NOT NULL,
  id_metodo INT NOT NULL,
  id_reserva INT NOT NULL,
  CONSTRAINT pk_pagos PRIMARY KEY (id_pago, id_reserva),
  CONSTRAINT fk_pago_metodo FOREIGN KEY (id_metodo) REFERENCES metodo_pago(id_metodo),
  CONSTRAINT fk_pago_reserva FOREIGN KEY (id_reserva) REFERENCES reserva(id_reserva)
);

CREATE TABLE evento_especial
(
  id_evento INT NOT NULL,
  nombre_evento VARCHAR(30) NOT NULL,
  descripcion VARCHAR(100) NOT NULL,
  CONSTRAINT pk_evento PRIMARY KEY (id_evento)
);

CREATE TABLE reserva_evento
(
  id_reserva_evento INT NOT NULL,
  id_evento INT NOT NULL,
  id_reserva INT NOT NULL,
  CONSTRAINT pk_reser_event PRIMARY KEY (id_reserva_evento, id_evento, id_reserva),
  CONSTRAINT fk_reserva_evento FOREIGN KEY (id_evento) REFERENCES evento_especial(id_evento),
  CONSTRAINT fk_reservaevento_reserva FOREIGN KEY (id_reserva) REFERENCES reserva(id_reserva)
);

CREATE TABLE horario_cancelacion
(
  id_cancelacion INT NOT NULL,
  motivo VARCHAR(50),
  fecha_cancelacion DATE,
  id_reserva INT NOT NULL,
  CONSTRAINT pk_cancelacion PRIMARY KEY (id_cancelacion, id_reserva),
  CONSTRAINT fk_cancelacion_reserva FOREIGN KEY (id_reserva) REFERENCES reserva(id_reserva)
);

CREATE TABLE telefono_cliente
(
  telefono INT NOT NULL,
  dni INT NOT NULL,
  CONSTRAINT pk_tele_clien PRIMARY KEY (dni, telefono),
  CONSTRAINT fk_telefono_cliente FOREIGN KEY (dni) REFERENCES cliente(dni)
);
