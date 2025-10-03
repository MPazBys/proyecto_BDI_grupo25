# UNIVERSIDAD NACIONAL DEL NORDESTE
**Facultad de Ciencias Exactas y Naturales y Agrimensura**  
**Cátedra: Base de Datos I**  
**Año: 2025**  
**Grupo: 25**

## Proyecto Base de Datos

### Alumnos:
- **Cardozo, Micaela** - DNI: [pendiente]
- **Bys, Paz** - DNI: [pendiente]
- **Cespedes, Hernan** - DNI: 42.739.764
- **Centurion Villamayor, Giovanni Isaias** - DNI: 96.079.673

---

# CAPÍTULO I
## Descripción del Trabajo

Nuestro proyecto consistirá en una base de datos enfocada a la administración y control de un bar/restaurante/local de comidas, la idea surge desde la experiencia de algunos alumnos del grupo que hemos podido trabajar en estos locales y presenciamos la precariedad de algunos de estos sistemas usados.

El objetivo general es realizar una base de datos para poder subsanar estos problemas y ofrecer un mejor manejo, consistencia y seguridad de datos a dichos emprendimientos.

Otros objetivos que queremos cumplir es poder ofrecer distintos tipos de perfiles para el manejo de la base de datos, cada uno con diferentes permisos, funciones y tipos de accesos. Mejorar la gestión de mesas, de clientes, de empleados y mejorar el registro de pagos.

## Alcance del Proyecto

El alcance del sistema está definido por las entidades y relaciones del esquema, cubriendo las siguientes áreas funcionales:

### 1. Gestión Integral de Reservas
- **Creación y Modificación**: Registrar y actualizar reservas asociadas a un Cliente (DNI, nombre, contacto) con fecha, hora y número de personas.
- **Asignación de Mesas**: Gestionar la asignación de una o varias Mesas a una reserva, considerando la capacidad y la UbicacionMesa (ej., terraza, salón).
- **Control de Estado**: Seguimiento del estado de la reserva a través de Estado_reserva (ej., confirmada, cancelada, completada).
- **Manejo de Cancelaciones**: Registro de las políticas o instancias de anulación en HorarioCancelacion.

### 2. Gestión de Mesas y Disponibilidad
- **Inventario**: Mantenimiento del catálogo de Mesas y sus características (número, capacidad).
- **Distribución**: Clasificación de mesas según su UbicacionMesa.
- **Disponibilidad en Tiempo Real**: Proveer información sobre qué mesas están libres u ocupadas en un momento dado, basándose en los registros de Reserva_Mesa.

### 3. Gestión de Clientes y Comunicación
- **Registro Central**: Almacenar datos básicos (Cliente).
- **Datos de Contacto**: Gestionar múltiples contactos por cliente (EmailCliente, TelefonoCliente).

### 4. Eventos y Promociones
- **Definición de Eventos**: Registro de EventosEspeciales (nombre, descripción).
- **Vinculación**: Asociación de reservas específicas con un evento mediante ReservaEvento.

### 5. Transacciones y Pagos
- **Registro de Pagos**: Documentación de cada pago realizado para una reserva (Pagos), incluyendo el monto y la fecha_pago.
- **Métodos de Pago**: Clasificación de las transacciones por MetodoPago (ej., tarjeta, efectivo).
- **Trazabilidad**: Identificación del Empleado responsable de procesar la transacción.

### 6. Gestión Básica de Personal y Turnos
- **Identificación**: Registro del Empleado (DNI, nombre).
- **Roles**: Asignación de funciones mediante RolEmpleado.
- **Horarios**: Planificación y registro de TurnoEmpleado (fecha, hora inicio/fin) para el personal.

## Exclusiones (Lo que NO está en el alcance)
- **Punto de Venta (POS)**: El sistema no abarca la gestión detallada de órdenes, menús, ingredientes, inventario de cocina o facturación fiscal compleja.
- **Nómina y Recursos Humanos**: No incluye el cálculo de sueldos, impuestos, vacaciones detalladas, o la gestión completa de RR.HH. del personal.
- **Marketing/Fidelización**: No incluye módulos avanzados de CRM, envío automatizado de correos de marketing o programas de lealtad.

---

# CAPÍTULO IV
## MODELO RELACIONAL

