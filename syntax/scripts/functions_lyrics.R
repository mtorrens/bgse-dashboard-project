################################################################################
# Barcelona Graduate School of Economics
# Master's Degree in Data Science
################################################################################
# Script   : functions_lyrics.R
# Descrip. : functions to maniuplate the text of the lyrics
################################################################################
# Author   : Balint Van, 2015.12.17
# Modified : -
################################################################################

################################################################################
# Function list
# 1. lyrics2df()
################################################################################

################################################################################
lyrics2df <- function(song) {
# This function takes a character vector about the lyrics of a song in a
# bag-of-words format where an element of a vector looks like this: "34:2"
# and spits out a data frame.
################################################################################
  out <- cbind(song[1], ldply(strsplit(song[-(1:2)], ':')))
  return(out)
}
# END OF SCRIPT
