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

olist_customers
olist_geolocation
olist_orders
olist_order_payments
olist_order_reviews
olist_products
olist_sellers
olist_order_items

### 6. Comprobación de registros

Finalmente, se ha comprobado que todos los registros importados en cada tabla coinciden con el número de registros originales.

```
SELECT 'customers' AS tabla, COUNT(*) FROM olist_customers
UNION ALL
SELECT 'geolocation' AS tabla, COUNT(*) FROM olist_geolocation
UNION ALL
(...)
```
