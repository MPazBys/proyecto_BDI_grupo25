
CREATE TABLE persona
(
  dni INT NOT NULL,
  nombre VARCHAR(50) NOT NULL,
  apellido VARCHAR(50) NOT NULL,
  email VARCHAR(50) NOT NULL,
  telefono INT NOT NULL,
  CONSTRAINT pk_persona PRIMARY KEY (dni)
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
  CONSTRAINT pk_mesa PRIMARY KEY (id_mesa, id_ubicacion),
  CONSTRAINT fk_mesa_ubicacion FOREIGN KEY (id_ubicacion) REFERENCES ubicacion_mesa(id_ubicacion)
);


CREATE TABLE estado_reserva
(
  id_estado INT NOT NULL,
  estado VARCHAR(30) NOT NULL,
  CONSTRAINT pk_estado PRIMARY KEY (id_estado)
);

CREATE TABLE evento
(
  id_evento INT NOT NULL,
  nombre_evento VARCHAR(30) NOT NULL,
  CONSTRAINT pk_evento PRIMARY KEY (id_evento)
);

CREATE TABLE cliente
(
  dni_cliente INT NOT NULL,
  CONSTRAINT pk_cliente PRIMARY KEY (dni_cliente),
  CONSTRAINT fk_cliente_persona FOREIGN KEY (dni_cliente) REFERENCES persona(dni)
);

CREATE TABLE rol_empleado
(
  id_rol INT NOT NULL,
  descripcion VARCHAR(30) NOT NULL,
  CONSTRAINT pk_rolempleado PRIMARY KEY (id_rol)
);


CREATE TABLE turno_empleado
(
  id_turno INT NOT NULL,
  inicio_turno INT NOT NULL,
  fin_turno INT NOT NULL,
  CONSTRAINT pk_turno PRIMARY KEY (id_turno)
);

CREATE TABLE empleado
(
  dni_empleado INT NOT NULL,
  id_rol INT NOT NULL,
  id_turno INT NOT NULL,
  CONSTRAINT pk_empleado PRIMARY KEY (dni_empleado, id_rol),
  CONSTRAINT fk_persona_empleado FOREIGN KEY (dni_empleado) REFERENCES persona(dni),
  CONSTRAINT fk_rol_empleado FOREIGN KEY (id_rol) REFERENCES rol_empleado(id_rol),
  CONSTRAINT fk_turno_empleado FOREIGN KEY (id_turno) REFERENCES turno_empleado(id_turno)
);


CREATE TABLE reserva
(
  id_reserva INT NOT NULL,
  fecha_reserva DATE NOT NULL,
  cant_personas INT NOT NULL,
  fecha_max_cancelacion DATE NOT NULL,
  id_estado INT NOT NULL,
  id_evento INT NOT NULL,
  dni_cliente INT NOT NULL,
  dni_empleado INT NOT NULL,
  id_rol INT NOT NULL,
  CONSTRAINT pk_reserva PRIMARY KEY (id_reserva),
  CONSTRAINT fk_reserva_estado FOREIGN KEY (id_estado) REFERENCES estado_reserva(id_estado),
  CONSTRAINT fk_reserva_evento FOREIGN KEY (id_evento) REFERENCES evento(id_evento),
  CONSTRAINT fk_reserva_cliente FOREIGN KEY (dni_cliente) REFERENCES cliente(dni_cliente),
  CONSTRAINT fk_reserva_empleado FOREIGN KEY (dni_empleado, id_rol) REFERENCES empleado(dni_empleado, id_rol)
);


CREATE TABLE reserva_mesa
(
  id_reserva INT NOT NULL,
  id_mesa INT NOT NULL,
  id_ubicacion INT NOT NULL,
  CONSTRAINT pk_reserva_mesa PRIMARY KEY (id_reserva, id_mesa, id_ubicacion),
  CONSTRAINT fk_reserva FOREIGN KEY (id_reserva) REFERENCES reserva(id_reserva),
  CONSTRAINT fk_mesa FOREIGN KEY (id_mesa, id_ubicacion) REFERENCES mesa(id_mesa, id_ubicacion)
);

CREATE TABLE metodo_pago
(
  id_metodo INT NOT NULL,
  forma_pago VARCHAR(30) NOT NULL,
  CONSTRAINT pk_metodo_pago PRIMARY KEY (id_metodo)
);

CREATE TABLE pagos
(
  id_pago INT NOT NULL,
  monto FLOAT NOT NULL,
  fecha_pago DATE NOT NULL,
  id_metodo INT NOT NULL,
  id_reserva INT NOT NULL,
  CONSTRAINT pk_pagos PRIMARY KEY (id_pago, id_reserva),
  CONSTRAINT fk_pago_metodo FOREIGN KEY (id_metodo) REFERENCES metodo_pago(id_metodo),
  CONSTRAINT fk_pago_reserva FOREIGN KEY (id_reserva) REFERENCES reserva(id_reserva)
);
