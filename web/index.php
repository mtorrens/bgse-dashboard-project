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
<script>
/**
 * Given an element, or an element ID, blank its style's display
 * property (return it to default)
 */
function show(element) {
    if (typeof(element) != "object")	{
	element = document.getElementById(element);
    }
    
    if (typeof(element) == "object") {
	element.style.display = '';
    }
}

/**
 * Given an element, or an element ID, set its style's display property
 * to 'none'
 */
function hide(element) {
    if (typeof(element) != "object")	{
	element = document.getElementById(element);
    }
    
    if (typeof(element) == "object") {
	element.style.display = 'none';
    }
}

function show_content(optionsId) {
	var ids = new Array('home','data','analysis');
	show(optionsId);
	document.getElementById(optionsId + '_link').className = 'active';

	for (var i = 0; i < ids.length; i++)
	{
	    if (ids[i] == optionsId) continue;
	    hide(ids[i]);
	    document.getElementById(ids[i] + '_link').className = '';
	}
}
</script>
<body>
	<!-- <div id="header"><h1>Product recommendation and customer analysis</h1></div> -->
	<div id="header"><h1>The Evolution of Music</h1></div>

	<div id="menu">
		<a id="home_link" href="index.php" class="active" onclick="show_content('home'); return false;">Home</a> &middot;
		<a id="data_link" href="data.php" onclick="show_content('data'); update_data_charts(); return false;">Data</a> &middot;
		<a id="analysis_link" href="analytics.php" onclick="show_content('analysis'); return false;">Analytics</a> 
	</div>

	<div id="main">

		<div id="home">
			<h2>Our challenge</h2>
			
      <p> Music is a worldwide phenomenon that has changed completely throughout the 20<sup>th</sup> century. With globalization, music has evolved at the speed of light in a very short amount of time. Understanding this evolution in terms of time, genre, origin and popularity of the music that is being produced is a very complex task that we begin to approach with this project. </p>

      <p> To do that, we exploit the data from the <i><a href="http://labrosa.ee.columbia.edu/millionsong/">Million Song Dataset</a> </i>, which contains audio features, analysis and metadata of one million songs in the 20<sup>th</sup> and 21<sup>st</sup> centuries, all of them provided by <i><a href="http://the.echonest.com/">The Echo Nest</a> </i>, a music intelligence and data platform for developers and media companies.  We worked with a representative subset of 10,000 songs made available on their website for smaller sized experiments. With this data we mainly wanted to cross-examine relationships between the interest variables to explore music evolution over time, differences in music genres, and origins and popularity of music.</p>
			
      <ol>
        <li><b>Genre differentiation.</b> We aimed to look at the differences in the internal built of music belonging to different genres.</li>
        <li><b>Time evolution.</b> We aimed to find out how music has evolved over time.  We hoped to spot significant differences in music variables from music produced over different decades.</li>
        <li><b>Music Origin.</b> We explored where music is being produced and whether there is concentration or sparsity of music production across the world.</li>
        <li><b>Song popularity.</b> We also aimed to find which key built-in features contribute to a song's popularity.</li>
        <li><b>Recommender system.</b> We developed a music recommender system such that songs and bands that have similar features are clustered to suggest near neighbors as possible favored candidates for a song that a user selects.</li>
      </ol>
      
      <h2>Our solution</h2>
      
      <p>The vast information contained in each song is examined and the selected features and metadata are extracted to perform a series of statistical analyses. The key part of the project is devoted to using the technical features of the song to determine how close are our songs in the selected dimensions. With that, we can cluster them and extract the most relevant information, which lead us to surprising and interesting results.</p>
      
      <p>In the following tabs there is a detailed description of the data we have used and the different analyses performed and results obtained to better understand each of the points above stated.</p>
      
      <p>We hope you enjoy it! :)</p>
			
		</div>	

	</div>

	<div id="footer">Project team: Niti Mishra, Miquel Torrens and Bálint Ván</div>

</body>
</html>
<?php ?>
