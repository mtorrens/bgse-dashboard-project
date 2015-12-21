################################################################################
# Barcelona Graduate School of Economics
# Master's Degree in Data Science
################################################################################
# Project  : Computing Lab
# Script   : 03_03_perform_lyrics.R
################################################################################
# Author   : Balint Van, 2015.12.17
# Modified : -
################################################################################
# source('/Users/miquel/Desktop/bgse/projects/complab/syntax/00_start.R')
# source(paste(SYNTAXDIR, '03_03_perform_lyrics.R', sep = ''))
################################################################################

################################################################################
main.03.03 <- function() {
################################################################################
  # Print starting time
  bs <- begin.script(paste('[', PROJECT, '] 03_03_perform_lyrics.R', sep = ''))

  # Find out which files need to be loaded
  file1 <- paste(DATADIR, 'song_metadata.RData', sep = '')
  file2 <- paste(DATADIR, 'clean_lyrics.RData', sep = '')
  song.md <- get(load(file = file1)); cat('Loaded file:', file1, '\n')
  lyrics.sample <- get(load(file = file2)); cat('Loaded file:', file2, '\n')

  # Joining tables
  sample.lyrics[, 'word'] <- words[sample.lyrics[, 'word_index']]

  # Removing stop words
  sample.lyrics <- sample.lyrics[! sample.lyrics[, 'word'] %in% stopwords(), ]
  lgs <- c('german', 'french', 'spanish', 'italian')
  for (lg in lgs) {
    chosen <- ! sample.lyrics[, 'word'] %in% stopwords(lg)
    sample.lyrics <- sample.lyrics[chosen, ]  
  }
  
  # Frequency list for every (remaining) word
  all <- ddply(sample.lyrics, 'word', summarise, freq = sum(word_count))
  all <- all[order(all[, 'freq']),]

  # Making wordcloud
  file <- paste(OUTPUTDIR, 'wordcloud.png', sep = '')
  png(file, width = 800, height = 800)
  wordcloud(all[, 'word'], all[, 'freq'],  max.words = 150, scale = c(8, 1),
            colors = brewer.pal(8, 'Dark2'))
  dev.off()
  cat('Written file:', file, '\n')

  # End script
  end.script(begin = bs, end = Sys.time())
}
# END OF SCRIPT
