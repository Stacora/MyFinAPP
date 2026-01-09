# Guía de Inicio Rápido

## Paso 1: Verificar Paquetes

Abre R o RStudio y ejecuta:
```r
source("check_packages.R")
```

Esto te dirá qué paquetes están instalados y cuáles faltan.

## Paso 2: Instalar Paquetes Faltantes

Si faltan paquetes, ejecuta:
```r
source("install_packages.R")
```

O instala manualmente:
```r
install.packages(c("shiny", "DT", "stringr", "dplyr", "reticulate", 
                   "RSQLite", "DBI", "shinyWidgets", "shinydashboard", 
                   "writexl", "ggplot2", "openxlsx", "readxl"))
```

## Paso 3: Ejecutar la Aplicación

### Opción A: Desde RStudio (Recomendado)
1. Abre `app.R` en RStudio
2. Haz clic en el botón "Run App" (arriba a la derecha del editor)

### Opción B: Desde la consola de R
```r
shiny::runApp("app.R")
```

### Opción C: Usando el script helper
```r
source("RUN_APP.R")
```

## Si Tienes Problemas

### Error: "there is no package called 'shiny'"
→ Los paquetes no están instalados. Ejecuta `source("install_packages.R")`

### Error: "cannot open file 'renv/activate.R'"
→ Renombra temporalmente `.Rprofile`:
```r
file.rename(".Rprofile", ".Rprofile.bak")
shiny::runApp("app.R")
```

### Error: "cannot find system Renviron"
→ Ejecuta la app directamente desde R/RStudio, no desde el terminal del sistema.

## Notas Importantes

- **Ejecuta desde R o RStudio**, no desde el terminal del sistema con `Rscript`
- Si los paquetes están instalados globalmente, la app funcionará sin renv
- Python es opcional - la app funcionará sin él, pero las tasas de cambio no se actualizarán

### Nota sobre gráficos

Algunas partes de la sección de gráficos (por ejemplo, ciertos gráficos de crédito
y débito) todavía están en construcción. Es posible que algunos gráficos no se
muestren o que aparezcan de forma parcial mientras el backend se termina de
implementar.

