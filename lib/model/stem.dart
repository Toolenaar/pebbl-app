class Stem {
  final String name;
  final String id;
  String filePath;
  final String downloadUrl;
  String downloadTaskId;
  Stem({this.name, this.filePath, this.downloadUrl, this.downloadTaskId, this.id});

  double volume = 1.0;

  Map toJson() {
    return {
      'id': id,
      'filePath': filePath,
      'name': name,
      'downloadUrl': downloadUrl,
      'downloadTaskId': downloadTaskId
    };
  }

  static Stem fromJson(Map json) {
    return Stem(
        filePath: json['filePath'],
        name: json['name'],
        id: json['id'],
        downloadUrl: json['downloadUrl'],
        downloadTaskId: json['downloadTaskId']);
  }

  static List<Stem> fromJsonList(List<dynamic> json) {
    return List<Stem>.from(json.map((d) => Stem.fromJson(d)));
  }

  Stem copyWith() {
    return Stem(
        name: this.name,
        filePath: this.filePath,
        downloadUrl: this.downloadUrl,
        id: this.id,
        downloadTaskId: this.downloadTaskId);
  }
}
