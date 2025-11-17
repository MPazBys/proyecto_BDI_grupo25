## TEMA 4 Índices Columnares

Según el sitio oficial de Microsoft para SQL Server “Un índice columnar es una tecnología de almacenamiento, recuperación y administración de datos que emplea un formato de datos en columnas denominado almacén de columnas.”

Este tipo de índices son utilizados y muy útiles para consultas con grandes números de registros, haciendo que estas sean más eficientes y rápidas, y eso es lo que probaremos en esta sección.

Para ello, utilizaremos índices columnares agrupados, lo cual consistirá en crear una nueva tabla con índice columnar agrupado en base a la principal para luego poder evaluar sus tiempos de respuestas y sacar conclusiones en base a ellas.

### Pasos realizados 

Para nuestras pruebas, usamos como tabla principal “reserva” de nuestro sistema, la nueva tabla que tendrá índice columnar la denominaremos “reserva_columnares”. Tendremos exactamente la misma estructura de la tabla “reserva” en “reserva_columnares”.

Haremos la carga masiva a “reserva_columnares” con base en los registros que se encuentran en la tabla “reserva”. Luego de estos pasos, podremos crear el índice columnar nuestra tabla.

Para esto, usaremos el siguiente comando
```
CREATE CLUSTERED COLUMNSTORE INDEX CCI_reserva_columnares 
ON reserva_columnares
GO
```

Lo que hacemos es decirle al motor que cree un índice llamado “CCI_reserva_columnares”, teniendo en cuenta que en lugar de almacenar los datos en fila, lo haga en columnas. Con lo cual, el motor reorganiza y comprime los registros de la tabla.


## Proseguiremos con la realización de las pruebas 

> Acceder a la imagen de la [Prueba A](pruebaA.png)

> Acceder a la imagen de la [Prueba B](pruebaB.png)

> Acceder a la imagen de la [Prueba C](pruebaC.png)

> Acceder a la imagen de la [Prueba D](pruebaD.png)

> Acceder a la imagen de la [Prueba E](pruebaE.png)

> Acceder a la imagen de la [Prueba F](pruebaF.png)


## Conclusiones Particulares del Tema

Podemos afirmar que para consultas en donde no tengamos que buscar muchos registros, el porcentaje de tiempo de respuesta es casi igual en ambos tipos de índices (Prueba A), pero cuando involucramos una cantidad considerable de registros con operaciones de agregación (AVG, COUNT, SUM, etc), el uso del índice columnar (Columnstore) es considerablemente superior que la forma tradicional (Rowstore). Por ende, en grandes sistemas en donde sea necesario el uso de consultas y subconsultas con millones de registros, es recomendable la utilización de Columnstore, sobre todo si la principal prioridad de estos es el análisis de los mismos.


## Bibliografia

https://learn.microsoft.com/es-es/sql/relational-databases/indexes/columnstore-indexes-overview?view=sql-server-ver17
