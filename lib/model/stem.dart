class Stem {
  final String name;
  final String fileName;
  Stem({this.name, this.fileName});

  double volume = 1.0;

  Map toJson() {
    return {'fileName': fileName, 'name': name};
  }

  static Stem fromJson(Map json) {
    return Stem(fileName: json['fileName'], name: json['name']);
  }
}
