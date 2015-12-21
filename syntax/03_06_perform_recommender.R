################################################################################
# Barcelona Graduate School of Economics
# Master's Degree in Data Science
################################################################################
# Project  : Computing Lab
# Script   : 03_06_perform_recommender.R
################################################################################
# Author   : Miquel Torrens, 2015.11.25
# Modified : -
################################################################################
# source('/Users/miquel/Desktop/bgse/projects/complab/syntax/00_start.R')
# source(paste(SYNTAXDIR, '03_06_perform_recommender.R', sep = ''))
################################################################################

################################################################################
main.03.06 <- function() {
################################################################################
  # Print starting time
  script <- paste('[', PROJECT, '] 03_06_perform_recommender.R', sep = '')
  bs <- begin.script(script)
  
  # Read MySQL configuration file
  conf.file <- paste(INPUTDIR, 'mysql_conn.conf', sep = '')
  cat('MySQL configuration read from:', conf.file, '\n')
  conf <- readLines(conf.file, warn = FALSE)
  conf <- trim(strsplit(conf, ':'))
  user <- conf[[1]][2]
  pass <- conf[[2]][2]
  host <- conf[[3]][2]

  # Get connection
  conn <- dbConnect(MySQL(), user, pass, dbname = 'omsong', host)
  cat('Connected to DB: omsong\n')

  # Load data
  aux <- load(file = paste(DATADIR, 'song_metadata.RData', sep = ''))
  song.md <- get(aux[1])
  n <- nrow(song.md)
  fn <- format(n, big.mark = ',')

  # Interesting cloumns
  out.cols <- c('song_id', 'artist_id', 'title', 'artist_name', 'release_name')
  cols <- c('key_confidence', 'loudness', 'tempo',
            'artist_hotttnesss', 'song_key', 'mode_confidence',
            'mean_bars_confidence', 'mean_beats_confidence',
            'mean_segments_loudness_max', 'mean_tatums_confidence',
            'mean_segments_timbre', 'mean_segments_pitches',
            'mean_sections_confidence', 'mean_segments_confidence',
            'mean_segments_start',  'time_signature_confidence',
            'artist_familiarity', 'song_mode')

  out <- vector(mode = 'list', length = n)
  for (id in song.md[, 'song_id']) {
    # Indexing
    mine <- which(song.md[, 'song_id'] == id)
    fi <- format(mine, big.mark = ',')
    cat('\rComputing recommendations:', fi, 'of', fn)

    # Query similar artists
    txt1 <- 'SELECT * FROM artist_relations WHERE song_id = "'
    query <- paste(txt1, id, '";', sep = '')
    send <- dbSendQuery(conn, query)
    relations <- fetch(send, n = -1)

    # If we have no relation, look for artist
    if (nrow(relations) == 0) {
      art.id <- song.md[which(song.md[, 'song_id'] == id), 'artist_id']
      txt2 <- 'SELECT * FROM artist_relations WHERE artist_id = "'
      query <- paste(txt2, art.id, '";', sep = '')
      send <- dbSendQuery(conn, query)
      relations <- fetch(send, n = -1)
    }

    # Fifty most related artists
    relations <- relations[order(relations[, 5]), ]
    pool <- relations[1:50, ]

    # Choose their songs
    sel <- which(song.md[, 'artist_id'] %in% pool[, 'related_artist'])
    #sel <- c(which(song.md[, 'song_id'] == id), sel)
    
    # If we have too few, we are done
    if (length(sel) == 0) {
      nas <- c(rep(NA, length(out.cols)), 1)
      out[[mine]] <- cbind(song.md[mine, out.cols],
                           as.data.frame(t(as.data.frame(nas))))
      next
    } else if (length(sel) < 5) {
      out[[mine]] <- cbind(song.md[rep(mine, length(sel)), out.cols],
                           song.md[sel, out.cols], 1:length(sel))
      next
    }

    # If the pool is not enough, add artists
    idx <- 1
    while (length(sel) < length(cols) + 2 && idx < 51) {
      pool <- relations[1:(50 + idx), ]
      sel <- which(song.md[, 'artist_id'] %in% pool[, 'related_artist'])
      idx <- idx + 1
    }

    # Some do not have enough
    if (idx == 51 & length(sel) < length(cols) + 2) {
      old.cols <- cols
      cols <- cols[1:(length(sel) - 2)]
    }

    # Standardize features
    sel <- c(mine, sel)
    ssongs <- song.md[sel, cols]
    ssongs <- ssongs[which(! is.na(rowSums(song.md[sel, cols]))), ]
    for (j in cols) {
      ssongs[, j] <- (ssongs[, j] - mean(ssongs[, j])) / sd(ssongs[, j])
    }

    # Reestablish previous values
    if (idx == 51 & length(sel) < length(cols) + 2) {
      cols <- old.cols
    }

    # Mahalanobis distance
    dist <- mahalanobis(ssongs, as.numeric(ssongs[1, ]), cov = var(ssongs))
    #dist <- as.matrix(ssongs - rowMeans(ssongs))
    #dist %*% solve(var(ssongs)) %*% t(dist)
    #case <- song.md[which(song.md[, 'song_id'] == id), cols]

    # Find closest
    closest <- as.numeric(names(sort(dist[2:length(dist)])[1:5]))

    # Record the results
    out[[mine]] <- cbind(song.md[rep(mine, 5), out.cols],
                         song.md[closest, out.cols], 1:length(closest))
    if (mine == n) { cat(' [Done!]\n') }
  }

  # Add into a data.frame
  recom <- as.data.frame(rbindlist(out))
  rownames(recom) <- NULL
  colnames(recom) <- c(out.cols, paste('recom', out.cols, sep = '_'), 'rank')

  # Find out which files need to be loaded
  file <- paste(DATADIR, 'results_recommender.RData', sep = '')
  save(recom, file = file); cat('Saved file:', file, '\n')

  # End connection
  dbDisconnect(conn)
  cat('Disconnected from DB: omsong\n')

  # End script
  end.script(begin = bs, end = Sys.time())
}
# END OF SCRIPT
