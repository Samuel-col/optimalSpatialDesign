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

target <- sp::spsample(mapa,n = 10, type = "random")
target <- spTransform(target,my.CRS)
#target <- sp::spsample(spTransform(mapa,CRS.output),n = 10, type = "random")

optimal_design(k = 3, s0 = target,model = modelo_svg,
               krigingType = "simple",map = mapa, CRS = my.CRS) -> res

res
