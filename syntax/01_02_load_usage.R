################################################################################
# Barcelona Graduate School of Economics
# Master's Degree in Data Science
################################################################################
# Project  : Computing Lab
# Script   : 01_02_load_usage.R
################################################################################
# Author   : Miquel Torrens, 2015.10.28
# Modified : Miquel Torrens, 2015.11.06
################################################################################
# source('/Users/miquel/Desktop/bgse/projects/complab/syntax/00_start.R')
# source(paste(SYNTAXDIR, '01_02_load_usage.R', sep = ''))
################################################################################

################################################################################
main.01.02 <- function() {
################################################################################
  # Print starting time
  bs <- begin.script(paste('[', PROJECT, '] 01_02_load_usage.R', sep = ''))

  # Find out which files need to be loaded
  file <- paste(INPUTDIR, 'train_triplets.txt', sep = '')
  usage <- read.table(file = file); cat('Loaded file:', file, '\n')

  # Tidying up
  colnames(usage) <- c('user', 'song', 'play_count')
  rownames(usage) <- NULL

  # Save
  save(usage, file = paste(DATADIR, 'usage_data.RData', sep = ''))
  cat('Saved file:', paste(DATADIR, 'usage_data.RData', sep = ''), '\n')

  file <- paste(INPUTDIR, 'mxm_dataset_train.txt', sep = '')
  lyrics <- readLines(file); cat('Loaded file:', file, '\n')

  # Save
  warning('TO DO: Break down lyrics object\n')
  save(lyrics, file = paste(DATADIR, 'lyrics_data.RData', sep = ''))
  cat('Saved file:', paste(DATADIR, 'lyrics_data.RData', sep = ''), '\n')

  # Means
  if (FALSE) {
    aux1 <- tapply(usage[, 'play_count'], usage[, 'song'], FUN = sum)
    aux2 <- tapply(usage[, 'play_count'], usage[, 'user'], FUN = sum)
    head(aux1[order(aux1, decreasing = TRUE)])
    head(aux1[order(aux1, decreasing = FALSE)])

    saux1 <- aux1[order(aux1, decreasing = TRUE)]
    hist(saux1[1:100])
    hist(log(saux1[1:100]))
    plot(cumsum(saux1))
    plot(density(aux1[aux1 < 1000]))
    plot(density(aux1[aux1 < 100]))
    table(aux1[aux1 < 100])
    table(aux1[aux1 < 1000])
    hist(aux1[aux1 < 100])
    hist(aux1[aux1 < 1000])

    saux2 <- aux2[order(aux2, decreasing = TRUE)]
    hist(saux2[1:100])
    hist(saux2[1:1000])
    hist(log(saux2[1:100]))
  }

  # End
  end.script(begin = bs, end = Sys.time())
}
# END OF SCRIPT
