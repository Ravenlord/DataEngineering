# Instructions
1. Clone repository `git clone https://github.com/Ravenlord/DataEngineering.git`
2. Install [PHP](http://php.net/downloads.php)
3. Install [Composer](http://getcomposer.org/download/)
4. Change to Task 3 directory
5. Run `composer update`
6. Rename `crawler.ini.example` to `crawler.ini` and supply Twitter credentials there
7. Change MongoDB database, collection or tweet count in `crawler.php` if necessary
8. Crawl tweets with `php crawler.php`
9. Run the various MapReduce tasks from `2.js` and `3.js` in a MongoDB tool of your choice
10. Start a Webserver
  * in this directory with `php -S localhost:[some port]`
  * or copy `index.php` to the document root of your PHP capable web server
11. Enjoy the chart in your browser ;)

**Note:** If you use different collection names than supplied in the example, please be sure to double check the collection used in the index.php file.

# Result
A screenshot of the resulting mood map is also provided here. 
![Mood Chart](https://raw.github.com/Ravenlord/DataEngineering/master/Task%203/mood-chart.png)
