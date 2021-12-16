class Entry {
  late String id;
  late String category;
  late String start;
  late String stop;
  late int diff;
  late String date;

  Entry();

  Entry.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        start = json['started_at'],
        stop = json['ended_at'],
        diff = json['difference'],
        category = json['category'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'started_at': start,
        'ended_at': stop,
        'difference': diff,
        'category': category,
      };
}
