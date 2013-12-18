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
var punctuation = ",;\\.:\\-_#'\\+\\*´`\\?!\"=\\(\\)\\{\\}\\|\\]\\\\~\\\\\\^„“”";
var re = new RegExp("^[" + punctuation + "]*([^" + punctuation + "]+)[" + punctuation + "]*$");


db.tweets.mapReduce(
  function () {
    this.text.split(" ").forEach(function (word) {
      if (word.length > 0) {
        word = word.replace(re,"$1");
        word = word.toLowerCase();
        if (slang[word]) {
          slang[word].split(" ").forEach(function (elem) {
            emit(this._id, {
              word: elem,
              coordinates: this.coordinates,
              place: this.place,
              country_code: this.country_code
            });
          }.bind(this));
        }
        else {
          emit(this._id, {
            word: word,
            coordinates: this.coordinates,
            place: this.place,
            country_code: this.country_code
          });
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
  { out: "tweets_translated", scope: {slang: slang, re: re} }
);

// 2.e

var subj = {};
db.subjectivity.find().forEach(function (elem) {
  subj[elem._id] = elem.rating;
});

var mapping = {
  negative: -1,
  neutral: 0,
  positive: 1
};

db.tweets_translated.mapReduce(
  function () {
    this.value.words.forEach(function (word) {
      var rating = mapping.neutral;
      if (subj[word]) {
        rating = mapping[subj[word]];
      }
      emit(this._id, {
        rating: rating,
        coordinates: this.value.coordinates,
        place: this.value.place,
        country_code: this.value.country_code
      });
    }.bind(this));
  },
  function (key, values) {
      rating = 0;
      values.forEach(function (elem) {
          rating += elem.rating;
      });
      return {coordinates: values[0].coordinates, country_code: values[0].country_code, place: values[0].place, rating: rating};
  },
  { out: "subj_analysis", scope: {subj: subj, mapping: mapping}, query: {"value.words": {$exists: true}}}
);

// 2.f

var subj = {};
db.subjectivity.find().forEach(function (elem) {
  subj[elem._id] = elem.rating;
});

var mapping = {
  negative: -1,
  neutral: 0,
  positive: 1
};

var emoticons = {
  positive: [":-)",":)",":o)",":]",":3",":c)",":>","=]","8)","=)",":}",":^)",":っ)",":-D",":D","8-D","8D","x-D","xD","X-D","XD","=-D","=D","=-3","=3","B^D",":-))",":*",":^*","( '}{' )",">:P",":-P",":P","X-P","x-p","xp","XP",":-p",":p","=p",":-Þ",":Þ",":þ",":-þ",":-b",":b","\\o/","<3"],
  negative: [">:[",":-(",":(","",":-c",":c",":-<","",":っC",":<",":-[",":[",":{",";(",":-||",":@",">:(",":'-(",":'(",":'-)",":')","D:<","D:","D8","D;","D=","DX","v.v","D-':",">:O",":-O",":O","8-0",">:\\",">:/",":-/",":-.",":/",":\\","=/","=\\",":L","=L",":S",">.<",":-###..",":###..","<:-|","</3"]
};

db.tweets_translated.mapReduce(
  function () {
    this.value.words.forEach(function (word) {
      var rating = mapping.neutral;
      if (subj[word]) {
        rating = mapping[subj[word]];
      }
      else if (emoticons.positive.indexOf(word) !== -1) {
        rating = mapping.positive;
      }
      else if (emoticons.negative.indexOf(word) !== -1) {
        rating = mapping.negative;
      }
      emit(this._id, {
        rating: rating,
        coordinates: this.value.coordinates,
        place: this.value.place,
        country_code: this.value.country_code
      });
    }.bind(this));
  },
  function (key, values) {
      rating = 0;
      values.forEach(function (elem) {
          rating += elem.rating;
      });
      return {coordinates: values[0].coordinates, country_code: values[0].country_code, place: values[0].place, rating: rating};
  },
  { out: "subj_analysis_emo", scope: {subj: subj, mapping: mapping, emoticons: emoticons}, query: {"value.words": {$exists: true}}}
);
