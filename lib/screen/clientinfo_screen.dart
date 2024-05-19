import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

class ClientInfoScreen extends StatefulWidget {
  const ClientInfoScreen({Key? key}) : super(key: key);

  @override
  State<ClientInfoScreen> createState() => _ClientInfoState();
}

class _ClientInfoState extends State<ClientInfoScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _schoolController = TextEditingController();
  String? _profilePictureUrl;
  final _picker = ImagePicker();
  File? profileImg;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('회원정보 수정'),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: Supabase.instance.client
            .from('user')
            .select()
            .eq('email', Supabase.instance.client.auth.currentUser?.email ?? '')
            .asStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('User not authenticated'),
            );
          }
          final user = snapshot.data!.first;

          _nicknameController.text = user['nickname'] ?? '';
          _ageController.text = user['age']?.toString() ?? '';
          _schoolController.text = user['school'] ?? '';
          _profilePictureUrl = user['profile_url'];

          return Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _profilePictureUrl != null
                    ? CircleAvatar(
                  backgroundImage: NetworkImage(_profilePictureUrl!),
                  radius: 80,
                )
                    : Image.asset(
                  'assets/default_user_img.png',
                  width: 120,
                  height: 120,
                ),
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () async {
                    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      setState(() {
                        profileImg = File(pickedFile.path);
                      });
                    }
                  },
                  child: Text('프로필 사진 변경'),
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  controller: _nicknameController,
                  decoration: InputDecoration(
                    labelText: '닉네임',
                  ),
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  controller: _ageController,
                  decoration: InputDecoration(
                    labelText: '나이',
                  ),
                ),
                SizedBox(height: 20.0),
                TextFormField(
                  controller: _schoolController,
                  decoration: InputDecoration(
                    labelText: '학교',
                  ),
                ),
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () async {
                    String? imageUrl;
                    if (profileImg != null) {
                      final nowTime = DateTime.now();
                      final imgFile = profileImg!;

                      // 사용자가 이미지를 가지고 있는지 확인
                      if (user['profile_url'] != null) {
                        // URL에서 파일 이름을 추출
                        final imageUrl = user['profile_url'];
                        final List<String> parts = imageUrl.split('/');
                        final fileNameWithQueryParams = parts.last; // 파일 이름과 쿼리 매개변수를 포함한 부분
                        final fileName = Uri.decodeFull(fileNameWithQueryParams.split('?').first); // 쿼리 매개변수 제외한 파일 이름 부분

                        // 기존 이미지를 삭제
                        await Supabase.instance.client.storage
                            .from('Brain')
                            .remove(['profiles/$fileName']);
                      }
                      // 이미지 파일 업로드
                      final response = await Supabase.instance.client.storage
                          .from('Brain')
                          .upload(
                        'profiles/${user['id']}_$nowTime.jpg',
                        imgFile,
                        fileOptions: FileOptions(
                          cacheControl: '3600',
                          upsert: true,
                        ),
                      );

                      // 업로드 된 파일의 이미지 url주소를 취득
                      imageUrl = Supabase.instance.client!.storage
                          .from('Brain')
                          .getPublicUrl(
                          'profiles/${user['id']}_$nowTime.jpg');

                      setState(() {
                        _profilePictureUrl = imageUrl;
                      });
                    }

                    final response = await Supabase.instance.client!.from(
                        'user').update({
                      'nickname': _nicknameController.text,
                      'age': int.tryParse(_ageController.text),
                      'school': _schoolController.text,
                      'profile_url': imageUrl ?? _profilePictureUrl,
                    }).eq('id', user['id']);

                    if (response != null && response.errorOrNull != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Failed to update profile: ${response.errorOrNull!
                                  .message}'),
                        ),
                      );
                    } else {
                      showDialog(
                        context: context,
                        builder: (BuildContext dialogContext) {
                          return CupertinoAlertDialog(
                            title: Text('회원정보 변경'),
                            content: Text('회원 정보 수정완료'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(dialogContext).pop();
                                },
                                child: Text('닫기'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  child: Text('회원정보 변경'),
                ),

              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _ageController.dispose();
    _schoolController.dispose();
    super.dispose();
  }
}