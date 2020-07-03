class Artist {
  final String name;

  Artist({this.name});

  Artist.fromJson(Map json) : name = json['name'];

  Artist copyWith() {
    return Artist(name: name);
  }
}
