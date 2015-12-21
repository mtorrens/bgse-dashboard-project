################################################################################
# Barcelona Graduate School of Economics
# Master's Degree in Data Science
################################################################################
# Project  : Computing Lab
# Script   : 00_index.R
################################################################################
# Author   : Miquel Torrens, 2015.10.18
# Modified : Miquel Torrens, 2015.12.17
################################################################################
# source('/Users/miquel/Desktop/bgse/projects/complab/syntax/00_start.R')
################################################################################

################################################################################
# Generic
source(paste(SCRIPTSDIR, 'functions_generic.R', sep = ''))
source(paste(SCRIPTSDIR, 'functions_google.R', sep = ''))
source(paste(SCRIPTSDIR, 'functions_lyrics.R', sep = ''))
################################################################################

################################################################################
# Load full scripts
# Read raw data
source(paste(SYNTAXDIR, '01_01_load_raw.R', sep = ''))
source(paste(SYNTAXDIR, '01_02_load_usage.R', sep = ''))
source(paste(SYNTAXDIR, '01_03_organize.R', sep = ''))
source(paste(SYNTAXDIR, '01_04_lyrics_setup.R', sep = ''))

# SQL Data upload
source(paste(SYNTAXDIR, '02_upload_sql.R', sep = ''))

# Perform analytics
source(paste(SYNTAXDIR, '03_01_perform_genre.R', sep = ''))
source(paste(SYNTAXDIR, '03_02_perform_evolution.R', sep = ''))
source(paste(SYNTAXDIR, '03_03_perform_lyrics.R', sep = ''))
source(paste(SYNTAXDIR, '03_04_perform_popularity.R', sep = ''))
source(paste(SYNTAXDIR, '03_05_perform_origin.R', sep = ''))
source(paste(SYNTAXDIR, '03_06_perform_recommender.R', sep = ''))

# SQL Results upload
source(paste(SYNTAXDIR, '04_upload_results.R', sep = ''))

# Read results from app
source(paste(SYNTAXDIR, '05_read_results.R', sep = ''))
################################################################################
# END OF SCRIPT
