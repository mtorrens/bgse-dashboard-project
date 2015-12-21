################################################################################
# Barcelona Graduate School of Economics
# Master's Degree in Data Science
################################################################################
# Project  : Computing Lab
# Script   : 04_upload_results.R
################################################################################
# Author   : Miquel Torrens, 2015.11.25
# Modified : Miquel Torrens, 2015.12.01
################################################################################
# source('/Users/miquel/Desktop/bgse/projects/complab/syntax/00_start.R')
# source(paste(SYNTAXDIR, '04_upload_results.R', sep = ''))
################################################################################

################################################################################
main.04 <- function() {
################################################################################
  # Print starting time
  bs <- begin.script(paste('[', PROJECT, '] 04_upload_results.R', sep = ''))

  # Read MySQL configuration file
  conf.file <- paste(INPUTDIR, 'mysql_conn.conf', sep = '')
  cat('MySQL configuration read from:', conf.file, '\n')
  conf <- readLines(conf.file, warn = FALSE)
  conf <- trim(strsplit(conf, ':'))
  user <- conf[[1]][2]
  pass <- conf[[2]][2]
  host <- conf[[3]][2]

  ##############################################################################
  # Get connection
  conn <- dbConnect(MySQL(), user, pass, dbname = 'omsong', host)
  cat('Connected to DB: omsong\n')
  ##############################################################################

  ##############################################################################
  # 1. + 2. Genre and time evolution
  file1 <- paste(DATADIR, 'genre_category.RData', sep = '')
  file2 <- paste(DATADIR, 'song_decade.RData', sep = '')
  genre.cat <- get(load(file = file1)); cat('Loaded file:', file1, '\n')
  song.decade <- get(load(file = file2)); cat('Loaded file:', file2, '\n')

  # Merge the tables
  m <- match(genre.cat[, 1], song.decade[, 1])
  genre.decade <- genre.cat
  genre.decade[, 'decade'] <- song.decade[m, 2]
  nas1 <- which(genre.decade[, 'decade'] == 'other')
  nas2 <- which(genre.decade[, 'genre_category'] == 'others')
  genre.decade[nas1, 'decade'] <- NA
  genre.decade[nas2, 'genre_category'] <- NA

  # Write table on MySQL
  cat('Writing table: song_genre_category... ')
  dbWriteTable(conn = conn,
               name = 'song_genre_decade',
               value = genre.decade,
               row.names = FALSE,
               #overwrite = TRUE)
               append = TRUE)
  cat('Done!\n')
  ##############################################################################

  ##############################################################################
  # 5. Origin
  file <- paste(DATADIR, 'worldwide_prediction.RData', sep = '')
  production <- get(load(file = file)); cat('Loaded file:', file, '\n')

  # Little cleaning
  production <- cbind.data.frame(1:nrow(production), production)
  rownames(production) <- NULL
  colnames(production) <- c('rank', 'country', 'fifties', 'sixties',
                            'seventies', 'eighties', 'nineties',
                            'two_thousands', 'twenty_tens')

  # Write table on MySQL
  cat('Writing table: world_production... ')
  dbWriteTable(conn = conn,
               name = 'world_production',
               value = production,
               row.names = FALSE,
               #overwrite = TRUE)
               append = TRUE)
  cat('Done!\n')
  ##############################################################################

  ##############################################################################
  # 6. Recommendations
  # Load the recommendations
  file <- paste(DATADIR, 'results_recommender.RData', sep = '')
  recom <- get(load(file = file)); cat('Loaded file:', file, '\n')

  # Add ID for the MySQL table
  ids <- paste(recom[, 'song_id'], recom[, 'recom_song_id'], sep = '_')
  #cols <- c('song_recom_id', colnames(recom))
  cols <- c('song_recom_id', 'song_id', 'artist_id', 'title', 'artist_name',
            'release_name', 'recom_song_id', 'recom_artist_id',
            'recommended_song', 'recommended_artist', 'album', 'rank')
  recom <- cbind(ids, recom)
  colnames(recom) <- cols
  rownames(recom) <- NULL

  # Write tables on MySQL
  cat('Writing table: results_recommender... ')
  dbWriteTable(conn = conn,
               name = 'results_recommender',
               value = recom,
               row.names = FALSE,
               #overwrite = TRUE)
               append = TRUE)
  cat('Done!\n')
  ##############################################################################

  ##############################################################################
  # End connection
  dbDisconnect(conn)
  cat('Disconnected from DB: omsong\n')
  ##############################################################################

  # End script
  end.script(begin = bs, end = Sys.time())
}
# END OF SCRIPT
