## TEMA 1: Procedimientos y Funciones Almacenadas

Según la documentación oficial de Microsoft para SQL Server, un Procedimiento Almacenado es un grupo de una o más instrucciones 
Transact-SQL o una referencia a un método Common Runtime Language (CLR) de Microsoft .NET Framework. 
Los procedimientos se asemejan a las construcciones de otros lenguajes de programación, ya que pueden aceptar parámetros de 
entrada y devolver varios valores en forma de parámetros de salida.

Este tipo de objetos son fundamentales para encapsular la lógica de negocio, mejorar la seguridad y optimizar el rendimiento 
mediante la reutilización de planes de ejecución. Eso es precisamente lo que probaremos en esta sección.

Para ello, realizaremos una comparativa de rendimiento (Benchmarking) en un entorno de alta carga, ejecutando operaciones de 
inserción y lectura sobre una tabla poblada con un volumen considerable de datos, contrastando el método de "SQL Directo" 
frente al uso de "Procedimientos Almacenados" y "Funciones Escalares".

### Pasos realizados
Para nuestras pruebas, utilizamos la tabla persona dentro del contexto de nuestro sistema "Proyecto Restaurante 2025", la cual 
se encuentra poblada con 1,000,000 de registros para simular un entorno de producción real.

Definimos tres escenarios de prueba para medir la eficiencia del motor de base de datos:
  1. Inserción Directa: Envío de la sentencia INSERT completa desde el script.
  2. Inserción vía Procedimiento: Llamada al objeto sp_InsertarPersona.
  3. Lectura vía Función: Transformación de datos usando fn_NombreCompleto

## Proseguiremos con la realización de las pruebas
> Acceder a la imagen de la [Prueba A](prueba_A.png)

> Acceder a la imagen de la [Prueba B](prueba_B.png)

> Acceder a la imagen de la [Prueba C](prueba_C.png)

## Conclusiones Particulares del Tema
Podemos afirmar que, aunque en operaciones aisladas con pocos datos la diferencia es imperceptible, en un entorno con 1 millón de 
registros y alta concurrencia, el uso de Procedimientos Almacenados presenta ventajas técnicas superiores.

Mientras que el SQL Directo obliga al servidor a analizar la sintaxis y generar un plan de ejecución nuevo por cada petición 
(consumiendo más CPU), el Procedimiento Almacenado reutiliza el plan que ya tiene en memoria caché, reduciendo el tiempo de 
procesamiento interno. Además, el tráfico de red disminuye drásticamente, ya que solo se envían los parámetros y el nombre del 
SP, en lugar de la sentencia SQL completa.

Por ende, para garantizar la escalabilidad, la seguridad (evitando inyección SQL) y la mantenibilidad del sistema, es recomendable 
encapsular las operaciones CRUD en Procedimientos y la lógica de transformación repetitiva en Funciones.
