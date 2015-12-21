################################################################################
# Barcelona Graduate School of Economics
# Master's Degree in Data Science
################################################################################
# Project  : Computing Lab
# Script   : 00_start.R
################################################################################
# Author   : Miquel Torrens, 2015.10.18
# Modified : Miquel Torrens, 2015.12.17
################################################################################
# source('/Users/miquel/Desktop/bgse/projects/complab/syntax/00_start.R')
################################################################################

################################################################################
# Read command line arguments
args <- commandArgs(trailingOnly = TRUE)
if (length(args) == 0) { args <- NA }
if (length(args) == 1) { args <- c(args, 'empty') }
if (length(args) == 2) { args <- c(args, 'empty') }

# Root path
if (is.na(args[1]) || .Platform['OS.type'] != 'unix') {
  PATH <- '/home/ubuntu/project/'
  #PATH <- '/Users/miquel/Desktop/bgse/projects/complab/'
} else {
  PATH <- paste(system(toString(args[1]), intern = TRUE), '/', sep = '')
}

# Project Name
PROJECT <- 'DS16T1.CL&DW_PROJECT'
################################################################################

################################################################################
# Define relative Paths
DOCDIR <- paste(PATH, 'doc/', sep = '')
DATADIR <- paste(PATH, 'data/', sep = '')
TEMPDIR <- paste(PATH, 'temp/', sep = '')
INPUTDIR <- paste(PATH, 'input/', sep = '')
OUTPUTDIR <- paste(PATH, 'output/', sep = '')
SYNTAXDIR <- paste(PATH, 'syntax/', sep = '')
SCRIPTSDIR <- paste(SYNTAXDIR, 'scripts/', sep = '')

# Create folders
try(dir.create(PATH, showWarnings = FALSE))
try(dir.create(DOCDIR, showWarnings = FALSE))
try(dir.create(DATADIR, showWarnings = FALSE))
try(dir.create(TEMPDIR, showWarnings = FALSE))
try(dir.create(INPUTDIR, showWarnings = FALSE))
try(dir.create(OUTPUTDIR, showWarnings = FALSE))
try(dir.create(SYNTAXDIR, showWarnings = FALSE))
try(dir.create(SCRIPTSDIR, showWarnings = FALSE))

# Project Index
source(paste(SYNTAXDIR, '00_index.R', sep = ''))
################################################################################

################################################################################
# Settings
# Check R version
check.version(dev.R = '3.2.2 x86_64')

# Print starting time
bs <- begin.script(script = paste('[', PROJECT, '] 00_start.R', sep = ''))

# Packages needed
load.packages(pkgs = c('data.table', 'RMySQL', 'gdata', 'RCurl', 'RJSONIO',
                       'rgdal', 'sp', 'maptools', 'rworldmap',  'RColorBrewer',
                       'classInt', 'forecast', 'ineq', 'devtools', 'plyr',
                       'wordcloud', 'tm', 'grid'))#, 'tidyr'))

# Special package
if (! require(ggbiplot)) {
  install_github('vqv/ggbiplot')
  cat('Installed package (from github): ggbiplot\n')
}
library(ggbiplot); cat('Library: ggbiplot\n')

# Stone parameters
today <- format(Sys.time(), '%Y%m%d')

# CRS
CRS_GOOGLE <- CRS('+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs')
################################################################################

################################################################################
# Execute if necessary
f0101a <- paste(DATADIR, 'song_database.RData', sep = '')
f0102a <- paste(DATADIR, 'lyrics_data.RData', sep = '')
f0102b <- paste(DATADIR, 'usage_data.RData', sep = '')
f0103a <- paste(DATADIR, 'song_metadata.RData', sep = '')
f0103b <- paste(DATADIR, 'song_analysis.RData', sep = '')
f0103c <- paste(DATADIR, 'song_guide.RData', sep = '')
f0104a <- paste(DATADIR, 'clean_lyrics.RData', sep = '')

if (args[2] == 'install') {
  if (args[3] == 'force' || ! file.exists(f0101a)) { main.01.01() }
  if (args[3] == 'force' || ! file.exists(f0102a)) { main.01.02() }
  if (args[3] == 'force' || ! file.exists(f0103a)) { main.01.03() }
  if (args[3] == 'force' || ! file.exists(f0104a)) { main.01.04() }
  main.02()
} else if (args[2] == 'analysis') {
  main.03.01()
  main.03.02()
  main.03.03()
  main.03.04()
  main.03.05()
  main.03.06()
  main.04()
}

# Record
end.script(begin = bs, end = Sys.time()); rm(bs)
################################################################################
# END OF SCRIPT
