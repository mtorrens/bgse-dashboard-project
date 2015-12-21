################################################################################
# Barcelona Graduate School of Economics
# Master's Degree in Data Science
################################################################################
# Project  : Computing Lab
# Script   : 03_01_perform_genre.R
################################################################################
# Author   : Niti Mishra, 2015.12.18
# Modified : -
################################################################################
# source('/Users/miquel/Desktop/bgse/projects/complab/syntax/00_start.R')
# source(paste(SYNTAXDIR, '03_01_perform_genre.R', sep = ''))
################################################################################

################################################################################
main.03.01 <- function() {
################################################################################
  # Print starting time
  bs <- begin.script(paste('[', PROJECT, '] 03_01_perform_genre.R', sep = ''))

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
  ##############################################################################

  ##############################################################################
  # Load data
  file <- paste(DATADIR, 'song_metadata.RData', sep = '')
  aux <- load(file = file); cat('Loaded file:', file, '\n')
  song.md <- get(aux[1])

  # Song tags data
  query <- dbSendQuery(conn, 'SELECT * FROM song_tags;')
  song.tags <- fetch(query, n = -1)

  # Artist terms data
  query <- dbSendQuery(conn, 'SELECT * FROM artist_terms;')
  artist.terms <- fetch(query, n = -1)
  ##############################################################################

  ##############################################################################
  # Merging
  # Add song tags to song.md
  m <- match(song.md[, 'song_id'], song.tags[, 'song_id'])
  song.md[, 'song_tag'] <- song.tags[m, 'song_tag']

  # assign one artist.terms
  ord <- order(artist.terms[, 'song_id'],
               artist.terms[, 'term_freq'], decreasing = TRUE)
  artist.terms <- artist.terms[ord, ]

  # Add artist terms to song.md
  m <- match(song.md[, 'song_id'], artist.terms[, 'song_id'])
  song.md[, 'artist_term'] <- artist.terms[m, 'artist_term']

  # Create new column with updated genre
  nas <- which(is.na(song.md[, 'song_tag']))
  song.md[, 'updated_genre'] <- song.md[, 'song_tag']
  song.md[nas, 'updated_genre'] <- song.md[nas, 'artist_term']

  # Create new column with genre category  
  song.md[, 'genre_category'] <- 'others'
  txt1 <- 'rock|country|grunge|punk|metal|alternative rock|folk|indie'
  txt2 <- 'hip|hop|hiphop|hip-hop|rap|r&b|rnb'
  txt3 <- 'jazz|saxophone|sax'
  txt4 <- 'blues|swing'
  txt5 <- 'motown|funk|soul|reggae|ska|bob-marley|bob marley|pop'
  txt6 <- 'edm|electronic|trance|house|tech|techno|dub|disco|dance'
  txt7 <- 'latin|salsa|brazi|cuban|americana|bossa|bolero'
  song.md[grepl(txt1, song.md[,'updated_genre']), 'genre_category'] <- 'Rock'
  song.md[grepl(txt2, song.md[,'updated_genre']), 'genre_category'] <- 'Hiphop'
  song.md[grepl(txt3, song.md[,'updated_genre']), 'genre_category'] <- 'Jazz'
  song.md[grepl(txt4, song.md[,'updated_genre']), 'genre_category'] <- 'Blues'
  song.md[grepl(txt5, song.md[,'updated_genre']), 'genre_category'] <- 'Funk'
  song.md[grepl(txt6, song.md[,'updated_genre']), 'genre_category'] <- 'EDM'
  song.md[grepl(txt7, song.md[,'updated_genre']), 'genre_category'] <- 'Latin'

  # Save the category for web queries
  genre.cat <- song.md[, c('song_id', 'genre_category')]
  file <- paste(DATADIR, 'genre_category.RData', sep = '')
  save(genre.cat, file = file); cat('Saved file:', file, '\n')

  # Select variables 
  cols <- c('key_confidence', 'loudness', 'tempo',
            'artist_hotttnesss', 'song_key', 'mode_confidence',
            'mean_bars_confidence', 'mean_beats_confidence',
            'mean_segments_loudness_max', 'mean_tatums_confidence',
            'mean_segments_timbre', 'mean_segments_pitches',
            'mean_sections_confidence', 'mean_segments_confidence',
            'mean_segments_start',  'time_signature_confidence',
            'artist_familiarity', 'song_mode', 'song_id', 'genre_category')

  # Omit rows with 'others' in genre category, and select variables in cols
  genre.only <- song.md[! grepl('others', song.md[, 'genre_category']), cols]

  # Select variables for PCA
  A <- genre.only[, c(1:4, 6:8, 10:12, 14)]
  cc <- complete.cases(A)
  A <- as.matrix(A[cc, ])
  genre <- genre.only[cc, cols]
  Song_ID <- genre[, 'song_id']
  colnames(A) <- c('KEY', 'LOUD', 'TEMPO', 'A.HOTNESS', 'MODE', 'BARS', 'BEATS',
                   'TATUMS', 'TIMBRE', 'PITCH', 'SEGMENT')
  rownames(A) <- Song_ID

  ##############################################################################
  # Principal Components Analysis
  A.pca <- princomp(scale(A[, 1:11]), scores = TRUE)
  
  ## Results
  #A.pca$loadings

  # PCA plot
  colr <- c('#ffd92f', '#8dd3c7', '#33a02c', '#1f78b4', '#e31a1c',
            '#ff7f00', '#c51b8a')
  g <- ggbiplot(A.pca, labels = '-', obs.scale = 1, var.scale = 1,
                varname.size = 5, varname.adjust = 3,
                groups = genre[, 'genre_category'], ellipse = TRUE) + 
       scale_color_manual(name = 'GENRE', values = colr) + 
       xlim(-4.5, 5) + ylim(-4, 5) +
       #xlab('Principal Component 1') + ylab('Principal Component 2') +
       ggtitle('First Two Principal Components of 11 Variables of Each Song')

  ##############################################################################
  # Customize the plot
  # Function to rescale the x & y positions of the lines and labels
  # Plot
  png.file <- paste(OUTPUTDIR, 'pca_genre.png', sep = '')
  if (! file.exists(png.file)) {
    aux <- function(a0, a1, M = M) {
      l <- lapply(as.list(environment()), as.numeric)
      out <- M * (l$a1 - l$a0) + l$a0
      grid::unit(out, 'native')
    }

    # Get list of grobs in current graphics window
    grobs <- grid.ls(print = FALSE)  

    # Find segments grob for the arrows
    s_id <- grobs$name[grep('segments', grobs$name)]

    # Edit length and colour of lines
    seg <- grid.get(gPath(s_id[2]))
    try(grid.edit(gPath(s_id[2]),
                  x1 = aux(seg$x0, seg$x1, 1), 
                  y1 = aux(seg$y0, seg$y1, 1),
                  gp = gpar(col = 'black')))

    # Final plot
    png(png.file, width = 600, height = 600)
    g
    dev.off()    
  }
  cat('Plotted PCA:', png.file, '\n')

  ##############################################################################
  # End connection
  dbDisconnect(conn)
  cat('Disconnected from DB: omsong\n')
  ##############################################################################

  # End script
  end.script(begin = bs, end = Sys.time())
}
# END OF SCRIPT
