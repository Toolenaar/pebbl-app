class User {
  final String id;
  final String email;
  final String username;

  User({this.id, this.email, this.username});

  User.fromJson(Map json, String id)
      : id = id,
        username = json['username'],
        email = json['email'];

  Map<String, dynamic> toJson() {
    return {'username': username, 'email': email};
  }
}
