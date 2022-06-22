# Diseño de Muestreo Óptimo

Esta función recibe un modelo de varigrama, un mapa (archivo `.shp`) y un conjunto de puntos en los que se quieren hacer predicciones y retorna los lugares en los que se deben tomar los registros para minimizar la varianza del error de predicción a través de kriging simple, ordinario o universal.

De acuerdo con Bohórquez (2022), un diseño óptimo $S_n^{*}$ se define como

$$S_{n}^{*}=\arg \max_{S_{n} \in \Xi_{n}} \Phi\left(\boldsymbol{\Theta}, S_{n}\right)$$


donde $\Phi\left(\boldsymbol{\Theta}, S_{n}\right)$ es el criterio de diseño y constituye cualquier medida escalar de información obtenida a partir de la configuración $S_{n}$ y que depende del vector de parámetros $\Theta$. Así, si se conoce el variograma de la variable de interés, entonces es posible optimizar el esquema de muestreo de modo que se minimice una función objetivo relacionada con el error de la predicción. En particular, la varianza del error de las predicciones en $m$ lugares no observados $S_{0}=\left\{\boldsymbol{s}_{0}^{1}, \ldots, \boldsymbol{s}_{0}^{B}\right\}$ puede ser minimizada. 

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
## Referencias

* Bohorquez, M. (2022). Estadística Espacial Espacio-Temporal para Campos Aleatorios Escalares y Funcionales [Notas de Clase].
---

Creado por: 
* Nathaly Vergel  (nvergel@unal.edu.co)
* Samuel Sánchez (ssanchezgu@unal.edu.co)
