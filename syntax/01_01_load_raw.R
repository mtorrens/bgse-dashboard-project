################################################################################
# Barcelona Graduate School of Economics
# Master's Degree in Data Science
################################################################################
# Project  : Computing Lab
# Script   : 01_01_load_raw.R
################################################################################
# Author   : Miquel Torrens, 2015.10.18
# Modified : Miquel Torrens, 2015.06.11
################################################################################
# source('/Users/miquel/Desktop/bgse/projects/complab/syntax/00_start.R')
# source(paste(SYNTAXDIR, '01_01_load_raw.R', sep = ''))
################################################################################

################################################################################
main.01.01 <- function() {
################################################################################
  # Print starting time
  bs <- begin.script(paste('[', PROJECT, '] 01_01_load_raw.R', sep = ''))

  # Find out which files need to be loaded
  # Execute Linux command: 'find . -print | grep -i ".*[.]h5" > filess.txt'
  txt1 <- 'find '
  txt2 <- ' -print | grep -i ".*[.]h5" > '
  txt3 <- 'list_input_files.txt'
  if (.Platform['OS.type'] == 'unix') {
    cat('Counting number of files to be read... ')
    system(paste(txt1, INPUTDIR, txt2, INPUTDIR, txt3, sep = ''))
    cat('Done!\n')
  } else {
    stop('this project cannot run on Windows.')
  }

  # Obtain the paths of all the files
  aux <- readLines(paste(INPUTDIR, 'list_input_files.txt', sep = ''))
  n <- length(aux)
  nf <- format(n, big.mark = ',')
  cat('Total number of files:', nf, '\n')

  # To read .h5 files we need a non-rcran package
  if (require(rhdf5) == FALSE) {
    source('http://bioconductor.org/biocLite.R')
    biocLite('rhdf5')
    cat('Downloaded package: rhdf5\n')
  }

  # Load the downloaded package
  library(rhdf5); cat('Loaded package: rhdf5\n')

  # Load files
  dbase <- vector(mode = 'list', length = n)
  for (h5file in aux) {
    who <- which(aux == h5file)
    whof <- format(who, big.mark = ',')
    cat('\rReading file: ', whof, ' of ', nf, '... ', sep = '')
    dbase[[who]] <- h5read(h5file, '/')
    if (who == n) { cat('Done!\n') }
  }
  H5close()

  # Save object
  cat('Writing R database...\n')
  file <- paste(DATADIR, 'song_database.RData', sep = '')
  save(dbase, file = file); cat('Saved file:', file, '\n')
  cat('Done!\n')

  # End
  end.script(begin = bs, end = Sys.time())
}
# END OF SCRIPT
