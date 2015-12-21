################################################################################
# Barcelona Graduate School of Economics
# Master's Degree in Data Science
################################################################################
# Project  : Computing Lab
# Script   : 01_03_organize.R
################################################################################
# Author   : Miquel Torrens, 2015.10.26
# Modified : Miquel Torrens, 2015.11.08
################################################################################
# source('/Users/miquel/Desktop/bgse/projects/complab/syntax/00_start.R')
# source(paste(SYNTAXDIR, '01_03_organize.R', sep = ''))
################################################################################

################################################################################
main.01.03 <- function() {
################################################################################
  # Print starting time
  bs <- begin.script(paste('[', PROJECT, '] 01_03_organize.R', sep = ''))

  ##############################################################################
  # Loading full database
  file <- paste(DATADIR, 'song_database.RData', sep = '')
  dbase <- get(load(file = file)); cat('Loaded file:', file, '\n')

  # Key parameters
  guide <- dbase[[7621]]
  dbase <- dbase[c(1:7620, 7622:length(dbase))]
  n <- length(dbase)
  nf <- format(n, big.mark = ',')

  # Decompose the data (for tractability)
  analysis <- vector(mode = 'list', length = n)
  metadata <- vector(mode = 'list', length = n)
  msbrainz <- vector(mode = 'list', length = n)
  for (i in 1:n) {
    iff <- format(i, big.mark = ',')
    cat('\rDecomposing database information:', iff, 'of', nf)
    analysis[[i]] <- dbase[[i]]['analysis']
    metadata[[i]] <- dbase[[i]]['metadata']
    msbrainz[[i]] <- dbase[[i]]['musicbrainz']  
    if (i == n) { cat(' [Done!]\n') }
  }

  ##############################################################################
  # Analysis information
  an1 <- vector(mode = 'list', length = n)
  an2 <- data.frame(matrix(nrow = n, ncol = 31 + 15 + 15))
  colnames(an2) <- colnames(analysis[[1]][[1]]['songs'][[1]])
  for (i in 1:n) {
    iff <- format(i, big.mark = ',')
    cat('\rTransforming song analysis information:', iff, 'of', nf)
    an1[[i]] <- analysis[[i]][[1]][c(1:13, 15:16)]
    an2[i, 1:31] <- analysis[[i]][[1]]['songs'][[1]]
    an2[i, 32:46] <- sapply(1:15, function(x) {
      mean(an1[[i]][[x]], na.rm = TRUE)
    })
    an2[i, 47:61] <- sapply(1:15, function(x) {
      sd(an1[[i]][[x]], na.rm = TRUE)
    })
    if (i == n) { cat(' [Done!]\n') }
  }
  colnames(an2) <- c(colnames(analysis[[1]][[1]]['songs'][[1]]),
                     paste('mean', names(an1[[1]]), sep = '_'),
                     paste('sd', names(an1[[1]]), sep = '_'))

  ##############################################################################
  # Metadata information
  md <- data.frame(matrix(nrow = n, ncol = 20 + 4))
  colnames(md) <- c(colnames(metadata[[2]][[1]][5][[1]]),
                    'artist_terms', 'artist_terms_freq', 'artist_terms_freq',
                    'similar_artists')
  for (i in 1:n) {
    iff <- format(i, big.mark = ',')
    cat('\rTransforming metadata information:', iff, 'of', nf)
    md[i, 1:20] <- metadata[[i]][[1]][5][[1]]
    md[i, 21] <- paste(unlist(metadata[[i]][[1]][1]), collapse = ', ')
    md[i, 22] <- paste(unlist(metadata[[i]][[1]][2]), collapse = ', ')
    md[i, 23] <- paste(unlist(metadata[[i]][[1]][3]), collapse = ', ')
    md[i, 24] <- paste(unlist(metadata[[i]][[1]][4]), collapse = ', ')
    if (i == n) { cat(' [Done!]\n') }
  }

  ##############################################################################
  # Music Brainz information
  mb <- data.frame(matrix(nrow = n, ncol = 3))
  colnames(mb) <- c('artist_mbtags', 'artist_mbtags_count', 'songs_year')
  for (i in 1:n) {
    iff <- format(i, big.mark = ',')
    cat('\rTransforming Musicbrainz information:', iff, 'of', nf)
    mb[i, 1] <- paste(unlist(msbrainz[[i]][[1]][1]), collapse = ', ')
    mb[i, 2] <- paste(unlist(msbrainz[[i]][[1]][2]), collapse = ', ')  
    #mb[i, 3] <- unlist(msbrainz[[i]][[1]][3])[1]  # Always zero
    mb[i, 3] <- unlist(msbrainz[[i]][[1]][3])[2]
    if (i == n) { cat(' [Done!]\n') }
  }

  # Polishing
  mb[which(mb[, 1] == ''), 1] <- NA
  mb[which(mb[, 2] == ''), 2] <- NA
  mb[which(mb[, 3] == 0), 3] <- NA

  ##############################################################################
  # Usage information
  file <- paste(DATADIR, 'usage_data.RData', sep = '')
  usage <- get(load(file = file)); cat('Loaded file:', file, '\n')
  aggu <- tapply(usage[, 'play_count'], usage[, 'song'], FUN = sum)
  aggc <- tapply(usage[, 'play_count'], usage[, 'song'], FUN = length)

  ##############################################################################
  # Store the important information
  song.an <- an1
  song.md <- cbind.data.frame(an2, md, mb)
  song.md[, 'play_count'] <- aggu[match(song.md[, 'song_id'], names(aggu))]
  song.md[, 'unique_users'] <- aggc[match(song.md[, 'song_id'], names(aggc))]

  # MySQL reserved words violations
  colnames(song.md)[which(colnames(song.md) == 'key')] <- 'song_key'
  colnames(song.md)[which(colnames(song.md) == 'mode')] <- 'song_mode'
  colnames(song.md)[which(colnames(song.md) == 'release')] <- 'release_name'

  # Save the data
  file1 <- paste(DATADIR, 'song_metadata.RData', sep = '')
  file2 <- paste(DATADIR, 'song_analysis.RData', sep = '')
  file3 <- paste(DATADIR, 'song_guide.RData', sep = '')
  save(song.md, file = file1); cat('Saved file:', file1, '\n')
  save(song.an, file = file2); cat('Saved file:', file2, '\n')
  save(guide, file = file3); cat('Saved file:', file3, '\n')

  # End
  end.script(begin = bs, end = Sys.time())
}
# END OF SCRIPT