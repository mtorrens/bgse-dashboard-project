<?php ?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">
<html>
<head>
	<title>music_app</title>    
	<link rel="stylesheet" type="text/css" href="style.css" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <link rel="stylesheet" href="bootstrap/css/bootstrap.css" type="text/css">
  <link rel="stylesheet" href="bootstrap/css/bootstrap-responsive.css" type="text/css">
  <link rel="stylesheet" href="themes/css/prettyPhoto.css" type="text/css">
  <link rel="stylesheet/less" href="themes/css/main.less"/>
  <script src="themes/js/less.js" type="text/javascript"></script>
  <link rel="stylesheet" href="themes/font-awesome/css/font-awesome.min.css">
  <link charset="utf-8" href="//fonts.googleapis.com/css?family=Roboto:100,300,400,500,700" media="screen" rel="stylesheet">
  <link charset="utf-8" href="//fonts.googleapis.com/css?family=Roboto%20Condensed:400" media="screen" rel="stylesheet">
  <script charset="utf-8" src="//www.gstatic.com/external_hosted/modernizr/modernizr.js"></script>
</head>

<body>
	<!-- <div id="header"><h1>Product recommendation and customer analysis</h1></div> -->
	<div id="header"><h1>The Evolution of Music</h1></div>

	<div id="menu">
		<a id="home_link" href="index.php" onclick="show_content('home'); return false;">Home</a> &middot;
		<a id="data_link" href="data.php" class="active" onclick="show_content('data'); update_data_charts(); return false;">Data</a> &middot;
		<a id="analysis_link" href="analytics.php" onclick="show_content('analysis'); return false;">Analytics</a> 
	</div>

	<div id="main">

  <?php

      include 'functions.php';
      $GLOBALS['graphid'] = 0;

      // Load libraries
      document_header();

      // Create connection
      $link = connect_to_db();
    ?>
    <div id="data">
  
    <h2>Data description</h2>
    
    <p>Below we provide the description of the most relevant and discriminant technical variables that we used in our analyses:</p>
    
    <ul style="list-style-type:circle">
      <li><b>Key.</b> Measured as the estimated overall key of a track. Specifically, key is what identifies the tonic triad of the song. Tonic pertains to the first note of a scale, while triad is defined as a chord consisting of 3 notes.</li>
      <li><b>Loudness.</b> Measured as the overall loudness in decibels, which is averaged across the entire track.</li>
      <li><b>Tempo.</b> Measured as the estimated overall tempo of a track in beats per minute.  In its simplest term, tempo can be defined as speed of a given piece.</li>
      <li><b>Mode.</b> Measured as confidence of mode estimation. Specifically, mode refers to the type of scale from which a song’s melodic content is derived.</li>
      <li><b>Beat.</b> Measured as list of beat markers in seconds. Beat is a basic time unit of a piece of music. For example; each tick.</li>
      <li><b>Bar.</b> Measured as list of bar markers in seconds. Bar is a segment of time defined as a given number of beats.</li>
      <li><b>Tatum.</b> Measured as list of tatum markers in seconds. Specifically, tatum is the lowest regular pulse train that a listener intuitively infers from the timing of perceived musical events. For example, a time quantum.</li>
      <li><b>Timbre.</b> Timbre is the quality of musical note that distinguishes different type of musical instruments or voices.</li>
      <li><b>Pitch.</b> A value between 0 to 1 describing the relative dominance of every pitch in the chromatic scale.</li>
      <li><b>Segment.</b> A set of sound entities (typically under a second) each relatively uniform in timbre and harmony. It includes timbre, pitch and loudness.</li>
      <li><b>Artist Hotness.</b> Measure of how popular in terms of buzz the artist of the song is.</li>
      <li><b>Artist familiarity.</b> Measure of how well-known the artist of the song is, which does not necessarily mean how much the artist is listened to.</li>
    </ul>

    <h2>Data visualization</h2>
  
    <p>In this section we carry out an initial analysis on how the data is like. Especially, we display aspects of the metadata of the songs, rather than technical features, which are not very intuitive.</p>
  
    <p>To start with, we show the results of the classification of songs to aggregated genres. We classified songs to a specific genre based on an extensive list of tags that users assign to each song. The histogram below shows the frequency of each genre. As expected, rock is the most frequent genre as it is the most heterogenous in tags, covering a wide spectrum of sub-genres. Unfortunately not all songs are assigned a genre, given that not all of them were tagged by users at a song level or at artist level.</p>

  <?php
      // Total Revenue by product
    
      $query = "SELECT genre_category, COUNT(*) FROM omsong.song_genre_decade WHERE genre_category IS NOT NULL GROUP BY genre_category;";
      $title = "Distribution of songs by classified genre";
      query_and_print_graph($query,$title, "Total amount");
  ?>
  
    <p>We also show how these songs are distributed over decades. There is a clear rise of music production through time, as we observe that music cumulates in the most recent years. The current decade has a small number because the data set has songs only until 2010. Again, not all songs are assigned a year of production so the 10,000 are not represented in the following graph.</p>
  
  <?php
    // Page body. Write here your queries
  
    $query = "SELECT decade, COUNT(*) FROM omsong.song_genre_decade WHERE decade IS NOT NULL GROUP BY decade;";
    $title = "Distribution of songs by decade";
    query_and_print_graph($query,$title,"Euros");
  ?>

    <h3>Origin of the artists</h3>

    <p>Most of the songs were endowed with a text description of the location of the artist, which we used to geolocate where their music was produced using the Google Maps API. As a result, below there is a point map of the location of all artists, which will be further analysed to determine concentration of music across time.</p>
  
    <center><img src="point_map.png" style="width: 70%"></center>

    <h3>Text analysis</h3>

    <p>Below we show a wordcloud of the songs for which we have been able to obtain the lyrics in a bag of words format. The wordcloud shows us the most frequent words occurring in the lyrics of the songs. We are not surprised that "love" is among the most frequent words used in songs. After removing the corresponding stopwords and keeping only those lyrics in English, we obtain the following picture:</p>
  
    <center><img src="wordcloud.png" style="width: 40%"></center>

    <p> In the next tab, we take this analysis further by performing statistical analyses that will help us disentangle the composistion of our songs.</p>

    </div>
	
  </div>

</body>
