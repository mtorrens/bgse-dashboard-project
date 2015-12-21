################################################################################
# Barcelona Graduate School of Economics
# Master's Degree in Data Science
################################################################################
# Project  : Computing Lab
# Script   : 02_upload_sql.R
################################################################################
# Author   : Miquel Torrens, 2015.11.08
# Modified : -
################################################################################
# source('/Users/miquel/Desktop/bgse/projects/complab/syntax/00_start.R')
# source(paste(SYNTAXDIR, '02_upload_sql.R', sep = ''))
################################################################################

################################################################################
main.02 <- function() {
################################################################################
  # Print starting time
  bs <- begin.script(paste('[', PROJECT, '] 02_upload_sql.R', sep = ''))

  # Read MySQL configuration file
  conf.file <- paste(INPUTDIR, 'mysql_conn.conf', sep = '')
  cat('MySQL configuration read from:', conf.file, '\n')
  conf <- readLines(conf.file, warn = FALSE)
  conf <- gdata::trim(strsplit(conf, ':'))
  user <- conf[[1]][2]
  pass <- conf[[2]][2]
  host <- conf[[3]][2]

  ##############################################################################
  # Get connection
  conn <- dbConnect(MySQL(), user, pass, dbname = 'omsong', host)
  cat('Connected to DB: omsong\n')
  #dbListTables(conn)
  ##############################################################################

  ##############################################################################
  # Load the data
  file <- paste(DATADIR, 'song_metadata.RData', sep = '')
  song.md <- get(load(file = file)); cat('Loaded file:', file, '\n')

  #aa <- apply(song.md, 2, function(x) { max(nchar(x)) })
  #for (i in 1:length(aa)) {
  #  cat(colnames(song.md)[i], ':', aa[i], '(', song.md[2, i], ')\n')
  #}

  # Some of the columns will be added on other tables
  kill.cols <- c('artist_terms', 'artist_terms_freq', 'artist_terms_freq.1',
                 'similar_artists', 'artist_mbtags', 'artist_mbtags_count')
  for (col in kill.cols) {
    song.md[, col] <- NULL  
  }

  for (j in c('artist_name', 'release_name', 'title')) {
    song.md[, j] <- iconv(song.md[, j], from = 'utf8', to = 'ASCII//TRANSLIT')
  }

  # Add full name for web display
  song.md[, 'artist_title'] <- paste(song.md[, 'artist_name'],
                                     song.md[, 'title'], sep = ' - ')

  # Write table on MySQL
  cat('Writing table: song_metadata... ')
  dbWriteTable(conn = conn,
               name = 'song_metadata',
               value = song.md,
               row.names = FALSE,
               append = TRUE)
  cat('Done!\n')

  # Clean session
  rm(song.md); gc()
  #for (col in 1:ncol(song.md)) {
  #  song.md[, col] <- gsub(' ', '_', song.md[, col])
  #  song.md[, col] <- gsub("'", '.', song.md[, col])
  #  song.md[which(is.na(song.md[, col])), col] <- 'NULL'
  #  song.md[which(song.md[, col] == ''), col] <- 'NULL'
  #}
  #txt1 <- 'INSERT INTO song_metadata ('
  #txt2 <- paste(colnames(song.md), collapse = ', ')
  #txt3 <- ') VALUES ('
  #txt4 <- ');'
  #query <- paste(txt1, txt2, txt3, paste(song.md[i, ], collapse = "', '"), txt4)
  #dbGetQuery(conn, query)
  ##############################################################################

  ##############################################################################
  # Unstructured tables
  f1 <- paste(TEMPDIR, 'rels.RData', sep = '')
  f2 <- paste(TEMPDIR, 'tags.RData', sep = '')
  f3 <- paste(TEMPDIR, 'term.RData', sep = '')
  if (! file.exists(f1)) {
    file <- paste(DATADIR, 'song_database.RData', sep = '')
    dbase <- get(load(file = file)); cat('Loaded file:', file, '\n')
    dbase <- dbase[c(1:7620, 7622:length(dbase))]
    n <- length(dbase)
    nf <- format(n, big.mark = ',')

    # Unstructured metadata
    metadata <- vector(mode = 'list', length = n)
    msbrainz <- vector(mode = 'list', length = n)
    for (i in 1:n) {
      iff <- format(i, big.mark = ',')
      cat('\rExtracting unstructured information:', iff, 'of', nf)
      metadata[[i]] <- dbase[[i]]['metadata']
      msbrainz[[i]] <- dbase[[i]]['musicbrainz']
      if (i == n) { cat(' [Done!]\n') }
    }

    # Related artists and terms
    rels <- vector(mode = 'list', length = n)
    term <- vector(mode = 'list', length = n)
    tags <- vector(mode = 'list', length = n)
    for (i in 1:n) {
      iff <- format(i, big.mark = ',')
      cat('\rMatching artist relations:', iff, 'of', nf)
      sid <- metadata[[i]][[1]]['songs'][[1]]['song_id'][1, 1]
      aid <- metadata[[i]][[1]]['songs'][[1]]['artist_id'][1, 1]
      sim <- metadata[[i]][[1]][['similar_artists']]
      ter <- cbind(metadata[[i]][[1]][['artist_terms']],
                   metadata[[i]][[1]][['artist_terms_freq']],
                   metadata[[i]][[1]][['artist_terms_weight']])
      tag <- cbind(unlist(msbrainz[[i]][[1]][1]),
                   unlist(msbrainz[[i]][[1]][2]))

      # Relations
      term[[i]] <- cbind(sid, aid, ter)  # Warning
      rels[[i]] <- cbind(sid, expand.grid(aid, sim), 1:length(sim))
      term[[i]] <- cbind(paste(term[[i]][, 2], term[[i]][, 3], sep = '-'),
                         term[[i]])
      rels[[i]] <- cbind(paste(rels[[i]][, 2], rels[[i]][, 3], sep = '-'),
                         rels[[i]])
      colnames(term[[i]]) <- c('term_artist_id', 'song_id', 'artist_id',
                               'artist_term', 'term_freq', 'term_weight')
      colnames(rels[[i]]) <- c('relation_id', 'song_id', 'artist_id',
                               'related_artist', 'relation_rank')
      term[[i]] <- as.data.frame(term[[i]])

      # Tags
      if (nrow(tag) > 0) {
        tags[[i]] <- cbind(sid, aid, tag)
        tags[[i]] <- cbind(paste(tags[[i]][, 1], tags[[i]][, 3], sep = '-'),
                           tags[[i]])
        colnames(tags[[i]]) <- c('song_tag_id', 'song_id', 'artist_id',
                                 'song_tag', 'tag_freq')
      } else {
        tags[[i]] <- c()
      }
      if (i == n) { cat(' [Done!]\n') }
    }

    # Aggregate
    rels <- factor2char(as.data.frame(rbindlist(rels)))
    tags <- factor2char(as.data.frame(do.call('rbind', tags)))
    term <- factor2char(as.data.frame(rbindlist(term)))
    tags[, 5] <- round(as.numeric(tags[, 5]), 6)
    term[, 5] <- round(as.numeric(term[, 5]), 6)
    term[, 6] <- round(as.numeric(term[, 6]), 6)
    rownames(tags) <- NULL

    # Save results
    save(rels, file = f1)
    save(tags, file = f2)
    save(term, file = f3)
  } else {
    # If the work is already done just load it
    rels <- get(load(file = f1))
    tags <- get(load(file = f2))
    term <- get(load(file = f3))
  }

  # Write tables on MySQL
  cat('Writing table: artist_relations... ')
  dbWriteTable(conn = conn,
               name = 'artist_relations',
               value = rels,
               row.names = FALSE,
               append = TRUE)

  cat('Done!\nWriting table: artist_terms... ')
  dbWriteTable(conn = conn,
               name = 'artist_terms',
               value = term,
               row.names = FALSE,
               append = TRUE)

  cat('Done!\nWriting table: song_tags... ')
  dbWriteTable(conn = conn,
               name = 'song_tags',
               value = tags,
               row.names = FALSE,
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
