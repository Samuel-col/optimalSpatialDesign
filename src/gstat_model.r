#-------------------------------------------------------------------------#
#               OPTIMAL CONFIGURATION FOR SPATIAL SAMPLING                #
#                     Nathaly Vergel y Samuel Sánchez     
#
#                  INGRESAR MODELO DE COVARIANZA DE GSTAT
#-------------------------------------------------------------------------#

vgm_model.fn <- function(points, s0, vgm_model, krigingType = "simple",
                        krig_formula=NULL,grid
                        ){
  
  N <- nrow(s0) # Número puntos apredecir 
  k <- length(points)/2 # Número de estaciones a ubicar
  z <- rep(1,length=k) # Crear vector de observaciones
  points <- matrix(points,ncol=2) # Crear matriz de coordenadas de las estaciones
  colnames(points) <- c("x","y")
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
                  model = vgm_model,
                  beta = 0,
                  data = datos)
  }
  
  # Kriging Ordinario
  if(krigingType == "ordinary"){
    gObj <- gstat(id="z",
                  formula = z ~ 1,
                  model = vgm_model,
                  data = datos)
  }
  
  # Kriging Universal
  if(krigingType == "universal"){
    if(is.null(krig_formula)){
      stop("El kriging universal requiere de una fórmula")
    }else{
      krig_formula = as.formula(paste("z~",krig_formula))
    }
    gObj <- gstat(id="z",
                  formula = krig_formula,
                  model = vgm_model,
                  data = datos)
  }
  
  invisible(capture.output(
    pred <- predict(object = gObj,newdata = nuevosPuntos) # Realizar kriging
  ))
  sigma <- sum(as.data.frame(pred)$z.var) # Calcular la varianza total
  #cat("\n",sigma,"\n")
  return(sigma)
}