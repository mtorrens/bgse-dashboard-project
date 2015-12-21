################################################################################
# Barcelona Graduate School of Economics
# Master's Degree in Data Science
################################################################################
# Project  : Computing Lab
# Script   : 01_04_lyrics_steup.R
################################################################################
# Author   : Balint Van, 2015.12.17
# Modified : -
################################################################################
# source('/Users/miquel/Desktop/bgse/projects/complab/syntax/00_start.R')
# source(paste(SYNTAXDIR, '01_04_lyrics_setup.R', sep = ''))
################################################################################

################################################################################
main.01.04 <- function() {
################################################################################
  # Print starting time
  bs <- begin.script(paste('[', PROJECT, '] 01_04_lyrics_setup.R', sep = ''))

  # Load in the lyrics data
  file <- paste(DATADIR, 'lyrics_data.RData', sep = '')
  lyrics <- get(load(file = file)); cat('Loaded file:', file, '\n')

  # Cut the top of the file, which is the description of the content
  lyrics.head <- lyrics[1:18]
  words <- unlist(strsplit(lyrics.head[18], ','))
  words <- words[-1]
  lyrics <- tail(lyrics, -18)

  # Splitting up the vectors by comma 
  lyrics <- sapply(lyrics, strsplit, ',')
  names(lyrics) <- 1:length(lyrics)

  # Extracting track ids from the lyrics data
  song.ids <- sapply(lyrics, function(x) { x[1] })

  # Unpacking the whole lyrics data set
  lyrics <- llply(lyrics, lyrics2df)
  lyrics <- as.data.frame(data.table::rbindlist(lyrics))
  #lyrics <- do.call(rbind, lyrics)
  rownames(lyrics) <- NULL
  names(lyrics) <- c('song_id', 'word_index', 'word_count')

  # Load the 10,000 songs
  file <- paste(DATADIR, 'song_metadata.RData', sep = '')
  song.md <- get(load(file = file)); cat('Loaded file:', file, '\n')
  sample.lyrics <- lyrics[song.ids %in% song.md[, 'track_id'], ]
  rm(lyrics); gc()

  # Processing the lyrics data to a nice format
  names(sample.lyrics) <- c('song_id', 'word_index', 'word_count')
  sample.lyrics[, 'word_index'] <- as.integer(sample.lyrics[, 'word_index'])
  sample.lyrics[, 'word_count'] <- as.integer(sample.lyrics[, 'word_count'])

  # Save results
  file <- paste(DATADIR, 'clean_lyrics.RData', sep = '')
  save(sample.lyrics, words, file = file); cat('Saved file:', file, '\n')
  
  # End
  end.script(begin = bs, end = Sys.time())
}
# END OF SCRIPT
