# Diseño de Muestreo Óptimo

This sentence uses `$` delimiters to show math inline:  $\sqrt{3x-1}+(1+x)^2$

Esta función recibe un modelo de varigrama, un mapa (archivo `.shp`) y un conjunto de puntos en los que se quieren hacer predicciones y retorna los lugares en los que se deben tomar los registros para minimizar la varianza del error de predicción a través de kriging simple, ordinario o universal.

De acuerdo con Un diseño óptimo $S_{n}^{*}$ se 
$
S_{n}^{*}=\arg \operatorname{má}_{S_{n} \in \Xi_{n}} \Phi\left(\boldsymbol{\Theta}, S_{n}\right)
$
donde $\Phi(\boldsymbol{\Theta}, S_{n})$ es el criterio de diseño y puede ser cualquier medida escalar de información obtenida a partir de la configuración $S_{n}$ y que depende del vector de parámetros $\Theta$. El criterio de diseño en el contexto de muestreo espacial depende

Si se conoce el variograma de la variable de interés, entonces es posible optimizar el esquema de muestreo de modo que se minimice una función objetivo relacionada con el error de predicción. En particular, la varianza del error de predicción asociada al kriging puede ser minimizada.

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
