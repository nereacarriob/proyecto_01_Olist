Todos los scripts de SQL se han ejecutado en MySQL Workbench. 

### 1. Creación de la Base de Datos

```
  CREATE DATABASE olist
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
```

- **CHARACTER SET utf8mb4**: permite almacenar todos los caracteres Unicode, incluyendo emojis y caracteres especiales, que podrían aparecer en nombres de productos o comentarios de clientes.
- **COLLATE utf8mb4_unicode_ci**: asegura que las comparaciones de texto sean insensibles a mayúsculas/minúsculas y sigan reglas de ordenamiento Unicode.
- De esta forma, se han evitado los problemas de codificación al cargar CSVs con acentos o símbolos.


### 2. Creación de Tablas

- Las tablas se han creado según la estructura de los CSVs originales.
- Se ha usado NULL para columnas donde el CSV puede tener valores vacíos (fechas, números, cantidades), lo que permite incluir celdas vacías sin errores.

Ejemplo - olist_products:

```
product_name_length INT NULL,
product_weight_g INT NULL
```
- Se ha creado un índice en la tabla `olist_geolocation` porque esta contiene millones de registros. Sin índice, las consultas que usen `geolocation_zip_code_prefix` para unir clientes, vendedores y pedidos serían muy lentas.  

### 3. Carga de CSVs

Antes de ejecutar los scripts de carga, es necesario permitir a MySQL la importación de archivos locales:

```
SET GLOBAL local_infile = 1;
```

```
LOAD DATA LOCAL INFILE 'ruta/del/csv'
INTO TABLE tabla
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
```

- **LOCAL**: permite cargar archivos desde tu ordenador (cliente).
- **CHARACTER SET utf8mb4**: garantiza lectura correcta de caracteres especiales.
- **IGNORE 1 ROWS**: evita insertar la fila de cabecera del CSV como datos.
- **Uso de SET y variables @**: transforma valores vacíos en NULL.

Ejemplo - olist_products:

```
SET 
    product_category_name = NULLIF(@product_category_name, ''),
```

### 4. Decisiones sobre integridad de datos y claves foráneas

1.Reviews (olist_order_reviews):
- review_id es PRIMARY KEY.
- Se han ignorado los duplicados en el CSV: asumimos que cada review debe ser única.

2.Productos (olist_products) y traducción de categorías (product_category_name_translation):
- Inicialmente se definió FK sobre product_category_name.
- Se eliminó porque no todos los productos tienen categoría en el CSV de traducción, permitiendo insertar todos los productos sin perder información.
- Finalmente, se ha valorado lo anterior junto con la relevancia del CSV product_category_name_translation para el proyecto y se ha decidido no integrarlo en la Base de Datos.

3.Valores vacíos de números enteros o de fecha:
- Al usar NULL, se han evitado errores Incorrect integer value en celdas vacías del CSV.


### 5. Flujo de carga de CSVs recomendado

- olist_customers
- olist_geolocation
- olist_orders
- olist_order_payments
- olist_order_reviews
- olist_products
- olist_sellers
- olist_order_items

### 6. Comprobación de registros

Después, se ha comprobado que todos los registros importados en cada tabla coinciden con el número de registros originales.

```
SELECT 'customers' AS tabla, COUNT(*) FROM olist_customers
UNION ALL
SELECT 'geolocation' AS tabla, COUNT(*) FROM olist_geolocation
UNION ALL
(...)
```

### 7. Creación de Archivos kpi_reviews y kpi_ventas
En estos archivos se han creado diferentes vistas que permiten explorar los datos y obtener KPIs relevantes para la posterior creación de las tablas finales que se utilizarán en Python.

**Archivo 04_kpi_reviews.sql:**
- `v_reviews_avg_global`: Rating promedio global (de 1 a 5).
- `v_reviews_avg_cat_producto`: Rating promedio por categoría de producto.
- `v_reviews_avg_cliente`: Rating promedio por cliente.
- `v_reviews_avg_vendedor`: Rating promedio por vendedor.
- `v_reviews_rating_distribucion`: Distribución del rating.
- `v_reviews_evolucion_temp`: Evolución temporal del número de reviews y la valoración promedio.  
  Se utilizan dos subconsultas para poder relacionar la evolución mensual de reviews con la evolución mensual de pedidos.
- `v_reviews_clientes_extremos`: Identifica los clientes más críticos y los más positivos según sus valoraciones.

**Archivo 05_kpi_ventas.sql:**

- `v_ventas_global`: Incluye un conjunto de KPIs generales de ventas mensuales, como número de pedidos (`num_pedidos`), importe total (`importe_total`) o número de ítems por pedido (`items_por_pedido_avg`).  
  Se crean dos CTE (`pagos_agrupados` e `items_agrupados`) para evitar problemas de duplicación derivados de las relaciones 1–N entre `olist_orders`, `olist_order_payments` y `olist_order_items` al calcular métricas agregadas.
- `v_ventas_por_cliente`: Incluye un conjunto de KPIs generales de ventas por cliente, como número de pedidos (`num_pedidos`), ticket promedio (`ticket_promedio`) o primera compra (`primera_compra`).  
  Al igual que en el caso anterior, se utilizan CTE para preagrupar los datos y evitar duplicaciones por relaciones 1–N al hacer `JOIN`.
- `v_ventas_por_producto`: Productos más vendidos y con mayor *revenue*.
- `v_entregas_global`: Días promedio de entrega (considerando solo pedidos enviados).


### 8. Creación de Tablas finales Python

Finalmente se han creado las tablas que recogen la información de las distintas vistas de `kpi_reviews` y `kpi_ventas`. Estas tablas serán la base del análisis en Python, que incluirá modelos de predicción de ventas y de segmentación de clientes.

**v_detalle_ventas_mensual:** 
- Ventas agregadas por mes, combinando métricas de ventas, entregas y reviews.
- Columnas: `año_mes`, `num_pedidos`, `clientes_unicos`, `sellers_unicos`, `importe_total`, `ticket_promedio`, `items_totales`, `revenue_por_item`, `dias_promedio_entrega`, `rating_avg_mensual`, `pct_pedidos_con_review`

**v_detalle_clientes:** 
- Métricas de comportamiento por cliente, incluyendo datos de pedidos, frecuencia de compra y reviews.
- Columnas: `id_cliente_unico`, `num_pedidos`, `importe_total`, `ticket_promedio`, `primera_compra`, `ultima_compra`, `items_por_pedido_avg`, `dias_entre_compras_avg`, `num_categorias_compradas`, `num_reviews_cliente`, `ratio_pedidos_con_review`, `tipo_cliente`


| **Vista**                  | **Nivel de agregación**      | **Origen principal**                                               | **Descripción**                                                                                 | **Campos clave**   |
| -------------------------- | ---------------------------- | ------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------- | ------------------ |
| `v_detalle_ventas_mensual` | Mensual (`año_mes`)          | `v_ventas_global`, `v_entregas_global`, `v_reviews_evolucion_temp` | KPIs mensuales combinando ventas, entregas y reviews.                              | `año_mes`          |
| `v_detalle_clientes`       | Cliente (`id_cliente_unico`) | `v_ventas_por_cliente`, `v_reviews_avg_cliente`                    | Métricas de comportamiento y fidelidad del cliente. | `id_cliente_unico` |

