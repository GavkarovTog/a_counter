class AppStatus {
  AppStatus(this.isOk, this.message);

  bool isOk;
  String message;
}

double ngram(String fst, String snd) {
  const gram_size = 1;
  if (fst.length < gram_size) {
    return 0;
  }

  else if (snd.length < gram_size) {
    return 0;
  }

  List<String> fst_gramms = [];
  for (int i = 0; i < fst.length ~/ gram_size; i ++) {
    fst_gramms.add(fst.substring(i * gram_size, i * gram_size + gram_size).toLowerCase());
  }

  List<String> snd_gramms = [];
  for (int i = 0; i < snd.length ~/ gram_size; i ++) {
    snd_gramms.add(snd.substring(i * gram_size, i * gram_size + gram_size).toLowerCase());
  }

  int interception_count = 0;
  for (String fst_gram in fst_gramms) {
    for (String snd_gram in snd_gramms) {
      if (fst_gram == snd_gram) {
        interception_count ++;
      }
    }
  }

  return interception_count / (fst_gramms.length + snd_gramms.length);
}