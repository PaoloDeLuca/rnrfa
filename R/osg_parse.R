#' Converts OS Grid Reference to BNG/WGS coordinates.
#'
#' @author Claudia Vitolo
#'
#' @description This function converts an Ordnance Survey (OS) grid reference to easting/northing or latitude/longitude coordinates.
#'
#' @param gridRefs This is a string (or a character vector) that contains the OS grid Reference.
#' @param CoordSystem By default, this is "BNG" which stands for British National Grids. The other option is to set CoordSystem = "WGS84", which returns latitude/longitude coordinates (more info can be found here https://www.epsg-registry.org/).
#'
#' @return vector made of two elements: the easting and northing (by default) or latitude and longitude coordinates.
#'
#' @export
#'
#' @examples
#' \dontrun{
#'   # single entry
#'   osg_parse(gridRefs="TQ722213")
#'
#'   # multiple entries
#'   osg_parse(gridRefs=c("SN831869","SN829838"))
#' }
#'

osg_parse <- function(gridRefs, CoordSystem = "BNG" ) {

  xlon <- c()
  ylat <- c()

  for (gridRef in gridRefs){

    # Starting point is the south-west corner

    # First letter identifies the 500x500 km grid
    firstLetter <- substr(gridRef,1,1)
    # Englan + Wales + Scotland
    if (firstLetter=="S") {xOffset1 <- 0;   yOffset1 <- 0}
    if (firstLetter=="T") {xOffset1 <- 500; yOffset1 <- 0}
    if (firstLetter=="N") {xOffset1 <- 0;   yOffset1 <- 500}
    if (firstLetter=="H") {xOffset1 <- 0;   yOffset1 <- 1000}
    if (firstLetter=="O") {xOffset1 <- 500; yOffset1 <- 500}

    # Norther Ireland?
    if (firstLetter=="I") {
      yOffset1 <- 0
      xOffset1 <- 0
      EPSG <- 29902
      defaultCRS <- sp::CRS("+init=epsg:29902")
    }else{
      EPSG <- 27700
      defaultCRS <- sp::CRS("+init=epsg:27700")
    }

    # Second letter identifies the 100x100 km grid
    secondLetter <- substr(gridRef,2,2)
    if (secondLetter=="A") {yOffset2 <- 400; xOffset2 <- 0}
    if (secondLetter=="B") {yOffset2 <- 400; xOffset2 <- 100}
    if (secondLetter=="C") {yOffset2 <- 400; xOffset2 <- 200}
    if (secondLetter=="D") {yOffset2 <- 400; xOffset2 <- 300}
    if (secondLetter=="E") {yOffset2 <- 400; xOffset2 <- 400}
    if (secondLetter=="F") {yOffset2 <- 300; xOffset2 <- 0}
    if (secondLetter=="G") {yOffset2 <- 300; xOffset2 <- 100}
    if (secondLetter=="H") {yOffset2 <- 300; xOffset2 <- 200}
    if (secondLetter=="J") {yOffset2 <- 300; xOffset2 <- 300}
    if (secondLetter=="K") {yOffset2 <- 300; xOffset2 <- 400}
    if (secondLetter=="L") {yOffset2 <- 200; xOffset2 <- 0}
    if (secondLetter=="M") {yOffset2 <- 200; xOffset2 <- 100}
    if (secondLetter=="N") {yOffset2 <- 200; xOffset2 <- 200}
    if (secondLetter=="O") {yOffset2 <- 200; xOffset2 <- 300}
    if (secondLetter=="P") {yOffset2 <- 200; xOffset2 <- 400}
    if (secondLetter=="Q") {yOffset2 <- 100; xOffset2 <- 0}
    if (secondLetter=="R") {yOffset2 <- 100; xOffset2 <- 100}
    if (secondLetter=="S") {yOffset2 <- 100; xOffset2 <- 200}
    if (secondLetter=="T") {yOffset2 <- 100; xOffset2 <- 300}
    if (secondLetter=="U") {yOffset2 <- 100; xOffset2 <- 400}
    if (secondLetter=="V") {yOffset2 <- 0; xOffset2 <- 0}
    if (secondLetter=="W") {yOffset2 <- 0; xOffset2 <- 100}
    if (secondLetter=="X") {yOffset2 <- 0; xOffset2 <- 200}
    if (secondLetter=="Y") {yOffset2 <- 0; xOffset2 <- 300}
    if (secondLetter=="Z") {yOffset2 <- 0; xOffset2 <- 400}

    # Split the numeric grid reference in half and extract to x, y
    n <- nchar(gridRef) - 2
    x <- (substr(gridRef, 3, (n / 2) + 2))
    y <- (substr(gridRef, (n / 2) + 3, n + 2))

    # Adjust grid reference to metres while prefixing letter conversion
    n <- 5 - nchar(x)
    xO <- (xOffset1 + xOffset2) / 100
    yO <- (yOffset1 + yOffset2) / 100
    x <- as.numeric(paste0(xO, x, paste0(rep(0, times=n), collapse="")))
    y <- as.numeric(paste0(yO, y, paste0(rep(0, times=n), collapse="")))

    # Create a spatial data frame with the coordinates.
    xy <- data.frame(x, y)
    sp::coordinates(xy) <- ~x + y
    sp::proj4string(xy) <- defaultCRS

    # this is the epsg code for OSgrid references in metres. To convert to lat-long WGS84 coords:
    if (CoordSystem == "WGS84") {
      xy <- sp::spTransform(xy, sp::CRS("+init=epsg:4326"))
    }

    xlon <- c(xlon, xy@coords[[1]])
    ylat <- c(ylat, xy@coords[[2]])

  }

  if (CoordSystem == "BNG") newCoords <- list("easting"=xlon, "northing"=ylat)
  if (CoordSystem == "WGS84") newCoords <- list("lon"=xlon, "lat"=ylat)

  return(newCoords)

}
