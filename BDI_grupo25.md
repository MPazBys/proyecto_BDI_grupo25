# UNIVERSIDAD NACIONAL DEL NORDESTE
**Facultad de Ciencias Exactas y Naturales y Agrimensura**  
**Cátedra: Base de Datos I**  
**Año: 2025**  
**Grupo: 25**

## Proyecto Base de Datos

### Alumnos:
- **Bys, Paz** - DNI: 46.242.480
- **Cardozo, Micaela** - DNI: 46.461.620
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

# CAPÍTULO II
## ESTUDIO DE TRABAJO

## TEMA 01: PROCEDIMIENTOS Y FUNCIONES ALMACENADAS

### 1. Introduccion y Beneficios: 
Un Procedimiento Almacenado (SP) en SQL Server es un objeto de base de datos que agrupa una o más instrucciones Transact-SQL (el lenguaje de SQL Server) 
en un solo plan de ejecución. También puede ser una referencia a un método CLR de .NET Framework.

Se asemejan a las construcciones de otros lenguajes de programación, ya que están diseñados para:
  - Aceptar parámetros de entrada (ej: @dni) y devolver múltiples valores en forma de parámetros de salida (ej: @id_creado).
  - Contener lógica de programación que realice operaciones complejas en la base de datos, incluyendo la llamada a otros procedimientos.
  - Devolver un valor de estado a la aplicación que lo llamó, para indicar si la operación tuvo éxito o si se produjo un error (y por qué).

#### Beneficios (Eficiencia y Seguridad)
- **Rendimiento y Reducción de Tráfico:** Las operaciones se ejecutan como un solo lote. Esto reduce el tráfico de red, ya que la aplicación solo envía
  una llamada EXEC en lugar de múltiples líneas de código SQL. El plan de ejecución se guarda en caché, acelerando ejecuciones futuras.
- **Seguridad (Encapsulación):** Permiten conceder permiso a un usuario para ejecutar el procedimiento (ej: GRANT EXECUTE ON sp_InsertarPersona) sin darle
  permiso directo para escribir (INSERT) en las tablas. Esto previene ataques de inyección SQL.
- **Mantenimiento (Reutilización):** Encapsulan la lógica de negocio. Si la regla para insertar un registro cambia, solo se modifica el SP, y no todas las
  aplicaciones que lo consumen.

### 2. Gestión y Ciclo de Vida de un Procedimiento Almacenado

Basado en la documentación de Microsoft, el ciclo de vida y la gestión de un procedimiento almacenado (SP) cubre las siguientes tareas:
  - **Creación de un procedimiento almacenado:** Es el proceso inicial donde se define el SP por primera vez. Se utiliza el comando CREATE PROCEDURE.
    Aquí se establece su nombre, los parámetros que recibirá y las instrucciones T-SQL que ejecutará.
  - **Modificar un procedimiento almacenado:** Se refiere a la actualización de un SP que ya existe. Se utiliza el comando ALTER PROCEDURE. Esto permite
    cambiar la lógica interna, añadir o quitar parámetros sin tener que borrarlo y volverlo a crear.
  - **Eliminación de un procedimiento almacenado:** Es el proceso de borrar permanentemente el SP de la base de datos. Se utiliza el comando DROP PROCEDURE.
  - **Ejecución de un procedimiento almacenado:** Es la acción de "llamar" o invocar al SP para que realice su tarea. Se utiliza el comando EXECUTE
    (o su abreviatura EXEC) seguido del nombre del SP y sus parámetros.
  - **Conceder permisos para un procedimiento almacenado:** Se refiere a la gestión de la seguridad. Es el acto de dar permiso (GRANT) a un usuario o rol
    para que pueda ejecutar un SP, sin necesidad de darle permisos directos sobre las tablas que este modifica.
  - **Devolución de datos de un procedimiento almacenado:** Describe las diferentes formas en que un SP puede devolver información a la aplicación que lo llamó.
    Esto puede ser a través de un conjunto de resultados (un SELECT), un parámetro de salida (OUTPUT) o un valor de estado (un número que indica éxito o error).
  - **Volver a compilar un procedimiento almacenado:** Es una tarea de optimización. Cuando un SP se ejecuta por primera vez, SQL Server crea un "plan de ejecución" y lo guarda.
    Recompilarlo (sp_recompile) fuerza al sistema a crear un nuevo plan, lo cual es útil si las tablas han cambiado mucho y el plan antiguo ya no es eficiente.
  - **Cambiar el nombre de un procedimiento almacenado:** Es el comando (sp_rename) que se utiliza para cambiar el nombre de un SP existente.
  - **Visualización de la definición de un procedimiento almacenado:** Es la forma de ver el código fuente (las instrucciones T-SQL) de un SP que ya está creado,
    usualmente usando el comando sp_helptext.
  - **Ver las dependencias de un procedimiento almacenado:** Permite analizar qué objetos (como tablas o vistas) utiliza el SP, o qué otros procedimientos llaman a este SP.
    Es fundamental para el mantenimiento, para saber que si se modifica una tabla, no se "romperá" un SP. 