## Diccionario De Datos

### Tabla: Cliente
| Columna | Tipo de Dato | PK/FK | Relación (FK Referencia) | Descripción |
|---------|-------------|--------|-------------------------|-------------|
| DNI | VARCHAR(15) | PK | N/A | Documento Nacional de Identidad del cliente. Identificador único. |
| nombre | VARCHAR(100) | | N/A | Nombre del cliente. |
| apellido | VARCHAR(100) | | N/A | Apellido del cliente. |
| email | VARCHAR(100) | | N/A | Email del cliente. |

### Tabla: TelefonoCliente
| Columna | Tipo de Dato | PK/FK | Relación (FK Referencia) | Descripción |
|---------|-------------|--------|-------------------------|-------------|
| DNI | VARCHAR(15) | FK | Cliente (DNI) | DNI del cliente asociado. |
| telefono | VARCHAR(20) | PK | N/A | Número de teléfono del cliente. |

### Tabla: Estado_reserva
| Columna | Tipo de Dato | PK/FK | Relación (FK Referencia) | Descripción |
|---------|-------------|--------|-------------------------|-------------|
| ID_estado | INT | PK | N/A | Identificador único del estado (ej: Confirmada, Cancelada). |
| estado | VARCHAR(50) | | N/A | Nombre descriptivo del estado. |

### Tabla: Reserva
| Columna | Tipo de Dato | PK/FK | Relación (FK Referencia) | Descripción |
|---------|-------------|--------|-------------------------|-------------|
| ID_reserva | INT | PK | N/A | Identificador único de la reserva. |
| fecha_reserva | DATE | | N/A | Fecha programada para la reserva. |
| hora_reserva | TIME | | N/A | Hora programada para la reserva. |
| cant_personas | INT | | N/A | Cantidad de personas de la reserva. |
| DNI | VARCHAR(15) | FK | Cliente (DNI) | DNI del cliente que realiza la reserva. |
| ID_estado | INT | FK | Estado_reserva (ID_estado) | Estado actual de la reserva. |
| ID_turno | INT | FK | TurnoEmpleado (ID_turno) | Turno de empleado asociado a la gestión de esta reserva (puede ser el que la registró). |
| DNI_empleado | VARCHAR(15) | FK | Empleado (DNI_empleado) | Empleado que registró o gestionó la reserva. |

### Tabla: HorarioCancelacion
| Columna | Tipo de Dato | PK/FK | Relación (FK Referencia) | Descripción |
|---------|-------------|--------|-------------------------|-------------|
| ID_cancelacion | INT | PK | N/A | Identificador único del registro de cancelación. |
| ID_reserva | INT | FK | Reserva (ID_reserva) | Reserva que fue cancelada. |
| motivo | VARCHAR(255) | | N/A | Razón de la cancelación. |
| fecha_cancelacion | DATE | | N/A | Fecha en que se registró la cancelación. |
| hora_cancelacion | TIME | | N/A | Hora en que se registró la cancelación. |

### Tabla: UbicacionMesa
| Columna | Tipo de Dato | PK/FK | Relación (FK Referencia) | Descripción |
|---------|-------------|--------|-------------------------|-------------|
| ID_ubicacion | INT | PK | N/A | Identificador único de la zona o área del restaurante. |
| ubicacion | VARCHAR(100) | | N/A | Nombre de la ubicación (ej: "Terraza", "Salón"). |

### Tabla: Mesa
| Columna | Tipo de Dato | PK/FK | Relación (FK Referencia) | Descripción |
|---------|-------------|--------|-------------------------|-------------|
| ID_mesa | INT | PK | N/A | Identificador único interno de la mesa. |
| nro_mesa | INT | | N/A | Número visible o identificador físico de la mesa. |
| capacidad | INT | | N/A | Máxima capacidad de personas de la mesa. |
| ID_ubicacion | INT | FK | UbicacionMesa (ID_ubicacion) | Ubicación física de la mesa. |

