// 유저 정보
import 'dart:io';

class UserModel {
  int? id;
  String nickname;
  String email;
  String? age;
  String? school;
  String? profileUrl;
  String uid;
  DateTime? createdAt;


  UserModel({
    this.id,
    required this.email,
    required this.nickname,
    this.age,
    this.school,
    this.profileUrl,
    this.createdAt,
    required this.uid,
  });

  Map<String, dynamic> toMap() {
    return {
      'nickname': nickname,
      'email': email,
      'profile_url': profileUrl,
      'uid': uid,
      'age' : age,
      'school' : school,
    };
  }

  factory UserModel.fromJson(Map<dynamic, dynamic> json) {
    return UserModel(
      id : json['id'],
      email: json['email'],
      nickname: json['nickname'],
      age: json['age'],
      school: json['school'],
      profileUrl: json['profile_url'],
      createdAt: DateTime.parse(json['created_at']),
      uid: json['uid'],
    );
  }
}
