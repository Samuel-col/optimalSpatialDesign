#-------------------------------------------------------------------------#
#          OPTIMAL CONFIGURATION FOR SPATIAL SAMPLING - TEST              #
#                     Nathaly Vergel y Samuel Sánchez                     #
#-------------------------------------------------------------------------#

rm(list=ls())

library(gstat)
library(rgdal)
library(ggplot2)
library(sf)
library(sp)

source("../src/optimal_design.r")
source("../src/gstat_model.r")
source("../src/own_model.r")

mapa <- rgdal::readOGR(dsn = "../data/Boyacá.shp")

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
target <- sp::spsample(mapa,n = 100, type = "random") # Puntos sobre los que queremos realizar una predicción de varianza mínima.


##
optimal_design(k = 10, s0 = target,vgm_model = modelo_svg,
               krigingType = "simple",map = mapa) -> res1

res1


mi.grilla <- sp::spsample(mapa,n=1e4,type = "regular")
mi.grilla <- mi.grilla[2e3:7e3]                          


optimal_design(k=10,s0 = as.data.frame(target),vgm_model = modelo_svg,
               krigingType = "ordinary",
               grid = as.data.frame(mi.grilla)) -> res2

res2


optimal_design(k = 10, s0 = target, vgm_model = modelo_svg,
               krigingType = "universal", 
               krig_formula = "x + I(x^2) + y",
               grid = as.data.frame(mi.grilla)) -> res3

res3


# Ahora vamos a suministrar un modelo de covarianza propio.

my_cov_model <- function(h, range, psill, nugget = 0){
  ifelse(h == 0,
         nugget + psill,
         ifelse(h > 0,
                psill*(exp((-1)*h/range)),
                "Las distancias deben ser positivas"
         )
  )
}

# Parámetros
my_range = 20000
my_psill = 5
my_nugget = 1


optimal_design(k = 20, s0 = as.data.frame(target), cov_model = my_cov_model,
               krigingType = "simple",map = mapa,
               range = my_range, psill = my_psill,
               nugget = my_nugget) -> res4

res4


optimal_design(k = 10, s0 = as.data.frame(target), cov_model = my_cov_model,
               krigingType = "ordinary",map = mapa,
               range = my_range, psill = my_psill,
               nugget = my_nugget) -> res5

res5


optimal_design(k = 20, s0 = as.data.frame(target), cov_model = my_cov_model,
               krigingType = "universal",map = mapa,
               range = my_range, psill = my_psill,
               nugget = my_nugget,krig_formula = "x + y") -> res6

res6


optimal_design(k = 10, s0 = as.data.frame(target), cov_model = my_cov_model,
               krigingType = "universal",map = mapa,
               range = my_range, psill = my_psill,
               nugget = my_nugget,krig_formula = "x + sqrt(y)") -> res7

res7


# Exportar gráficos
for(i in 1:7){
  print(i)
  new_file <- paste("ej",i,".png",sep="")
  new_path <- paste(getwd(),new_file,sep="/")
  png(filename = new_path,height = 850, width = 1000)
  cat("Se abrió el archivo",new_path,"\n")
  res_object_name <- paste("res",i,sep="")
  res_object <- get(res_object_name)
  plot(res_object$plot)
  dev.off()
}
