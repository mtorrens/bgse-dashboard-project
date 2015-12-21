BGSE Dashboard Project: The Evolution of Music
==============================================

Overview
--------

This project implements exploration of music evolution and differences in music genre using Principal Component Analysis (PCA) as well as exploration of origin and popularity of songs using log-linear OLS model. The project also comprises a music recommender system based on Mahalanobis distance of the technical features of a selected song.

The objectives of the project are:
  * Explore differences in various music genres and in music produced over time using PCA.
  * Explore change in the concentration or sparsity of music production across the world and over time. 
  * Investigate key built-in features that contribute to the popularity of a song.
  * Develop a music recommender system that suggests five closest candidate songs, ranked based on their Mahalanobis distance of the technical features of a selected song.

The ultimate goal is to use the technical features of the song to determine how similar or different songs are in their selected dimensions over time, across genre and origins. 

Implementation
--------------

The 'Data' tab includes two histograms of that shows the frequency of songs by their genre and by decade. Note that the graph is generated dynamically each time the web page is loaded. It also includes a point map that geolocates the origins of music production using Google Maps API. Finally, it consists of a wordcloud of songs for which we obtain the lyrics in a bag of words format for most frequently used words in the lyrics of the songs.

In the analytics part we can examine the different results of our analyses.

To run the Principal Components Analysis, we chose selected significant technical features of each songs and plot their principal component on lower dimensional space to see how they correlate. 

To develop the log-linear OLS model on the play count of each of the songs, we examined which features affect the number of times a song is listened to as a proxy measure for popularity. We identified the most discriminant features from a wide range of variables and standardized them to diminish correlation between the parameters and for easier interpretation. 

To develop the music recommendation system we have used the Mahalanobis distance. The user can test the recommender system online. The web will print in real time the results recommended for the song that the user selects.

Installing the project
----------------------

*Warning:* this project cannot be run cloning this directory because the size of the data does not allow storing it online at this point. Please contact the [authors](mailto:niti.mishra@barcelonagse.eu,miquel.torrens@barcelonagse.eu,balint.van@barcelonagse.eu) for access to the data.

Once the data is stored, it is necessary to adapt user, password and host for the MySQL connection in the configuration file in the input folder, as well as in the connection in the .php file. Afterwards, run the following commands inside the project’s folder:

`bash setup.sh install`

`bash setup.sh run`

Permissions to necessary folders may need to be granted before running the project.

Required packages
-----------------

The R analysis relies on the following packages:

  * `data.table`
  * `RMySQL`
  * `gdata`
  * `RCurl`
  * `RJSONIO`
  * `rgdal`
  * `sp`
  * `maptools`
  * `rworldmap`
  * `RColorBrewer`
  * `classInt`
  * `forecast`
  * `ineq`
  * `devtools`
  * `plyr`
  * `wordcloud`
  * `tm`
  * `grid`
  
Acknowledgments
---------------

This project is based on code by: Guglielmo Bartolozzi, Christian Brownlees,  Niti Mishra, Miquel Torrens and Bálint Ván.

