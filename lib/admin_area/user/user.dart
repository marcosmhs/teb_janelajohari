import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  static const collectionName = 'user';

  late String id;
  late String email;
  late String password;
  late String token;
  late String name;

  late bool _passwordChanged = false;

  User({this.id = '', this.email = '', this.password = '', this.token = '', this.name = ''});

  void setPassword(String value) {
    password = value;
    _passwordChanged = true;
  }

  bool get isPasswordChanged {
    return _passwordChanged;
  }

  factory User.fromDocument(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return User.fromMap(map: data);
  }

  static User fromMap({required Map<String, dynamic> map, String setEmail = '', String setToken = ''}) {
    var u = User();

    u = User(
      id: map['id'] ?? '',
      email: setEmail.isNotEmpty ? setEmail : map['email'] ?? '',
      password: map['password'] ?? '',
      token: setToken.isNotEmpty ? setToken : map['token'] ?? '',
      name: map['name'] ?? '',
    );
    return u;
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> r = {};
    r = {'id': id, 'email': email, 'password': password, 'token': token, 'name': name};

    return r;
  }
}
