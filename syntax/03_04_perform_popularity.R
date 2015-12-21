################################################################################
# Barcelona Graduate School of Economics
# Master's Degree in Data Science
################################################################################
# Project  : Computing Lab
# Script   : 03_04_perform_popularity.R
################################################################################
# Author   : Miquel Torrens, 2015.12.02
# Modified : Miquel Torrens, 2015.12.03
################################################################################
# source('/Users/miquel/Desktop/bgse/projects/complab/syntax/00_start.R')
# source(paste(SYNTAXDIR, '03_04_perform_popularity.R', sep = ''))
################################################################################

################################################################################
main.03.04 <- function() {
################################################################################
  # Print starting time
  script <- paste('[', PROJECT, '] 03_04_perform_popularity.R', sep = '')
  bs <- begin.script(script)

  # Load data
  file <- paste(DATADIR, 'song_metadata.RData', sep = '')
  aux <- load(file = file); cat('Loaded file:', file, '\n')
  song.md <- get(aux[1])
  n <- nrow(song.md)
  fn <- format(n, big.mark = ',')

  # Classified genre
  file <- paste(DATADIR, 'song_genre_category.RData', sep = '')
  aux <- load(file = file); cat('Loaded file:', file, '\n')
  genre <- get(aux[1])

  # Add it
  song.md[, 'new_genre'] <- genre[match(song.md[, 'song_id'], genre[, 1]), 2]

  # Choose the amount of columns
  cols <- c('duration', 'song_key', 'key_confidence', 'loudness', 'song_mode',
            'mode_confidence', 'tempo', 'time_signature', 'artist_hotttnesss',
            'time_signature_confidence', 'mean_bars_confidence',
            'mean_beats_confidence', 'mean_sections_confidence',
            'mean_segments_confidence', 'mean_segments_loudness_max',
            'mean_segments_pitches', 'mean_segments_timbre',
            'mean_tatums_confidence', 'genre', 'song_hotttnesss', 'songs_year',
            'play_count', 'unique_users', 'new_genre')
  
  # Selection of columns  
  df <- song.md[which(! is.na(song.md[, 'play_count'])), cols]

  # Dummies genre
  genres <- c('edm', 'hiphop', 'rock', 'funk', 'jazzblues', 'latin')
  df[, genres] <- 0
  df[which(df[, 'new_genre'] == 'EDM'), 'edm'] <- 1
  df[which(df[, 'new_genre'] == 'F.Hiphop'), 'hiphop'] <- 1
  df[which(df[, 'new_genre'] == 'F.Rock'), 'rock'] <- 1
  df[which(df[, 'new_genre'] == 'Funk'), 'funk'] <- 1
  df[which(df[, 'new_genre'] == 'JazznBlues'), 'jazzblues'] <- 1
  df[which(df[, 'new_genre'] == 'Latin'), 'latin'] <- 1
  df[, 'new_genre'] <- NULL

  # Compute how old songs are
  df[, 'years_old'] <- max(df[, 'songs_year'], na.rm = TRUE) -
                       df[, 'songs_year']
  
  # Standardize some of the features
  cols <- colnames(df)
  kill <- c('genre', 'play_count', 'unique_users', 'songs_year',
            'song_hotttnesss', 'song_mode')
  cols2 <- cols[! cols %in% c(kill, genres, 'years_old')]
  for (col in cols2) {
    #df[, col] <- log(df[, col] + abs(min(df[, col], na.rm = TRUE)) + 0.001)
    df[, col] <- (df[, col] - mean(df[, col], na.rm = TRUE)) /
                  sd(df[, col], na.rm = TRUE)
  }

  # Build a model
  regressors <- paste(c(cols2, genres, 'years_old'), collapse = ' + ')
  form <- as.formula(paste('log(play_count) ~', regressors))
  #form <- as.formula(paste('log(unique_users) ~', paste(cols2, collapse = '+')))

  # Compute linear model
  m01 <- lm(form, data = df)

  # Build a second model
  cols3 <- c('loudness', 'tempo', 'artist_hotttnesss',
             'time_signature_confidence', 'mean_beats_confidence',
             'mean_sections_confidence', 'mean_segments_pitches',
             'mean_segments_timbre', 'years_old', genres)
  form2 <- as.formula(paste('log(play_count) ~', paste(cols3, collapse = '+')))

  # Compute second linear model
  model <- lm(form2, data = df)

  # Save results
  file <- paste(DATADIR, 'popularity_model.RData', sep = '')
  save(model, file = file); cat('Saved file:', file, '\n')

  # End script
  end.script(begin = bs, end = Sys.time())
}
# END OF SCRIPT
