# Troubleshooting Guide

## Error: "there is no package called 'shiny'"

**Causa**: Los paquetes R necesarios no están instalados en el sistema.

**Solución**:

1. **Verificar qué paquetes faltan:**
   ```r
   source("check_packages.R")
   ```

2. **Instalar todos los paquetes necesarios:**
   ```r
   source("install_packages.R")
   ```

3. **O instalar manualmente:**
   ```r
   install.packages(c("shiny", "DT", "stringr", "dplyr", "reticulate", 
                      "RSQLite", "DBI", "shinyWidgets", "shinydashboard", 
                      "writexl", "ggplot2", "openxlsx", "readxl"))
   ```

4. **Luego ejecutar la app:**
   ```r
   shiny::runApp("app.R")
   ```

**Nota**: Si estás usando RStudio, asegúrate de que estás ejecutando desde la consola de R, no desde el terminal del sistema.

## Error: "cannot open file 'renv/activate.R': Operation not permitted"

**Causa**: El archivo `.Rprofile` está intentando cargar renv, pero renv no está completamente inicializado o hay problemas de permisos.

**Solución 1: Ejecutar sin renv (rápido)**
```r
# Renombrar temporalmente .Rprofile
file.rename(".Rprofile", ".Rprofile.bak")

# Ejecutar la app
shiny::runApp("app.R")

# Restaurar .Rprofile después si es necesario
file.rename(".Rprofile.bak", ".Rprofile")
```

**Solución 2: Usar el script RUN_APP.R**
```r
source("RUN_APP.R")
```

**Solución 3: Inicializar renv correctamente**
```r
# Primero inicializar renv
source("setup_renv.R")

# Luego ejecutar la app
shiny::runApp("app.R")
```

## Error: "cannot find system Renviron"

**Causa**: Problema con la configuración de R en el sistema.

**Solución**: 
- Ejecutar la app directamente sin depender de `.Rprofile`:
```r
# En R, cambiar al directorio del proyecto
setwd("/ruta/completa/al/proyecto/FinApp_RShiny")

# Ejecutar directamente
shiny::runApp("app.R")
```

## Error: Paquetes faltantes

**Causa**: Los paquetes R necesarios no están instalados.

**Solución**:
```r
# Instalar paquetes necesarios
install.packages(c(
  "shiny", "DT", "stringr", "dplyr", "reticulate",
  "RSQLite", "DBI", "shinyWidgets", "shinydashboard",
  "writexl", "ggplot2", "openxlsx", "readxl"
))
```

## Error: Python no disponible

**Causa**: Python no está configurado o los módulos no están instalados.

**Solución**:
- La app funcionará, pero las tasas de cambio no se actualizarán
- Para habilitar Python:
  ```bash
  pip install requests pandas
  ```
- O configurar Python en R:
  ```r
  reticulate::use_python("/ruta/a/python")
  ```

## Error al cargar archivos de datos

**Causa**: Los archivos de datos no están en las rutas esperadas.

**Solución**: Verificar que existan:
- `data/reference/currency_list.csv`
- `data/raw/FinApp_planilla.xlsx`

## Recomendación General

Si tienes problemas persistentes, la forma más simple es:

1. **Renombrar `.Rprofile` temporalmente**:
   ```r
   file.rename(".Rprofile", ".Rprofile.disabled")
   ```

2. **Ejecutar la app directamente**:
   ```r
   shiny::runApp("app.R")
   ```

3. **Si funciona, restaurar `.Rprofile`**:
   ```r
   file.rename(".Rprofile.disabled", ".Rprofile")
   ```

Esto permite que la app funcione sin depender de renv si los paquetes están instalados globalmente.

## Nota sobre gráficos

Algunos gráficos y visualizaciones (por ejemplo, ciertos gráficos de crédito/débito)
todavía están en desarrollo. Es posible que no aparezcan o que muestren un
comportamiento incompleto o experimental en la aplicación actual.