### 3. Tipos de Procedimientos Almacenados

#### 1. Definidos por el Usuario (User-defined)
Estos son los procedimientos estándar que los desarrolladores crean y almacenan dentro de una base de datos específica (definida por el usuario). Son el tipo 
principal que usarás en tu proyecto. Pueden ser escritos en Transact-SQL o hacer referencia a un método CLR (.NET Framework).

        Ejemplo (T-SQL)
        -- El procedimiento que estamos creando para el proyecto
        CREATE PROCEDURE sp_InsertarPersona
            @dni INT,
            @nombre VARCHAR(100)
        AS
        BEGIN
            INSERT INTO persona (dni, nombre)
            VALUES (@dni, @nombre);
        END
#### 2. Temporales (Temporary)
Son una forma especial de procedimientos definidos por el usuario, pero se almacenan en la base de datos temporal (tempdb) en lugar de en la tuya. Se eliminan automáticamente
  - **Temporal Local (#):**
    El nombre comienza con un solo #.
    Solo es visible para la conexión del usuario que lo creó.
    Se elimina automáticamente cuando ese usuario cierra la conexión.
    Ejemplo: CREATE PROC #MiReporteTemporal ...

  - **Temporal Global (##):**
    El nombre comienza con dos ##.
    Es visible para cualquier usuario después de su creación.
    Se elimina cuando la última sesión que lo estaba usando se cierra.
    Ejemplo: CREATE PROC ##ConfiguracionGlobal ...

#### 3. del Sistema (System)
Estos son los procedimientos preinstalados que vienen con el Motor de Base de Datos. SQL Server los usa para administrar y reportar sobre el estado del sistema.
  - Están almacenados en la base de datos Resource pero aparecen lógicamente en el esquema sys de todas las bases de datos.
  - Comienzan con el prefijo sp_. (Se recomienda no usar sp_ para tus propios procedimientos).

         Ejemplo:

        -- Muestra información sobre el objeto 'persona'
  
        EXEC sp_help 'persona';
  
        -- Muestra las conexiones activas en el servidor
        EXEC sp_who;

#### 4. Extendidos Definidos por el Usuario (Extended)
Estos procedimientos permiten a SQL Server ejecutar rutinas externas escritas en lenguajes como C. Son bibliotecas DLL que el servidor carga y ejecuta dinámicamente.
  - **Usan el prefijo xp_:** 

        -- (A menudo deshabilitado por seguridad)

        -- Ejecuta un comando en el sistema operativo del servidor
        EXEC xp_cmdshell 'DIR C:';

### 3. Funciones Definidas por el Usuario (UDF)
Una función es una rutina que acepta parámetros, realiza una acción (generalmente un cálculo) y siempre debe devolver un valor.

#### Tipos Principales
  - **Funciones Escalares:** Devuelven un único valor (ej: un número, texto o fecha). Son ideales para cálculos repetitivos.
      Ejemplo: fn_CalcularEdad(@fecha_nacimiento)
  - **Funciones con Valores de Tabla (TVF):** Devuelven una tabla completa (un conjunto de resultados). Son como "vistas con parámetros".
      Ejemplo: fn_ReservasDelCliente(@dni)
#### Uso Principal
  La gran ventaja de las funciones es que se pueden usar directamente dentro de un SELECT o WHERE, algo que los procedimientos no pueden hacer.
         
      Ejemplo SQL
      -- Se usa como una columna más
      SELECT
          nombre,
          dbo.fn_CalcularEdad(fecha_nacimiento) AS Edad
      FROM
          persona;

### 4. Aplicación en Operaciones CRUD
Como vimos en la lista anterior, las tareas fundamentales son Crear, Modificar y Eliminar. A continuación, aplicaremos estos conceptos para implementar 
las operaciones CRUD (Crear, Leer, Modificar, Borrar) en nuestro proyecto.

Los procedimientos almacenados son el mecanismo ideal para encapsular y centralizar esta lógica de negocio. Actúan como una "API" segura para la base de datos.
  - **Crear (INSERT):** Se implementa un procedimiento (ej: sp_InsertarPersona) que recibe todos los campos de la nueva fila como parámetros. Esto asegura que
    solo se inserten datos válidos y de la forma correcta, ocultando la lógica del INSERT a la aplicación.
  - **Modificar (UPDATE):** Se diseña un procedimiento (ej: sp_ModificarPersona) que recibe la clave primaria (ej: @dni) para identificar el registro, junto con
    los nuevos valores que se deben actualizar
  - **Borrar (DELETE):** Se crea un procedimiento (ej: sp_BorrarPersona) que solo acepta la clave primaria (@dni). Esto previene eliminaciones accidentales o
    maliciosas y permite añadir lógica de borrado (como un borrado lógico) en un futuro.
  - **Leer (SELECT):** Aunque a menudo se hacen con vistas o funciones, los SPs también son potentes para devolver conjuntos de resultados complejos, permitiendo
    filtros y lógica que una vista simple no puede manejar.

#### Capacidades Avanzadas (Integridad y Errores)
Más allá del CRUD básico, la verdadera potencia de los procedimientos almacenados radica en su capacidad para:
  - **Manejar Transacciones:** Agrupar múltiples comandos (ej: un INSERT en pagos y un UPDATE en reserva) en una sola unidad de trabajo "todo o nada". Si una parte
    falla, todo se revierte (ROLLBACK), garantizando la integridad de los datos.
  - **Gestión Compleja de Errores:** Implementar bloques TRY...CATCH para capturar errores de SQL durante la ejecución. Esto permite devolver mensajes de error claros
    y personalizados a la aplicación, en lugar de mensajes crípticos del sistema.

### 5. Diferencias Clave (Procedimiento vs. Función)

| Característica | Procedimiento Almacenado (SP) |  Función (UDF)  |
|----------------|-------------------------------|-----------------|
| Propósito Principal | Ejecutar acciones (modificar datos, gestionar procesos). | Realizar cálculos y devolver un valor. | 
| Valor de Retorno | No es obligatorio. Puede devolver 0 o más conjuntos de resultados. | Obligatorio. Debe devolver un solo valor (escalar o tabla). | 
| Modificar Datos (CRUD) | Sí. Es su uso ideal (INSERT, UPDATE, DELETE). | No. No pueden "realizar acciones que modifiquen el estado de la base de datos". | 
| Cómo se llama | Con EXECUTE o EXEC. | Directamente en un SELECT o WHERE. | 
| Uso en SELECT | No se puede llamar dentro de un SELECT. | Sí. Es su principal ventaja. | 
| Manejo de Errores | Soporta TRY...CATCH y transacciones completas | Limitado. No soporta TRY...CATCH. | 
| Llamadas | Puede llamar a funciones. | No puede llamar a procedimientos almacenados. | 

## TEMA 02: TRANSACCIONES

## TEMA 03: OPTIMIZACIÓN DE ÍNDICES
### INTRODUCCION

En el ámbito de las bases de datos, crear índices eficaces es primordial para lograr un buen rendimiento de la base de datos, en especial si estamos tratando con grandes volúmenes de información. La ausencia de estos, la sobreindizacion o el mal diseño de los índices son los principales causantes de problemas de rendimiento de la base de datos.

Un índice en SQL funciona igual que un índice en un libro debido a que provee una forma rápida de localizar información en especifica en este mismo. La diferencia es que, en el ámbito de las bases de datos, los índices son una lista ordenada de valores acompañadas de sus punteros que, siendo redundante, apuntan a las paginas de datos donde se encuentran estos valores. Asi mismo los propios índices se almacenan en las denominadas paginas de índice.

Un índice es una estructura en disco o en memoria asociada a una tabla o vista que agiliza la recuperación de los registros de la tabla o vista. Un índice contiene claves creadas a partir de los valores de una o varias columnas de la tabla o vista. Almacenan los datos organizados de forma lógica como una tabla con filas y columnas, que a su vez son almacenados físicamente en un formato de datos de fila denominado almacén de filas

En este proyecto estaremos usando los índices agrupados o también conocidos como clustered pero también abordaremos de manera teorica y explicativa los non clustered.

### Índice Agrupado (Clustered Index)

**Organización física**: Este tipo de índice define y almacena el orden físico real de las filas de datos en el disco. Los datos de la tabla se ordenan y almacenan en el disco exactamente en la misma secuencia que el índice.

**Cantidad por tabla**: Solo puede existir un único índice agrupado por tabla, ya que es imposible que los datos estén físicamente ordenados de más de una manera a la vez.

**Analogía**: Es como ordenar un archivo de documentos por fecha de manera cronológica; los papeles mismos están físicamente en ese orden.

### Índice No Agrupado (Non-Clustered Index)

**Organización lógica**: Un índice no agrupado no altera el orden físico de los datos en la tabla. En su lugar, crea una estructura de datos independiente y separada de la tabla principal.

**Composición**: Esta estructura contiene una copia de las columnas indexadas (la clave del índice) junto con punteros o referencias que indican la ubicación física de cada fila de datos correspondiente en la tabla.

**Cantidad por tabla**: Puede haber múltiples índices no agrupados en una misma tabla.

**Analogía**: Funciona exactamente como el índice alfabético al final de un libro. El índice te dirige rápidamente a los números de página (los punteros) donde se encuentra la información, sin necesidad de que las páginas del libro estén reordenadas.
## TEMA 04: ÍNDICES COLUMNARES

### 1. Introducción y Conceptos Fundamentales 
Un **Índice Columnar (Columnstore Index)** es una tecnología de almacenamiento y procesamiento de datos que organiza los datos a nivel de columna en lugar de a nivel de fila. El objetivo principal de este formato es optimizar las consultas analíticas (scans masivos) en grandes conjuntos de datos, especialmente en entornos de Data Warehousing  (Almacenamiento de Datos).

En cambio, la forma tradicional en cómo se almacenan los datos se denominan **Rowstore**, que es básicamente almacenar físicamente los datos en filas.

En un **Rowgroup** (grupo de filas, forma tradicional), las filas son comprimidas al mismo tiempo con el formato del almacén de columnas. Por el contrario, el almacén de columnas segmenta la tabla en grupos de filas para luego comprimir cada uno de ellos a modo columna.

Para mejorar el rendimiento y reducir la fragmentación de los segmentos, el índice columnar puede almacenar temporalmente algunos datos en un almacén denominado Delta. Este almacén es un grupo de filas Delta que usan índice de árbol B agrupado, teniendo mejoras en cuanto a rendimiento y compresión debido a la utilización de almacenamiento de filas hasta alcanzar 1.048.576 filas para luego moverlas al almacén de columnas.

### 2. Diferencias con los Índices Tradicionales (Rowstore)
La principal distinción es la organización y el enfoque:

| Aspectos | Columnar (Columnstore) | Tradicional (Rowstore) |
|----------|------------------------|-------------------------|
| Organización Física | Los valores de la misma columna se almacenan juntos. | Los valores de una fila completa se almacenan juntos. |
| Optimización | Consultas analíticas, agregaciones y reportes. | Transacciones (OLTP) y búsquedas por clave. 
| Rendimiento Analítico | Utiliza la Ejecución en Modo por Lotes (Batch Mode) para procesar miles de filas a la vez. | Procesa datos fila por fila (Row Mode), más lento para grandes volúmenes. |
| Compresión | Extrema, ya que los valores de una misma columna suelen ser muy similares. | Moderada o estándar (menos eficiente para análisis). |

### 3. Principal Caso de Uso
#### Escenario Principal
- El beneficio máximo se obtiene cuando se necesita analizar grandes volúmenes de datos mediante scans masivos para realizar agregaciones, reportes complejos, o análisis de tendencias.
- Esto se debe a las características únicas del índice columnar:
- Alto Rendimiento en Consultas Analíticas: Proporcionan hasta 10 veces el rendimiento en comparación con el almacenamiento tradicional orientado a filas, gracias a la Ejecución en Modo por Lotes que procesa múltiples filas a la vez.
- Compresión Masiva de Datos: Logran hasta 10 veces más compresión de datos. Esto minimiza la E/S (Input/Output) necesaria para leer la información del disco.

#### Escenarios Secundarios (Análisis Operativo)
- Un caso de uso secundario, pero muy importante, es el análisis operativo en tiempo real.
- Al usar un índice columnar no agrupado sobre una tabla tradicional (Rowstore), se permite que:
  - * La carga de trabajo transaccional (OLTP) utiliza el índice de fila subyacente.
  - * Las consultas analíticas de alto rendimiento utilizan simultáneamente el índice columnar.
- Esto elimina la necesidad de mover los datos a un sistema separado para el análisis.

### 4. Tipos de Índices Columnares
Existen dos implementaciones principales, diseñadas para diferentes escenarios:
- **Agrupado (Clustered Columnstore Index):**
- 1. Es el almacenamiento primario de la tabla, lo que significa que toda la tabla se almacena en formato columnar.
- 2. Ideal para tablas de hechos en Data Warehouses donde el análisis es la única prioridad.

- **No Agrupado (Nonclustered Columnstore Index):**
- 1. Es un índice secundario creado sobre una tabla tradicional (Rowstore). Esto permite el Análisis Operativo en Tiempo Real, donde las transacciones OLTP usan la tabla Rowstore subyacente y las consultas analíticas usan el índice Columnar de alto rendimiento de forma simultánea.
- 2. Las inserciones pequeñas se gestionan inicialmente en el Deltastore (que usa un índice de árbol B), un almacén temporal que es eficiente para transacciones. Estas filas son luego movidas y comprimidas al almacén de columnas una vez que alcanzan un tamaño suficiente.

### 5. Beneficios Principales
- **Alto Rendimiento Analítico:** Ofrece hasta 10 veces más velocidad en consultas analíticas que examinan grandes cantidades de datos.
- **Alta Compresión:** Logra hasta 10 veces más compresión de datos que el almacenamiento sin comprimir, reduciendo costos de almacenamiento y E/S (Input/Output).
- **Eficiencia de Recursos:** La alta compresión reduce la superficie de memoria necesaria, permitiendo a SQL Server ejecutar más consultas y operaciones en memoria.
- **Análisis en Tiempo Real:** Permite realizar análisis de alto rendimiento directamente sobre las cargas de trabajo transaccionales activas sin necesidad de mover los datos a un Data Warehouse separado (usando el índice no agrupado).


# CAPÍTULO IV
## MODELO RELACIONAL

> Modelo Relacional: ![Modelo Relacional](doc/diagrama_BD.png)

## Diccionario De Datos

### Tabla: persona
| Columna | Tipo de Dato | PK/FK | Relación (FK Referencia) | Descripción |
|---------|-------------|--------|-------------------------|-------------|
| dni | BIGINT | PK | N/A | Documento Nacional de Identidad de la persona. Identificador único. |
| nombre | VARCHAR(50) | | N/A | Nombre de la persona. |
| apellido | VARCHAR(50) | | N/A | Apellido de la persona. |
| email | VARCHAR(50) | | N/A | Correo electrónico de la persona. |
| telefono | BIGINT | | N/A | Número de teléfono. |

### Tabla: cliente
| Columna | Tipo de Dato | PK/FK | Relación (FK Referencia) | Descripción |
|---------|-------------|--------|-------------------------|-------------|
| dni_cliente | BIGINT | PK, FK | persona(dni) | DNI del cliente, referencia a la tabla persona. |

### Tabla: estado_reserva
| Columna | Tipo de Dato | PK/FK | Relación (FK Referencia) | Descripción |
|---------|-------------|--------|-------------------------|-------------|
| id_estado | INT | PK | N/A | Identificador único del estado (ej: Confirmada, Cancelada). |
| estado | VARCHAR(30) | | N/A | Nombre descriptivo del estado. |

### Tabla: reserva
| Columna | Tipo de Dato | PK/FK | Relación (FK Referencia) | Descripción |
|---------|-------------|--------|-------------------------|-------------|
| id_reserva | INT | PK | N/A | Identificador único de la reserva. |
| fecha_reserva | DATETIME | | N/A | Fecha programada para la reserva. |
| cant_personas | INT | | N/A | Cantidad de personas de la reserva. |
| fecha_max_cancelacion | DATE |  | N/A | Columna calculada: 48 horas antes de fecha_reserva |
| id_estado | INT | FK | estado_reserva(id_estado) | Estado actual de la reserva. |
| id_evento | INT | FK | evento(id_evento) | Tipo de evento reservado. |
| dni_cliente | BIGINT | FK | empleado(dni_empleado, id_rol) | Cliente que realiza la reserva. |
| dni_empleado | BIGINT | FK | empleado(dni_empleado, id_rol) | Empleado que registró la reserva. |
| id_rol | INT | FK | empleado(dni_empleado, id_rol) | Rol del empleado que registró. |

### Tabla: ubicacion_mesa
| Columna | Tipo de Dato | PK/FK | Relación (FK Referencia) | Descripción |
|---------|-------------|--------|-------------------------|-------------|
| id_ubicacion | INT | PK | N/A | Identificador único de la zona o área del restaurante. |
| ubicacion | VARCHAR(30) | | N/A | Nombre de la ubicación (ej: "Terraza", "Salón"). |

### Tabla: mesa
| Columna | Tipo de Dato | PK/FK | Relación (FK Referencia) | Descripción |
|---------|-------------|--------|-------------------------|-------------|
| id_mesa | INT | PK | N/A | Identificador único interno de la mesa. |
| capacidad | INT | | N/A | Máxima capacidad de personas de la mesa. |
| id_ubicacion | INT | PK, FK | ubicacion_mesa(id_ubicacion) | Ubicación física de la mesa. |

### Tabla: reserva_mesa
| Columna | Tipo de Dato | PK/FK | Relación (FK Referencia) | Descripción |
|---------|-------------|--------|-------------------------|-------------|
| id_reserva | INT | PK, FK | reserva(id_reserva) | Reserva a la que se asigna la mesa. |
| id_mesa | INT | PK, FK | mesa(id_mesa, id_ubicacion) | Mesa asignada a la reserva. |
| id_ubicacion | INT | PK, FK | mesa(id_mesa, id_ubicacion) | Ubicación de la mesa asignada. |

### Tabla: rol_empleado
| Columna | Tipo de Dato | PK/FK | Relación (FK Referencia) | Descripción |
|---------|-------------|--------|-------------------------|-------------|
| id_rol | INT | PK | N/A | Identificador único del rol (ej: Mesero, Gerente). |
| descripcion | VARCHAR(30) | | N/A | Nombre descriptivo del rol del empleado. |

### Tabla: empleado
| Columna | Tipo de Dato | PK/FK | Relación (FK Referencia) | Descripción |
|---------|-------------|--------|-------------------------|-------------|
| dni_empleado | BIGINT | PK, FK | persona(dni) | DNI del empleado, referencia a persona. |
| id_rol | INT | PK, FK | rol_empleado(id_rol) | Rol asignado al empleado. |
| id_turno | INT | FK | turno_empleado(id_turno) | Turno asignado al empleado. |
| activo_en_rol | BIT | FK | N/A | Indicador de rol activo (1) o inactivo (0). |

### Tabla: turno_empleado
| Columna | Tipo de Dato | PK/FK | Relación (FK Referencia) | Descripción |
|---------|-------------|--------|-------------------------|-------------|
| id_turno | INT | PK | N/A | Identificador único del turno programado. |
| inicio_turno | TIME | | N/A | Hora de inicio del turno. |
| fin_turno | TIME | | N/A | Hora de fin del turno. |

### Tabla: metodo_pago
| Columna | Tipo de Dato | PK/FK | Relación (FK Referencia) | Descripción |
|---------|-------------|--------|-------------------------|-------------|
| id_metodo | INT | PK | N/A | Identificador único del tipo de pago. |
| forma_pago | VARCHAR(30) | | N/A | Nombre del método (ej: Efectivo, Tarjeta). |

### Tabla: pagos
| Columna | Tipo de Dato | PK/FK | Relación (FK Referencia) | Descripción |
|---------|-------------|--------|-------------------------|-------------|
| id_pago | INT | PK | N/A | Identificador único de la transacción de pago. |
| monto | DECIMAL(10,2) | | N/A | Monto total del pago realizado. |
| fecha_pago | DATE | | N/A | Fecha en que se realizó el pago. |
| id_metodo | INT | FK | metodo_pago(id_metodo) | Método de pago utilizado. |
| id_reserva | INT | PK, FK | reserva(id_reserva) | Reserva asociada al pago. |

### Tabla: evento
| Columna | Tipo de Dato | PK/FK | Relación (FK Referencia) | Descripción |
|---------|-------------|--------|-------------------------|-------------|
| id_evento | INT | PK | N/A | Identificador único del evento especial. |
| nombre_evento | VARCHAR(30) | | N/A | Nombre del evento (ej: Navidad, Catering corporativo). |


# CAPÍTULO V
## CONCLUSIÓN
