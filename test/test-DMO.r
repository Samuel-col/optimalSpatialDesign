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
#library(crayon)

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
target <- sp::spsample(mapa,n = 100, type = "random")

optimal_design(k = 10, s0 = target,vgm_model = modelo_svg,
               krigingType = "simple",map = mapa) -> res1

res1

# png("ej1.png",height = 650, width = 700)
# res1$plot
# dev.off()


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

# Fórmula para el kriging universal
my_formula = formula("z ~ x + y")


optimal_design(k = 10, s0 = as.data.frame(target), cov_model = my_cov_model,
               krigingType = "simple",map = mapa,
               range = my_range, psill = my_psill,
               nugget = my_nugget) -> res4

res4


optimal_design(k = 10, s0 = as.data.frame(target), cov_model = my_cov_model,
               krigingType = "ordinary",map = mapa,
               range = my_range, psill = my_psill,
               nugget = my_nugget) -> res5

res5


optimal_design(k = 10, s0 = as.data.frame(target), cov_model = my_cov_model,
               krigingType = "ordinary",map = mapa,
               range = my_range, psill = my_psill,
               nugget = my_nugget,krig_formula = my_formula) -> res6

res6


my_formula = formula("z ~ x + sqrt(y)")

optimal_design(k = 10, s0 = as.data.frame(target), cov_model = my_cov_model,
               krigingType = "ordinary",map = mapa,
               range = my_range, psill = my_psill,
               nugget = my_nugget,krig_formula = my_formula) -> res7

res7
