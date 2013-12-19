// 3.1 Sentiment per country.

db.subj_analysis_emo.mapReduce(
  function () {
    if (this.value.country_code && this.value.country_code.length === 2) {
      emit(this.value.country_code, this.value.rating);
    }
  },
  function (key, values) {
    return Array.sum(values) / values.length;
  },
  { out: "sentiment_country" }
);

// 3.2 Sentiment per city.


