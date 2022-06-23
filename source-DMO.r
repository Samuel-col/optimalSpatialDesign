#-------------------------------------------------------------------------#
#               OPTIMAL CONFIGURATION FOR SPATIAL SAMPLING                #
#                     Nathaly Vergel y Samuel Sánchez                     #
#-------------------------------------------------------------------------#

#----------- Función a maximizar ---------------#

criterio <- function(points, s0, model, krigingType = "simple",
                    form=NULL,grid
                    ){
  
  N <- nrow(s0) # Número puntos apredecir 
  k <- length(points)/2 # Número de estaciones a ubicar
  z <- rep(0,length=k) # Crear vector de observaciones
  points <- matrix(points,ncol=2) # Crear matriz de coordenadas de las estaciones
  datos <- SpatialPointsDataFrame(coords = points,
                                  data = as.data.frame(z)) # Crear SpatialPointsDataFrame
  nuevosPuntos <- SpatialPoints(s0) # Crear SpatialPoints a predecir
  
  # Cambiar coordenadas en points por los puntos más cercanos de la grilla
  dists <- proxy::dist(points,as.matrix(grid),diag=T) # Distancias de los puntos en points a los puntos en la grilla
  ids <- apply(as.matrix(dists),1,which.min) # Ubicar el punto de la grilla más cercano a cada punto de points
  points <- as.matrix(grid)[ids,] # Reemplazar los puntos en points por sus pares más cercanos en la grilla
  
  # Kriging Simple
  if(krigingType == "simple"){ 
    gObj <- gstat(id="z",
                  formula = z ~ 1,
                  model = model,
                  beta = 0,
                  data = datos)
  }
  
  # Kriging Ordinario
  if(krigingType == "ordinary"){
    gObj <- gstat(id="z",
                  formula = z ~ 1,
                  model = model,
                  data = datos)
  }
  
  # Kriging Universal
  if(krigingType == "universal"){
    if(is.null(form)){
      stop("El kriging universal requiere de una fórmula")
    }else{
      formula = as.formula(paste("z~",form))
    }
    gObj <- gstat(id="z",
                  formula = formula,
                  model = model,
                  data = datos)
  }
  
  invisible(capture.output(
    pred <- predict(object = gObj,newdata = nuevosPuntos) # Realizar kriging
  ))
  sigma <- sum(as.data.frame(pred)$z.var) # Calcular la varianza total
  #cat("\n",sigma,"\n")
  return(sigma)
}



#-------------- Función DMO -------------------------#

# * Incluir modelos externos a vgm
# * En las grillas regularmente espaciadas la distancia mínima en estaciones por defecto es 1/3 del rango, pero el usuario lo puede cambiar.
# * Escribir documentación sobre todo lo anterior.

optimal_design <- function(k, s0, model, krigingType = "simple",
                           form=NULL,grid=NULL,map=NULL,plt = T){
  
  # Posiciones iniciales
  estaciones0 <- as.data.frame(sp::spsample(mapa, n = k, type = "random"))
  estaciones0 <- as.matrix(estaciones0)
  
  # Puntos candidatos
  if(is.null(grid)){
    if(is.null(map)){
      stop("No se ha suministrado una grilla ni un mapa de posibles coordenadas para las estaciones.")
    }else{
      rango <- max(modelo_svg$range)
      grid <- as.data.frame(sp::spsample(mapa,n = 3e3,
                                         type = "regular",
                                         cellsize = rango/3))
    }
  }

  # Minimización de la varianza de predicción
  stats::optim(par = c(estaciones0),fn = criterio,s0 = s0, 
      model = model,method = "L-BFGS-B",grid=grid,
      control = list(trace = 1L,factr = 1e-6,
                     REPORT = 4L)) -> result
  matrix(result$par,ncol=2) -> nuevas_estaciones
  
  dist.tmp <- proxy::dist(nuevas_estaciones,as.matrix(grid))
  ids.tmp <- apply(as.matrix(dist.tmp),1,which.min)
  nuevas_estaciones <- as.matrix(grid)[ids.tmp,]
  
  
  # Graficar
  if(plt){
    library(ggplot2)
    library(sf)
    s0 <- as.data.frame(s0)
    ggplot() + 
      geom_point(aes(x=grid[,1],y=grid[,2]),colour = "gray90") + # Agregar grilla
      geom_sf(data = st_as_sf(mapa),fill= "#ffffff00",
                      colour = "gray40") + # Agregar mapa
      geom_point(aes(x = s0[,1],y=s0[,2],
                     col = "P. Interés")) +  # Agregar puntos a predecir
      geom_point(aes(x=nuevas_estaciones[,1],y = nuevas_estaciones[,2],
                     col = "Estaciones")) +  # Agregar estaciones
      theme_light() +
      labs(title = "Resultados: Diseño de Muestreo Óptimo",
           subtitle = paste(k,"nuevas estaciones"),
           caption = "Nathaly Vergel & Samuel Sánchez",
           x = "Longitud",y = "Latitud") +
      theme(legend.title = element_blank()) -> fit.plot
    
  }
  
  if(plt){
    return(list(coords = nuevas_estaciones,plot = fit.plot))
  }else{
    return(nuevas_estaciones)
  }
  
}