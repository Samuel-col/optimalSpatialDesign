#-------------------------------------------------------------------------#
#               OPTIMAL CONFIGURATION FOR SPATIAL SAMPLING                #
#                     Nathaly Vergel y Samuel Sánchez                     #
#-------------------------------------------------------------------------#


optimal_design <- function(k, s0, vgm_model = NULL,cov_model = NULL, 
                           krigingType = "simple",range = NULL,
                           psill = NULL, nugget = 0,
                           krig_formula = NULL,grid = NULL,map = NULL,
                           plt = T,...){
  
  # Posiciones iniciales
  estaciones0 <- as.data.frame(sp::spsample(mapa, n = k, type = "random"))
  estaciones0 <- as.matrix(estaciones0)
  
  # Puntos candidatos
  if(is.null(grid)){
    if(is.null(map)){
      stop("No se ha suministrado una grilla ni un mapa de posibles coordenadas para las estaciones.")
    }else{
      # rango <- max(modelo_svg$range)
      grid <- as.data.frame(sp::spsample(mapa,n = 3e3,
                                         type = "regular"))#,
                                         #cellsize = rango/3))
    }
  }

  
  # Validación de argumentos
  if(is.null(vgm_model) & is.null(cov_model)){
    stop("Se debe suministrar un modelo del paqute gstat (vgm_model) o una función de un modelo de covarianza (cov_model).")
  }
  
  # Minimización de la varianza de predicción
  
  if(!is.null(vgm_model)){
    # Llamar a vgm_model
    stats::optim(par = c(estaciones0),fn = vgm_model.fn,s0 = s0, 
        vgm_model = vgm_model,method = "L-BFGS-B",grid=grid,
        krig_formula = krig_formula,krigingType = krigingType,
        control = list(trace = 1L,factr = 1e-6,
                       REPORT = 4L)) -> result
  }else{
    
    if(is.null(range) | is.null(psill)){
      stop("Se deben suministrar el rango (range) y la silla (psill).")
    }
    # Llamar a own_model
    invisible(capture.output(
    stats::optim(par = c(estaciones0),fn = own_model.fn, s0 = s0,
                 krigingType = krigingType,krig_formula = krig_formula,
                 range = range, psill = psill,cov_model = cov_model,
                 nugget = nugget,...,#grid = grid,
                 control = list(trace = 1L,factr = 1e-6,
                                 REPORT = 4L)) -> result
    ))
    
    
  }
  
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