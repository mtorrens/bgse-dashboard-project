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
		<a id="data_link" href="data.php" onclick="show_content('data'); update_data_charts(); return false;">Data</a> &middot;
		<a id="analysis_link" href="analytics.php" class="active" onclick="show_content('analysis'); return false;">Analytics</a> 
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

	<div id="analysis">
	<h2>Genre differentiation</h2>
	
	<p>We ran <b>Principal Components Analysis</b> (PCA) on selected significant technical features of each song. The principal components take these technical features into account and plot them in lower dimensional space to see how they correlate: how each genre lie in this space, whether they are grouped together or are distinctly different from other genres. We found that songs from different genres do have their distinct features that define them. However, they also intersect among songs across genres.</p>
		
  <center><img src="pca_genre.png" style="width: 50%"></center>
	
	<h2>Time evolution</h2>
	
	<p>We replicated the PCA analysis as with genre by aggregating the data per decade this time. We plot the same principal components that rely on the technical features but we group the points according to time instead. We find no major distinct difference among music produced over time.</p>
		
  <center><img src="pca_time.png" style="width: 50%"></center>

	<h2>Predicting song popularity</h2>
	
	<p>We ran a <b>log-linear OLS model</b> on the play count of each of the songs to understand which features affect the number of times a song is listened to, as a proxy measure for popularity. Play count could be Poisson distributed but given its large values we can linearize it using logs. We included the most discriminant features analysed from a wide range of potential variables, most of which were directly insignificant. Given that we work with a subset of 10,000 songs and that most of them are incomplete cases, excess of significance was not an issue and so penalized regression methods were not required. We also standardised numerical features (except years since publication) given the difference in their nature to diminish correlation between the parameters and for easier interpretation.</p>

	<p>The results are shown in the table below. We can observe that the heaviest determinants of popularity seems to be loudness, beats and, obviously, artist hotness. These variables positively affect the play count. On the other hand, pitches, timbre and possibly sections affect negatively, approximately in the same proportion and with a smaller effect than the previous variables. It is also interesting to point out that the number of years since publication affects positively in large measure because they have been in the market for a longer time. So, there is a better and longer knowledge of them. Finally, also point out that the dummy variables that define the genre to which the song belongs does not seem to have an effect on popularity. None of them are significant, so genre does not seem to be a factor in determining popularity.</p>
		
  <center><img src="popularity_model.png" style="width: 40%"></center>

	<h2>Analysing music origins</h2>
	
  <p>We used Google Maps API to <b>geolocate</b> each of the songs and computed the country of origin with their coordinates. We then aggregated the data per country and decade and computed the Herfindahl index for each decade until 2000s.</p>

  <center><img src="country_map.png" style="width: 80%"></center>

  <p>Additionally, we used elementary <b>time series</b> analysis to predict the music production of the current decade to observe the tendency of the concentration of music. During the last century the concentration had the tendency to go down but currently it seems to be on the rise again.

  <?php
    // Most sold product pairs
    $title = "Distribution of songs across Top 10 countries and decades, with Herfindahl index on top";
    $query = "SELECT country, fifties, sixties, seventies, eighties, nineties, two_thousands, twenty_tens FROM omsong.world_production ORDER BY rank LIMIT 10;";
    query_and_print_table($query, $title);
  ?>

	<h2>Recommender system</h2>

  <p>A series of artists are assigned to each artist, those for which enough users that listen to both artists. The recommender system then calculates the <b>Mahalanobis distance</b> on the technhical feature space between the selected song and the songs for the artists on the song's artist list. Then we rank these distances and show the closest five if they are close enough.</p>

	<p>Just give it a try!</p>
		
    <form name="search" method="POST" action="analytics.php" align = "center">

      <select name="song_id">
        <option value="">--Select Song--</option>
        <?php
        $sql=mysql_query("SELECT * FROM omsong.song_metadata ORDER BY artist_name;");
        while($row=mysql_fetch_array($sql)) {
          echo '<option value="'.$row['song_id'].'">'.substr($row['artist_title'],0,100).'</option>';
        }
        ?>
      </select>
      <input type="submit" name="submit" value="Submit">
    </form>
  
    <?php
    
      if (isset($_POST['submit'])) {

        $query3="SELECT artist_title FROM omsong.song_metadata WHERE song_id = ";
        $query3 .= "'".$_POST['song_id']."';";
        $sql2=mysql_query($query3);
        $sql3=mysql_fetch_array($sql2);

        $title2 = "Recommended results for:";
        $title2 .= " ".$sql3['artist_title'];
        //$title2 .= " ".$_POST['artist_title']."blabla";
        $query2 = "SELECT rank, recommended_artist, recommended_song, album FROM omsong.results_recommender WHERE song_id = ";
        $query2 .= "'".$_POST['song_id']."' ORDER BY rank;";

        query_and_print_table($query2,$title2);
      
      } 
  
    ?>

		</div>
		
<?php
	// Close connection
	mysql_close($link);
?>

  </div>

</body>