### Tabla: Reserva_Mesa
| Columna | Tipo de Dato | PK/FK | Relación (FK Referencia) | Descripción |
|---------|-------------|--------|-------------------------|-------------|
| ID_reserva | INT | PK, FK | Reserva (ID_reserva) | Reserva a la que se asigna la mesa. |
| ID_mesa | INT | PK, FK | Mesa (ID_mesa) | Mesa asignada a la reserva. |
| nro_dia | INT | | N/A | (Uso alternativo) Número de día de la semana. |
| inicio_dispo | TIME | | N/A | Hora de inicio de la ocupación/disponibilidad para la reserva. |
| fin_dispo | TIME | | N/A | Hora de fin de la ocupación/disponibilidad para la reserva. |
| fecha_dispo | DATE | | N/A | Fecha específica de la asignación. |

### Tabla: RolEmpleado
| Columna | Tipo de Dato | PK/FK | Relación (FK Referencia) | Descripción |
|---------|-------------|--------|-------------------------|-------------|
| ID_rol | INT | PK | N/A | Identificador único del rol (ej: Mesero, Gerente). |
| nombre_rol | VARCHAR(100) | | N/A | Nombre descriptivo del rol del empleado. |

### Tabla: Empleado
| Columna | Tipo de Dato | PK/FK | Relación (FK Referencia) | Descripción |
|---------|-------------|--------|-------------------------|-------------|
| DNI_empleado | VARCHAR(15) | PK | N/A | DNI del empleado. Identificador único. |
| nombre | VARCHAR(100) | | N/A | Nombre del empleado. |
| apellido | VARCHAR(100) | | N/A | Apellido del empleado. |
| ID_rol | INT | FK | RolEmpleado (ID_rol) | Rol asignado al empleado. |

### Tabla: TurnoEmpleado
| Columna | Tipo de Dato | PK/FK | Relación (FK Referencia) | Descripción |
|---------|-------------|--------|-------------------------|-------------|
| ID_turno | INT | PK | N/A | Identificador único del turno programado. |
| DNI_empleado | VARCHAR(15) | FK | Empleado (DNI_empleado) | Empleado asignado a este turno. |
| fecha_turno | DATE | | N/A | Fecha del turno de trabajo. |
| inicio_turno | TIME | | N/A | Hora de inicio de la jornada. |
| fin_turno | TIME | | N/A | Hora de fin de la jornada. |
| hr_turno | TIME | | N/A | Duración del turno (horas). |

### Tabla: MetodoPago
| Columna | Tipo de Dato | PK/FK | Relación (FK Referencia) | Descripción |
|---------|-------------|--------|-------------------------|-------------|
| ID_metodo | INT | PK | N/A | Identificador único del tipo de pago. |
| nombre_pago | VARCHAR(50) | | N/A | Nombre del método (ej: Efectivo, Tarjeta). |

### Tabla: Pagos
| Columna | Tipo de Dato | PK/FK | Relación (FK Referencia) | Descripción |
|---------|-------------|--------|-------------------------|-------------|
| ID_pago | INT | PK | N/A | Identificador único de la transacción de pago. |
| ID_reserva | INT | FK | Reserva (ID_reserva) | Reserva a la que está asociado el pago. |
| monto | DECIMAL(10,2) | | N/A | Monto total del pago realizado. |
| fecha_pago | DATE | | N/A | Fecha en que se realizó el pago. |
| ID_metodo | INT | FK | MetodoPago (ID_metodo) | Método de pago utilizado. |
| ID_empleado | VARCHAR(15) | FK | Empleado (DNI_empleado) | Empleado que procesó el pago. |

### Tabla: EventoEspecial
| Columna | Tipo de Dato | PK/FK | Relación (FK Referencia) | Descripción |
|---------|-------------|--------|-------------------------|-------------|
| ID_evento | INT | PK | N/A | Identificador único del evento especial. |
| nombre_evento | VARCHAR(100) | | N/A | Nombre del evento (ej: Navidad, Catering corporativo). |
| description | VARCHAR(255) | | N/A | Descripción detallada del evento. |

### Tabla: ReservaEvento
| Columna | Tipo de Dato | PK/FK | Relación (FK Referencia) | Descripción |
|---------|-------------|--------|-------------------------|-------------|
| ID_reserva | INT | PK, FK | Reserva (ID_reserva) | Reserva asociada al evento especial. |
| ID_evento | INT | PK, FK | EventoEspecial (ID_evento) | Evento especial al que corresponde la reserva. |
