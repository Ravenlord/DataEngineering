// 2.b

db.tweets.find().count();

db.tweets.mapReduce(
  function () { emit(1, 1); },
  function (key, values) { return Array.sum(values); },
  { out: {inline: 1} }
).results[0].value;

// 2.c

var slang = {};
db.slang.find().forEach(function (elem) {
    slang[elem._id] = elem.value;
});

db.tweets.mapReduce(
  function () {
    this.text.split(/[,.\?\!\-_ ]/).forEach(function (word) {
      if (word.length > 0) {
        word = word.toLowerCase();
        if (slang[word]) {
          slang[word].split(" ").forEach(function (elem) {
            emit(this._id, {
            word: elem,
            coordinates: this.coordinates,
            place: this.place,
            country_code: this.country_code
            }
          );
          }.bind(this));
        }
        else {
          emit(this._id, {
            word: word,
            coordinates: this.coordinates,
            place: this.place,
            country_code: this.country_code
            }
          );
        }
      }
    }.bind(this));
  },
  function (key, values) {
    var words = [];
    values.forEach(function (element) {
      words.push(element.word);
    });
    return {coordinates: values[0].coordinates, country_code: values[0].country_code, place: values[0].place, words: words};
  },
  { out: "tweets_translated", scope: {slang: slang} }
);
