################################################################################
# Barcelona Graduate School of Economics
# Master's Degree in Data Science
################################################################################
# Project  : Computing Lab
# Script   : 03_02_perform_evolution.R
################################################################################
# Author   : Niti Mishra, 2015.12.18
# Modified : -
################################################################################
# source('/Users/miquel/Desktop/bgse/projects/complab/syntax/00_start.R')
# source(paste(SYNTAXDIR, '03_02_perform_evolution.R', sep = ''))
################################################################################

################################################################################
main.03.02 <- function() {
################################################################################
  # Print starting time
  script <- paste('[', PROJECT, '] 03_02_perform_evolution.R', sep = '')
  bs <- begin.script(script)

  ##############################################################################
  # Data cleaning
  # Load data
  file <- paste(DATADIR, 'song_metadata.RData', sep = '')
  aux <- load(file = file); cat('Loaded file:', file, '\n')
  song.md <- get(aux[1])

  # Create new column with decade category
  song.md[, 'decade'] <- 'other'
  opt1 <- which(song.md[, 'songs_year'] > 1919 &
                song.md[, 'songs_year'] < 1960)
  opt2 <- which(song.md[, 'songs_year'] > 1959 &
                song.md[, 'songs_year'] < 1970)
  opt3 <- which(song.md[, 'songs_year'] > 1969 &
                song.md[, 'songs_year'] < 1980)
  opt4 <- which(song.md[, 'songs_year'] > 1979 &
                song.md[, 'songs_year'] < 1990)
  opt5 <- which(song.md[, 'songs_year'] > 1989 &
                song.md[, 'songs_year'] < 2000)
  opt6 <- which(song.md[, 'songs_year'] > 1999 &
                song.md[, 'songs_year'] < 2010)
  opt7 <- which(song.md[, 'songs_year'] > 2009 &
                song.md[, 'songs_year'] < 2020)
  song.md[opt1, 'decade'] <- '1950s'
  song.md[opt2, 'decade'] <- '1960s'
  song.md[opt3, 'decade'] <- '1970s'
  song.md[opt4, 'decade'] <- '1980s'
  song.md[opt5, 'decade'] <- '1990s'
  song.md[opt6, 'decade'] <- '2000s'
  song.md[opt7, 'decade'] <- '2010s'

  # Save the category for web queries
  song.decade <- song.md[, c('song_id', 'decade')]
  file <- paste(DATADIR, 'song_decade.RData', sep = '')
  save(song.decade, file = file); cat('Saved file:', file, '\n')

  # Undo numbers of the year
  song.md[, 'songs_year'] <- as.character(song.md[, 'songs_year'])

  # Select variables 
  cols <- c('key_confidence', 'loudness', 'tempo',
            'artist_hotttnesss', 'song_key', 'mode_confidence',
            'mean_bars_confidence', 'mean_beats_confidence',
            'mean_segments_loudness_max', 'mean_tatums_confidence',
            'mean_segments_timbre', 'mean_segments_pitches',
            'mean_sections_confidence', 'mean_segments_confidence',
            'mean_segments_start',  'time_signature_confidence',
            'artist_familiarity', 'song_mode', 'song_id', 'songs_year',
            'decade')
  #who <- ! grepl('others', song.md[, 'decade'])
  #decade_only <- song.md[who, cols]
  decade_only <- song.md[, cols]
  
  # Select variables for PCA
  B <- decade_only[, c(1:4, 6:8, 10:12, 14)]
  cc <- complete.cases(B)
  B <- as.matrix(B[cc, ])
  decade <- decade_only[cc, cols]
  Song_ID <- decade[, 'song_id']
  colnames(B) <- c('KEY', 'LOUD', 'TEMPO', 'A.HOTNESS', 'MODE', 'BARS', 'BEATS',
                   'TATUMS', 'TIMBRE', 'PITCH', 'SEGMENT')
  rownames(B) <- Song_ID

  # Select variables in cols
  decade_only <- song.md[, cols]

  ##############################################################################
  # Principal Components Analysis
  # PCA plot
  B.pca <- princomp(scale(B[, 1:11]), scores = TRUE)

  ## Results 
  #B.pca$loadings

  # PCA plot
  colr <- c('#ffd92f', '#8dd3c7', '#33a02c', '#1f78b4', '#e31a1c',
            #'#ff7f00', '#c51b8a')
            '#ff7f00', '#c51b8a', '#ffffff')
  g <- ggbiplot(B.pca, labels = '-', obs.scale = 1, var.scale = 1,
                varname.size = 5, varname.adjust = 3,
                groups = decade[, 'decade'], ellipse = TRUE) + 
       scale_color_manual(name = 'DECADE', values = colr) + 
       xlim(-4.5, 5) + ylim(-4, 5) +
       #xlab('Principal Component 1') + ylab('Principal Component 2') +
       ggtitle('First Two Principal Components of 11 Variables of Each Song')

  ##############################################################################
  # Customize the plot
  # Function to rescale the x & y positions of the lines and labels
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
  #try(grid.edit(gPath(s_id[2]),
  #              x1 = aux(seg$x0, seg$x1, 1), 
  #              y1 = aux(seg$y0, seg$y1, 1),
  #              gp = gpar(col = 'black')))

  # Plot
  png.file <- paste(OUTPUTDIR, 'pca_time.png', sep = '')
  if (! file.exists(png.file)) {
    png(png.file, width = 600, height = 600)
    g
    dev.off()
  }
  cat('Plotted PCA:', png.file, '\n')

  # End script
  end.script(begin = bs, end = Sys.time())
}
# END OF SCRIPT
