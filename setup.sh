#!/bin/bash

# Installion script
cmd=$1
user=`grep user: input/mysql_conn.conf | cut -f2 -d' '`
pswd=`grep password: input/mysql_conn.conf | cut -f2 -d' '`

target_dir='/var/www/html'

case $cmd in

install)
  echo "Installing... "

  # Run MySQL script
  mysql -u $user -p$pswd < syntax/data_structure.sql
  
  # Run R scripts
  Rscript syntax/00_start.R pwd install
  
  # Create the App folder
  mkdir -p "$target_dir/music_app"
  cp -rf web/* "$target_dir/music_app"
  echo "Done!"
  ;;

uninstall)
  echo "Uninstalling... "

  # Erase database from MySQL
  mysql -u $user -p$pswd -e "DROP DATABASE omsong;"

  # Erase thins on App
  rm -rf "target_dir/music_app"
  echo "Done!"
  ;;

run)
  echo "Running..."

  # Run MySQL script
  mysql -u $user -p$pswd < syntax/results_framework.sql

  # Run R scripts
  Rscript syntax/00_start.R pwd analysis
  #Rscript syntax/00_start.R pwd run

  # Web plots
  cp output/pca_genre.png "$target_dir/music_app"
  cp output/pca_time.png "$target_dir/music_app"
  cp output/country_map.png "$target_dir/music_app"
  cp output/europe_map.png "$target_dir/music_app"
  cp output/point_map.png "$target_dir/music_app"
  cp output/wordcloud.png "$target_dir/music_app"
  ;;

webupdate)
  echo "Updating... "

  # Copying new stuff for the website
  cp -rf web/* "$target_dir/music_app"

  # Web plots
  cp output/pca_genre.png "$target_dir/music_app"
  cp output/pca_time.png "$target_dir/music_app"
  cp output/country_map.png "$target_dir/music_app"
  cp output/europe_map.png "$target_dir/music_app"
  cp output/point_map.png "$target_dir/music_app"
  cp output/wordcloud.png "$target_dir/music_app"  
  cp output/popularity_model.png "$target_dir/music_app"  

  echo "Done!"
  ;;

*)
  echo "Unknown Command!"

esac
