class Entry {
  late String id;
  late String category;
  late String start;
  late String stop;
  late int seconds;
  late String date;

  Entry();

  Entry.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        start = json['start'],
        stop = json['stop'],
        seconds = json['seconds'],
        category = json['category'],
        date = json['date'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date,
        'start': start,
        'stop': stop,
        'seconds': seconds,
        'category': category,
      };
}
