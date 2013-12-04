<?php
error_reporting(E_ALL);
ini_set("display_errors", 1);
require("vendor/autoload.php");

/**
 * General purpose crawler class for the Twitter streaming API.
 *
 * @author Markus Deutschl <mdeutschl.mmt-m2012@fh-salzburg.ac.at>
 */
class TweetCrawler extends OauthPhirehose {

  private $collection;

  private $batchSize;

  private $maxTweets;

  private $tweetCount = 0;

  private $tweets = [];


  public function __construct($username, $password, $method = Phirehose::METHOD_SAMPLE, $format = self::FORMAT_JSON, $lang = false, $db = "test", $collection = "tweets", $maxTweets = 10000, $batchSize = 1000) {
    parent::__construct($username, $password, $method, $format, $lang);
    $this->maxTweets = $maxTweets;
    $this->batchSize = $batchSize;
    $this->collection = (new MongoClient())->selectDB($db)->selectCollection($collection);
  }

  public function enqueueStatus($status) {
    // Flush the tweets to the database if the batch size is big enough.
    if (!empty($this->tweets) && $this->tweetCount % $this->batchSize === 0 ) {
      $this->collection->batchInsert($this->tweets, [ "continueOnError" => true ]);
      $this->tweets = [];
      $this->log("Flushed {$this->batchSize} tweets to the database!");
    }

    // If we have gathered enough tweets, flush the last tweets to the database and exit.
    if ($this->tweetCount >= $this->maxTweets) {
      if (!empty($this->tweets)) {
        $this->collection->batchInsert($this->tweets, [ "continueOnError" => true ]);
      }
      $this->log("{$this->maxTweets} tweets have been crawled successfully!");
      exit();
    }

    // Decode the JSON data to an associative array.
    $data = json_decode($status, true);
    // Check for all required fields.
    if (is_array($data)
          && isset($data["user"])
          && isset($data["user"]["screen_name"])
          && isset($data["text"])
          && isset($data["geo"])
          && isset($data["geo"]["coordinates"])
          && isset($data["place"])
          && isset($data["place"]["name"])
          && isset($data["place"]["country_code"])
          && isset($data["place"]["country"])
        ) {
      // Push the tweet data to the internal stack.
      $this->tweets[] = [
        "user" => $data["user"]["screen_name"],
        "text" => $data["text"],
        "coordinates" => $data["geo"]["coordinates"],
        "place" => $data["place"]["name"],
        "country_code" => $data["place"]["country_code"],
        "country" => $data["place"]["country"],
      ];
      $this->tweetCount++;
    }
  }
}

// Check if the configuration file is readable.
if (!is_readable("crawler.ini")) {
  exit("Please supply a crawler.ini file next to the crawler.php!" . PHP_EOL);
}

// Parse the necessary options.
$options = parse_ini_file("crawler.ini");
// Check if we have all options needed.
if ($options === false
      || !isset($options["consumer_key"])
      || !isset($options["consumer_secret"])
      || !isset($options["oauth_token"])
      || !isset($options["consumer_secret"])
    ) {
  exit("Missing configuration options in crawler.ini! Please supply consumer_key, consumer_secret, oauth_token and oauth_secret." . PHP_EOL);
}

$crawler = new TweetCrawler($options["oauth_token"], $options["oauth_secret"], Phirehose::METHOD_FILTER);
// Set consumer key and secret for the Twitter app.
$crawler->consumerKey = $options["consumer_key"];
$crawler->consumerSecret = $options["consumer_secret"];
// Only crawl tweets with a geolocation and in the English language.
$crawler->setLocations([[-180, -90, 180, 90]]);
$crawler->setLang("en");
// Finally consume the Tweet stream.
$crawler->consume();
