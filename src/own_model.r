#-------------------------------------------------------------------------#
#               OPTIMAL CONFIGURATION FOR SPATIAL SAMPLING                #
#                     Nathaly Vergel y Samuel Sánchez     
#
#                  INGRESAR MODELO PROPIO DE COVARIANZA
#-------------------------------------------------------------------------#


own_model.fn <- function(cov_model,
                      #CRS,
                      points,
                      s0,
                      krigingType,
                      range,
                      psill,
                      nugget,
                      krig_formula,
                      #grid,
                      ...){
  
  # Reestructurar el argumento a optimizar
  points <- matrix(points,ncol=2) # Crear matriz de coordenadas de las estaciones
  
  # Cambiar coordenadas en points por los puntos más cercanos de la grilla
  #dists <- proxy::dist(points,as.matrix(grid),diag=T) # Distancias de los puntos en points a los puntos en la grilla
  #ids <- apply(as.matrix(dists),1,which.min) # Ubicar el punto de la grilla más cercano a cada punto de points
  #points <- as.matrix(grid)[ids,] # Reemplazar los puntos en points por sus pares más cercanos en la grilla
  
  # Algunas restricciones
  if (!(krigingType %in% c("simple", "ordinary", "universal"))){
    stop("El argumento krigingType debe ser 'simple', 'ordinary' o 'universal'")
  }
  if(range < 0.0) {stop("El rango debe ser positivo")}
  if((krigingType == "universal") && (is.null(krig_formula)) ){
    stop("Para el kriging universal es necesario especificar la fórmula en función de 'x' y 'y'")
  }
  
  # Nuestros datos (esto ya est'a en la funci'on principal)
  z <- rep(1, nrow(points))
  colnames(points) <- c("x","y")
  datos <- SpatialPointsDataFrame(coords = points,
                                  data = as.data.frame(z))
  #proj4string(datos) <- CRS
  
  
  # Definir 
  dist_matrix <- as.matrix(dist(points))
  
  # ----------------------#
  #   COVARIANZA
  # ----------------------#
  # Covarianza entre las k estaciones y los N puntos a predecir
  cov0 <- cov_model(proxy::dist(points, s0),
                    range = range,
                    psill = psill,
                    nugget = nugget,
                    ...)
  
  # Covarianza entre las estaciones
  Sigma <- matrix(as.numeric(cov_model(dist_matrix,
                                       range = range,
                                       psill = psill,
                                       nugget = nugget, 
                                       ...)
  ),
  nrow = nrow(points)
  )
  
  ## Calcular lambda segun tipo de kriging
  
  # Objetos u'tiles
  k <- nrow(points)
  N <- nrow(s0)
  ones_k <- matrix(1, k, 1)
  ones_N <- matrix(1, N, 1)
  
  # Simple
  if(krigingType == "simple"){
    #print(noquote("[usando kriging simple]"))
    
    lambda <- solve(Sigma)%*%cov0
  }
  
  # Ordinario
  if(krigingType == "ordinary"){
    #print(noquote("[usando kriging ordinario]"))
    
    aux    <- ones_k%*%((1 + (-1)*(t(ones_k)%*%solve(Sigma)%*%cov0))/as.numeric((t(ones_k)%*%solve(Sigma)%*%ones_k)))
    lambda <- solve(Sigma) %*% (cov0 + aux)  # De dimension k x 1
  }
  
  # Universal
  if(krigingType == "universal"){
    #print(noquote("[usando kriging universal]"))
    
    krig_formula <- as.formula(paste("z ~ ",krig_formula))
    
    # Para las estaciones
    mean_model_points <- lm(formula = krig_formula, data = as.data.frame(datos))
    X_mat <- as.matrix(model.matrix(mean_model_points))
    
    # Para los target
    datos_s0 = as.data.frame(s0); datos_s0$z = 1:N
    mean_model_s0 <- lm(formula = krig_formula, data = datos_s0)
    x_s0 <- t(as.matrix(model.matrix(mean_model_s0)))
    
    # Lambda
    aux1 <- (X_mat%*% solve( t(X_mat)%*%solve(Sigma)%*%X_mat ))
    aux2 <- (x_s0 - t(X_mat)%*%solve(Sigma)%*%cov0)
    lambda <- solve(Sigma)%*%(cov0 + aux1%*%aux2)
  }
  
  # Varianza
  
  # Silla
  C0 = cov_model(0,
                 range = range, 
                 psill = psill, 
                 nugget = nugget, 
                 ...)
  
  variance <- C0*t(ones_N) - 2*diag(t(lambda)%*%cov0) + diag(t(lambda)%*%Sigma%*%lambda)
  
  # Devolver la suma de las varianzas
  return(sum(variance))
}
