#-------------------------------------------------------------------------#
#          OPTIMAL CONFIGURATION FOR SPATIAL SAMPLING - TEST              #
#                     Nathaly Vergel y Samuel Sánchez                     #
#-------------------------------------------------------------------------#

rm(list=ls())
setwd("/home/samuel/Documentos/U/Espacial/Parciales/p1")

library(gstat)
library(rgdal)
library(ggplot2)
library(sf)
library(sp)
#library(crayon)

source("source-DMO.r")

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
target <- sp::spsample(mapa,n = 100, type = "random")

optimal_design(k = 10, s0 = target,model = modelo_svg,
               krigingType = "simple",map = mapa) -> res1

res1


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
