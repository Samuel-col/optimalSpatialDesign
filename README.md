# Diseño de Muestreo Óptimo

Esta función recibe un modelo de varigrama, un mapa (archivo `.shp`) y un conjunto de puntos en los que se quieren hacer predicciones y retorna los lugares en los que se deben tomar los registros para minimizar la varianza de la predicción a través de kriging simple, ordinario o universal.

---

```r

nombre_de_la_funcion(arg1,arg2,...)

```

---

## Dependencias

* [`gstat`](https://github.com/r-spatial/gstat)
* [`spsann`](https://github.com/Laboratorio-de-Pedometria/spsann-package)
* [`ggplot2`](https://github.com/tidyverse/ggplot2)
* [`sf`](https://github.com/r-spatial/sf)
* [`rgdal`](https://github.com/cran/rgdal)
* [`sp`](https://github.com/edzer/sp)

Todos estos paquetes están disponibles en [CRAN](https://cran.r-project.org/web/packages/available_packages_by_name.html#available-packages-D) excepto `spsann` el cual debe ser descargado a partir de github.

---

## Argumentos

*Aquí explicamos en qué consiste cada argumento como si fuera la documentación de R*

---

## Detalles



---

## Ejemplo


---

Creado por: 
* Nathaly Vergel  (nvergel@unal.edu.co)
* Samuel Sánchez (ssanchezgu@unal.edu.co)
