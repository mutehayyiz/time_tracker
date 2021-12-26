class Total {
  String category;
  String date;

  double total;
  int seconds;

  Total.fromJson(Map<String, dynamic> json)
      : category = json["category"],
        date = json["date"],
        total = json["total"],
        seconds = json["seconds"];
}
