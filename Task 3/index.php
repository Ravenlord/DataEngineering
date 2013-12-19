<html>
  <head>
    <title>Mood Visualization of Countries</title>
    <meta charset="utf-8">
  </head>
  <style type="text/css">
    #mood-map {
      height: 500px;
      width: 900px;
    }
  </style>
  <body>
    <h1>Mood Visualization of Countries according to Twitter</h1>
    <p>The moods of the countries in the analysis have been calculated from the contents of roughly 100,000 tweets, crawled on December, 5th 2013.</p>
    <p>Words and their positive or negative meaning were analyzed and rated. The final score was aggregated for each country in the dataset.</p>
    <p>In total 100,000 tweets from 43 countries have been rated and visualized in the chart below.</p>
    <div id="mood-map"></div>
    <script type='text/javascript' src='https://www.google.com/jsapi'></script>
    <script type="text/javascript">
      google.load("visualization", "1", {"packages": ["geochart"]});
      google.setOnLoadCallback(drawMoodMap.bind(this));
      var data = [ ["Country", "Mood"]<?php
        $cursor = (new MongoClient())->selectDB("test")->selectCollection("sentiment_country")->find();
        foreach ($cursor as $doc) {
          echo ", ['{$doc["_id"]}', {$doc["value"]}]";
        }
      ?> ];

      var min = Infinity;
      var max = 0;
      data.forEach(function (elem) {
        if (elem[1] > max) {
          max = elem[1];
        }
        if (elem[1] < min) {
          min = elem[1];
        }
      });

      function drawMoodMap() {
        var chartData = google.visualization.arrayToDataTable(data);
        var options = {
          colorAxis: {
            colors: [ "red", "white", "green" ],
            values: [ min, 0, max]
          },
          datelessRegionColor: "white"
        };

        var chart = new google.visualization.GeoChart(document.getElementById("mood-map"));
        chart.draw(chartData, options);
      }
    </script>
  </body>
</html>
