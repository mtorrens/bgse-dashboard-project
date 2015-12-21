################################################################################
# Barcelona Graduate School of Economics
# Master's Degree in Data Science
################################################################################
# Script   : functions_google.R
# Descrip. : functions to query Google
################################################################################
# Author   : (c) Miquel Torrens, 2015.11.24
# Modified :     -
################################################################################

################################################################################
# Function list
# 1. geolocate()
################################################################################

################################################################################
google.geolocate <- function(text = NULL, english = TRUE, dir = NULL) {
# (c) Miquel Torrens, 2015.11.24
# Query Google API to geolocate from text
################################################################################
  # Recording current time
  require(RCurl)
  require(RJSONIO)

  # Proper form
  new.text <- trim(gsub('[[:punct:]]', '', text))
  new.text <- gsub(' ', '+', new.text)
  new.text <- gsub('\\t', '', new.text)

  # Build URL
  txt1 <- 'http://maps.googleapis.com/maps/api/geocode/json?address='
  txt2 <- '&language=en'
  if (english == TRUE) {
    url <- paste(txt1, new.text, txt2, sep = '')
  } else {
    url <- paste(txt1, new.text, sep = '')
  }

  # Query Google Maps API
  dwl <- RJSONIO::fromJSON(RCurl::getURL(url = url))

  # Return the result
  return(dwl)
}
# END OF SCRIPT
