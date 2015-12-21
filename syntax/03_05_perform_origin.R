################################################################################
# Barcelona Graduate School of Economics
# Master's Degree in Data Science
################################################################################
# Project  : Computing Lab
# Script   : 03_05_perform_origin.R
################################################################################
# Author   : Miquel Torrens, 2015.11.30
# Modified : Miquel Torrens, 2015.12.03
################################################################################
# source('/Users/miquel/Desktop/bgse/projects/complab/syntax/00_start.R')
# source(paste(SYNTAXDIR, '03_05_perform_origin.R', sep = ''))
################################################################################

################################################################################
main.03.05 <- function() {
################################################################################
  # Print starting time
  bs <- begin.script(paste('[', PROJECT, '] 03_05_perform_origin.R', sep = ''))

  # Define new directories
  GEODIR <- paste(DATADIR, 'geo_json/', sep = '')
  #MAPDIR <- paste(INPUTDIR, 'shp/', sep = '')
  try(dir.create(GEODIR, showWarnings = FALSE))
  #try(dir.create(MAPDIR, showWarnings = FALSE))

  # Load data
  file <- paste(DATADIR, 'song_metadata.RData', sep = '')
  aux <- load(file = file); cat('Loaded file:', file, '\n')
  song.md <- get(aux[1])
  n <- nrow(song.md)
  fn <- format(n, big.mark = ',')

  # Determine locations
  locs <- song.md[, 'artist_location']
  locs <- iconv(locs, from = 'utf8', to = 'ASCII//TRANSLIT')

  # Look for the coordinates on Google
  new.locs <- vector(mode = 'list', length = nrow(song.md))
  for (i in 1:n) {
    fi <- format(i, big.mark = ',')
    cat('\rGetting location data:', fi, 'of', fn)
    loc <- locs[i]
    if (! is.na(loc) && loc != '') {
      id <- song.md[i, 'song_id']
      file <- paste(GEODIR, id, '.RData', sep = '')
      if (! file.exists(file)) {
        Sys.sleep(jitter(0.8, factor = 10))
        res <- google.geolocate(text = loc)
        save(res, file = file)
      } else {
        res <- get(load(file = file))
      }

      # Elements
      if (! res[['status']] %in% c('ZERO_RESULTS')) {
      #if (! res[['status']] %in% c('ZERO_RESULTS', 'UNKNOWN_ERROR')) {
        add <- unlist(res[['results']][[1]]['formatted_address'])
        lat <- unlist(res[['results']][[1]][['geometry']][['location']][1])
        lng <- unlist(res[['results']][[1]][['geometry']][['location']][2])
        typ <- unlist(res[['results']][[1]][['geometry']][['location_type']])
        new.loc <- c(id, add, lat, lng, typ)
      } else {
        new.loc <- c(id, rep(NA, 4))
      }
    } else {
      # Empty songs
      new.loc <- c(id, rep(NA, 4))
    }

    # Add them up
    new.locs[[i]] <- as.data.frame(t(as.data.frame(new.loc)))
    if (i == n) { cat(' [Done!]\n') }
  }

  # New location data
  new.locs <- as.data.frame(rbindlist(new.locs))
  new.locs <- factor2char(df = new.locs)

  # Unify coordinates
  coords <- song.md[, c('artist_longitude', 'artist_latitude')]
  nas <- which(is.na(coords[, 1]))
  coords[nas, 1] <- as.numeric(new.locs[nas, 4])
  coords[nas, 2] <- as.numeric(new.locs[nas, 3])

  # Convert it to points
  pts <- coords[which(! is.na(coords[, 1])), ]
  pts[, 1] <- as.numeric(as.character(pts[, 1]))
  pts[, 2] <- as.numeric(as.character(pts[, 2]))

  # Add small variations to the coordinates so they stack up
  set.seed(666)
  pts2 <- pts[1, ]
  ft <- format(nrow(pts), big.mark = ',')
  for (r in 2:nrow(pts)) {
    fr <- format(r, big.mark = ',')
    cat('\rCorrecting location data:', fr, 'of', ft)
    if (pts[r, 1] %in% pts2[, 1] && pts[r, 2] %in% pts2[, 2]) {
      pts[r, 1] <- jitter(pts[r, 1], factor = 0.001)
      pts[r, 2] <- jitter(pts[r, 2], factor = 0.001)
    }
    pts2 <- rbind.data.frame(pts2, pts[r, ])
    if (fr == ft) { cat(' [Done!]\n') }
  }

  # Convert to spatial data frame
  pts <- pts2
  coordinates(pts) <- pts[, 1:2]
  proj4string(pts) <- CRS_GOOGLE

  # Plor music points
  wmap <- getMap(resolution = 'coarse')
  map.file <- paste(OUTPUTDIR, 'point_map.png', sep = '')
  if (! file.exists(map.file)) { png(map.file) }
  plot(wmap, col = 'lightyellow', main = 'Artist locations')
  points(pts, pch = 16, col = 'red', cex = 0.5)
  if (! file.exists(map.file)) { dev.off() }
  cat('Plotted map:', map.file, '\n')

  # Country-level data
  country <- as.character(sp::over(pts, wmap)[, 'SOVEREIGNT'])
  m0 <- match(wmap@data[, 'SOVEREIGNT'], names(table(country)))
  wmap@data[, 'TOTAL_SONGS'] <- table(country)[m0]
  wmap@data[which(is.na(wmap@data[, 'TOTAL_SONGS'])), 'TOTAL_SONGS'] <- 0
  wmap@data[, 'PERC_SONGS'] <- wmap@data[, 'TOTAL_SONGS'] /
                               sum(wmap@data[, 'TOTAL_SONGS'])
  wmap@data[, 'FPERC_SONGS'] <- cut(wmap@data[, 'PERC_SONGS'], 5)
  #mapCountryData(wmap, nameColumnToPlot = 'FPERC_SONGS')

  # Plotting
  ncolors <- 8
  pvar <- wmap@data[, 'PERC_SONGS']
  pal <- brewer.pal(ncolors, 'PuBu')
  class <- classIntervals(pvar, ncolors, style = 'jenks')
  colors <- findColours(class, pal)

  # Store map
  map.file <- paste(OUTPUTDIR, 'country_map.png', sep = '')
  if (! file.exists(map.file)) { png(map.file) }
  plot(wmap, col = colors, main = 'Music origins')
  #legend('bottomleft', legend = names(attr(colors, 'table')),
  #       fill = attr(colors, 'palette'), cex = 0.6, bty = 'n')
  if (! file.exists(map.file)) { dev.off() }
  cat('Plotted map:', map.file, '\n')

  # European map
  eurmap <- wmap[which(wmap@data[, 'GLOCAF'] == 'Europe' &
                       wmap@data[, 'ADM0_DIF'] == 0), ]
  country <- as.character(sp::over(pts, eurmap)[, 'SOVEREIGNT'])
  m0 <- match(eurmap@data[, 'SOVEREIGNT'], names(table(country)))
  eurmap@data[, 'TOTAL_SONGS'] <- table(country)[m0]
  eurmap@data[which(is.na(eurmap@data[, 'TOTAL_SONGS'])), 'TOTAL_SONGS'] <- 0
  eurmap@data[, 'PERC_SONGS'] <- eurmap@data[, 'TOTAL_SONGS'] /
                                 sum(eurmap@data[, 'TOTAL_SONGS'])
  eurmap@data[, 'FPERC_SONGS'] <- cut(eurmap@data[, 'PERC_SONGS'], 5)
  #mapCountryData(wmap, nameColumnToPlot = 'FPERC_SONGS')

  # Plotting
  ncolors <- 8
  pvar <- eurmap@data[, 'PERC_SONGS']
  pal <- brewer.pal(ncolors, 'PuBu')
  class <- classIntervals(pvar, ncolors, style = 'jenks')
  colors <- findColours(class, pal)
  map.file <- paste(OUTPUTDIR, 'europe_map.png', sep = '')
  if (! file.exists(map.file)) { png(map.file) }
  plot(eurmap, col = colors, main = 'Music origins')
  if (! file.exists(map.file)) { dev.off() }
  cat('Plotted map:', map.file, '\n')

  # # U.S. and U.K. maps
  # country <- as.character(sp::over(pts, wmap)[, 'SOVEREIGNT'])
  # us <- which(country == 'United States of America')
  # uk <- which(country == 'United Kingdom')
  
  # pts <- pts@data[, 1:2]
  # coordinates(pts) <- pts[, 1:2]
  # proj4string(pts) <- proj4string(usmap)

  # library(maps)
  # map('state')
  # aa <- map('state')
  # #usmap <- map('county', lwd = 0.1)

  # usmap <- readRDS(paste0(INPUTDIR,'USA_adm2.rds'))
  # usc <- sp::over(pts[us, ], usmap)
  # usc[, 'count'] <- 1
  # usc[, 'name'] <- paste(tolower(usc[, 'NAME_1']), ',',
  #                        tolower(usc[, 'NAME_2']), sep = '')
  # count <- tapply(usc[, 'count'], usc[, 'name'], sum)

  # ncolors <- 8
  # pvar <- count
  # pal <- brewer.pal(ncolors, 'PuBu')
  # class <- classIntervals(pvar, ncolors, style = 'jenks')
  # colors <- findColours(class, pal)
  # m <- match(map("county", plot=FALSE)$names, names(count))
  # map('county', col = colors[m], fill = TRUE, lwd = 0.1)
  # #plot(eurmap, col = colors, main = 'Music origins')
 
  # Prediction
  # s50 <- which(substr(song.md[, 'songs_year'], 3, 3) == '5')
  # s60 <- which(substr(song.md[, 'songs_year'], 3, 3) == '6')
  # s70 <- which(substr(song.md[, 'songs_year'], 3, 3) == '7')
  # s80 <- which(substr(song.md[, 'songs_year'], 3, 3) == '8')
  # s90 <- which(substr(song.md[, 'songs_year'], 3, 3) == '9')
  # s00 <- which(substr(song.md[, 'songs_year'], 3, 3) == '0')
  # #s10 <- which(substr(song.md[, 'songs_year'], 3, 3) == '1')

  # Get the country data
  pts <- cbind(song.md[, 'song_id'], coords)
  pts <- pts[which(! is.na(pts[, 2])), ]
  pts[, 2] <- as.numeric(as.character(pts[, 2]))
  pts[, 3] <- as.numeric(as.character(pts[, 3]))
  coordinates(pts) <- pts[, 2:3]
  proj4string(pts) <- CRS_GOOGLE
  pts@data[, 'country'] <- as.character(sp::over(pts, wmap)[, 'SOVEREIGNT'])

  # Unify the data
  yc <- song.md[, c('song_id', 'songs_year')]
  yc[, 'country'] <- pts@data[match(yc[, 1], pts@data[, 1]), 'country']
  yc <- yc[which(! is.na(yc[, 'songs_year']) & ! is.na(yc[, 'country'])), ]
  yc <- yc[which(yc[, 'songs_year'] > 1950 & yc[, 'songs_year'] < 2010), ]
  yc[, 'count'] <- rep(1, nrow(yc))
  yc[, 'decade'] <- substr(yc[, 'songs_year'], 3, 3)

  # Set them up in a data frame
  sums <- tapply(yc[, 'count'], paste(yc[, 'country'], yc[, 'decade']), sum)
  totals <- expand.grid(unique(yc[, 'country']), unique(yc[, 'decade']))
  totals <- factor2char(totals)
  totals[, 'tot'] <- 0
  totals[, 'tot'] <- sums[match(paste(totals[, 1], totals[, 2]), names(sums))]
  s50 <- which(totals[, 2] == '5')
  s60 <- which(totals[, 2] == '6')
  s70 <- which(totals[, 2] == '7')
  s80 <- which(totals[, 2] == '8')
  s90 <- which(totals[, 2] == '9')
  s00 <- which(totals[, 2] == '0')
  totals[s50, 2] <- 1950
  totals[s60, 2] <- 1960
  totals[s70, 2] <- 1970
  totals[s80, 2] <- 1980
  totals[s90, 2] <- 1990
  totals[s00, 2] <- 2000
  totals <- totals[order(totals[, 1], totals[, 2]), ]
  totals[which(is.na(totals[, 3])), 3] <- 0
  totals[, 3] <- as.numeric(as.character(totals[, 3]))
  rownames(totals) <- NULL

  # Time series
  for (cty in unique(totals[, 1])) {
    aux <- totals[which(totals[, 1] == cty), ]
    aux[, 3] <- as.numeric(aux[, 3])
    #model <- arima(log(as.numeric(aux[, 3]) + 0.01), c(3, 0, 1))
    if (cty %in% c('Canada', 'Sweden', 'Spain', 'Norway', 'Mexico')) {
      pred <- aux[6, 3] * log(aux[6, 3] / aux[5, 3])
    } else  if (cty %in% c('Australia')) {
      model <- auto.arima(as.numeric(aux[4:5, 3]))
      pred <- max(exp(as.data.frame(forecast(model, 1))[, 1]) - 1, 0)
    } else {
      model <- auto.arima(as.numeric(aux[, 3]))
      pred <- max(as.data.frame(forecast(model, 1))[, 1], 0)
    }
    totals <- rbind.data.frame(totals, c(cty, 2010, round(pred, 0)))
  }

  # Aggregate by decade
  decade <- as.data.frame(unique(totals[, 1]))
  for (dec in unique(totals[, 2])) {
    aux <- totals[which(totals[, 2] == dec), ]
    aux[, 'perc'] <- as.numeric(aux[, 'tot']) / sum(as.numeric(aux[, 'tot']))
    decade <- cbind(decade, round(100 * aux[, 'perc'], 2))
  }
  decade <- decade[order(decade[, ncol(decade)], decreasing = TRUE), ]
  colnames(decade) <- c('country', paste(c(5:9, 0:1), '0s', sep = ''))

  # Inequality index
  herf <- apply(decade[, 2:ncol(decade)], 2, Herfindahl)
  herf <- as.data.frame(t(as.data.frame(c('Herfindahl Index', herf))))
  herf <- factor2char(herf)
  for (j in 2:ncol(herf)) {
    herf[, j] <- round(as.numeric(herf[, j]), 2)
  }
  colnames(herf) <- colnames(decade)
  decade <- rbind.data.frame(herf, decade)
  rownames(decade) <- NULL  

  # Save results
  file <- paste(DATADIR, 'worldwide_prediction.RData', sep = '')
  save(decade, file = file); cat('Saved file:', file, '\n')

  # End script
  end.script(begin = bs, end = Sys.time())
}
# END OF SCRIPT
