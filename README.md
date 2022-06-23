# Diseño de Muestreo Óptimo

Esta función recibe un modelo de varigrama, un mapa (archivo `.shp`) y un conjunto de puntos en los que se quieren hacer predicciones y retorna los lugares en los que se deben tomar los registros para minimizar la varianza del error de predicción a través de kriging simple, ordinario o universal.

De acuerdo con Bohórquez (2022), un diseño óptimo $S_{n}^{*}$ se define como

$$S_{n}^{*}=\arg \max_{S_{n} \in \Xi_{n}} \Phi\left(\boldsymbol{\Theta}, S_{n}\right)$$

donde $\Phi\left(\boldsymbol{\Theta}, S_{n}\right)$ es el criterio de diseño y constituye cualquier medida escalar de información obtenida a partir de la configuración $S_{n}$ y que depende del vector de parámetros. Así, si se conoce el variograma de la variable de interés, entonces es posible optimizar el esquema de muestreo de modo que se minimice una función objetivo relacionada con el error de la predicción. En particular, la varianza del error de las predicciones en $m$ lugares no observados $S_{0}=\{s_{0}^{1}, ..., s_{0}^{m}\}$ puede ser minimizada. 

*aquí mencionamos la varianza de la predicción según el tipo de kriging 
*también hablamos del método de optimización
---

```r

optimal_design <- function(k, s0, model, krigingType = "simple", form = NULL, map, CRS, plt = T)

```
---

## Dependencias

* [`gstat`](https://github.com/r-spatial/gstat)
* [`ggplot2`](https://github.com/tidyverse/ggplot2)
* [`sf`](https://github.com/r-spatial/sf)
* [`sp`](https://github.com/edzer/sp)

Todos estos paquetes están disponibles en [CRAN](https://cran.r-project.org/web/packages/available_packages_by_name.html#available-packages-D).

---

## Argumentos

| Argumento | Descripción |
| ------ | ------ |
|   `k`     |   Número de estaciones a ubicar   |
| `S0` | Objeto de tipo matrix o data.frame que contenga las coordenadas de las ubicaciones de interés (donde se desean hacer predicciones) |
| `model` | Objeto de tipo `vgm`. Modelo de semivarianza. |
| `krigingType`  | Tipo de kriging a utilizar, e.g. "simple", "ordinary" o "universal".  |
| `form` | (Opcional) Fórmula que define la variable dependiente como un modelo lineal de variables independientes, e.g. "x+y".|
| `grid` | Objeto de tipo matrix o data.frame. Grilla de puntos en los cuales se pueden ubicar estaciones. |
| `map` | Objeto de tipo SpatialPolygonsDataFrame que limita el área geográfica donde las estaciones quieren ser ubicadas si no se pasa ningún objeto en el argumento `grid`. |
| `plt` | Booleano que determina se se debe generar un gráfico con el resultado obtenido o no. |

---

## Detalles



---

## Ejemplo

Cargamos la librerías necesarias y el script con la función `optimal_design`.

```r

library(gstat)
library(rgdal)
library(ggplot2)
library(sf)
library(sp)

source("source-DMO.r")

```

Ahora, cargamos el mapa y creamos el modelo de semivariograma con los cuales trabajaremos.

```r

mapa <- rgdal::readOGR(dsn = "Boyacá.shp")

modelo_svg <- vgm(psill = 5.665312,
                  model = "Exc",
                  range = 88033.33,
                  kappa = 1.62,
                  add.to = vgm(psill = 0.893,
                               model = "Nug",
                               range = 0,
                               kappa = 0))

my.CRS <- sp::CRS("+init=epsg:21899") # https://epsg.io/21899

mapa <- spTransform(mapa,my.CRS)

```

Ya podemos crear un conjunto de puntos en el mapa en los cuales queremos predecir de manera óptima y llamar a la función `optimal_design`.

```r

target <- sp::spsample(mapa,n = 100, type = "random")

optimal_design(k = 10, s0 = target,model = modelo_svg,
               krigingType = "simple",map = mapa) -> res1

res1

```

A continuación se muestran otros ejemplos para kriging ordinario y kriging universal suministrando una grilla específica de puntos en los que se pueden unbicar las estaciones

```r

mi.grilla <- sp::spsample(mapa,n=1e4,type = "regular")
mi.grilla <- mi.grilla[2e3:7e3]                          


optimal_design(k=10,s0 = target,model = modelo_svg,
               krigingType = "ordinary",
               grid = as.data.frame(mi.grilla)) -> res2

res2


optimal_design(k = 10, s0 = target, model = modelo_svg,
               krigingType = "universal", form = "x + I(x^2) + y",
               grid = as.data.frame(mi.grilla)) -> res3

res3


```

---
## Referencias

* Bohorquez, M. (2022). Estadística Espacial Espacio-Temporal para Campos Aleatorios Escalares y Funcionales [Notas de Clase].
---

Creado por: 
* Nathaly Vergel  (nvergel@unal.edu.co)
* Samuel Sánchez (ssanchezgu@unal.edu.co)
