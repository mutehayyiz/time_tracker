class Total {
  late String category;
  late String date;
  late double total;
  late int seconds;

  Total();

  Total.fromJson(Map<String, dynamic> json)
      : category = json["category"],
        date = json["date"],
        total = json["total"],
        seconds = json["seconds"];
}
