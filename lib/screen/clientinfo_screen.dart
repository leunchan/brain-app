import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moonje_mate/widget/buttons.dart';
import 'package:moonje_mate/widget/text_fields.dart';
import 'package:moonje_mate/widget/texts.dart';
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
          _profilePictureUrl ??= user['profile_url'] ?? 'assets/default_user_img.png';

          return SingleChildScrollView(
            child: Container(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _profilePictureUrl != null && !_profilePictureUrl!.contains('assets/default_user_img.png')
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
                    Container(
                      width: 180,
                      height: 32,
                      child: ElevatedButtionCustom(
                        text: '프로필 사진 변경',
                        backgroundColor: Colors.black,
                        textColor: Colors.white,
                        onPressed: () {
                          showBottomSheetAboutProfile();
                        },
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionText(text: '닉네임', textColor: Color(0xff979797)),
                        const SizedBox(height: 8),
                        TextFormFieldCustom(
                          isPasswordField: false,
                          isReadOnly: false,
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.next,
                          validator: (value) => inputNameValidator(value),
                          controller: _nicknameController,
                        ),
                      ],
                    ),
                    SizedBox(height: 20.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionText(text: '나이', textColor: Color(0xff979797)),
                        const SizedBox(height: 8),
                        TextFormFieldCustom(
                          isPasswordField: false,
                          maxLines: 1,
                          isReadOnly: false,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          validator: (value) => inputAgeValidator(value),
                          controller: _ageController,
                        ),
                      ],
                    ),
                    SizedBox(height: 20.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionText(text: '현재학력', textColor: Color(0xff979797)),
                        const SizedBox(height: 8),
                        TextFormFieldCustom(
                          isPasswordField: false,
                          maxLines: 1,
                          isReadOnly: false,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          validator: (value) => inputSchoolValidator(value),
                          controller: _schoolController,
                        ),
                      ],
                    ),
                    SizedBox(height: 20.0),
                    Container(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButtionCustom(
                        text: '프로필 변경',
                        backgroundColor: Colors.black,
                        textColor: Colors.white,
                        onPressed: () async {
                          await _updateProfile(user);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> getCameraImage() async {
    var image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        profileImg = File(image.path);
      });
      await uploadProfileImage();
    }
  }

  Future<void> getGalleryImage() async {
    var image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 10,
    );
    if (image != null) {
      setState(() {
        profileImg = File(image.path);
      });
      await uploadProfileImage();
    }
  }

  Future<void> uploadProfileImage() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null || profileImg == null) return;

    final nowTime = DateTime.now();
    final imgFile = profileImg!;

    if (_profilePictureUrl != null && !_profilePictureUrl!.contains('assets/default_user_img.png')) {
      final imageUrl = _profilePictureUrl!;
      final List<String> parts = imageUrl.split('/');
      final fileNameWithQueryParams = parts.last;
      final fileName = Uri.decodeFull(fileNameWithQueryParams.split('?').first);

      await Supabase.instance.client.storage
          .from('Brain')
          .remove(['profiles/$fileName']);
    }

    final response = await Supabase.instance.client.storage
        .from('Brain')
        .upload(
      'profiles/${user.id}_$nowTime.jpg',
      imgFile,
      fileOptions: FileOptions(
        cacheControl: '3600',
        upsert: true,
      ),
    );

    final imageUrl = Supabase.instance.client.storage
        .from('Brain')
        .getPublicUrl(
        'profiles/${user.id}_$nowTime.jpg');

    setState(() {
      _profilePictureUrl = imageUrl;
    });

    await Supabase.instance.client.from('user').update({
      'profile_url': imageUrl,
    }).eq('id', user.id);
  }

  void showBottomSheetAboutProfile() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  getCameraImage();
                },
                child: Text(
                  '사진촬영',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  getGalleryImage();
                },
                child: Text(
                  '앨범에서 사진 선택',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  deleteProfileImg();
                },
                child: Text(
                  '프로필 사진 삭제',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void deleteProfileImg() {
    setState(() {
      profileImg = null;
      _profilePictureUrl = 'assets/default_user_img.png';
    });
  }

  String? inputAgeValidator(value) {
    if (value.isEmpty) {
      return '나이를 입력해주세요';
    }
    return null;
  }

  String? inputSchoolValidator(value) {
    if (value.isEmpty) {
      return '현재학력을 입력해주세요';
    }
    return null;
  }

  String? inputNameValidator(value) {
    if (value.isEmpty) {
      return '닉네임을 입력해주세요';
    }
    return null;
  }

  Future<void> _updateProfile(Map<String, dynamic> user) async {
    try {
      String? imageUrl = _profilePictureUrl;

      if (profileImg != null) {
        final nowTime = DateTime.now();
        final imgFile = profileImg!;

        if (user['profile_url'] != null) {
          final imageUrl = user['profile_url'];
          final List<String> parts = imageUrl.split('/');
          final fileNameWithQueryParams = parts.last;
          final fileName = Uri.decodeFull(fileNameWithQueryParams.split('?').first);

          await Supabase.instance.client.storage
              .from('Brain')
              .remove(['profiles/$fileName']);
        }

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

        imageUrl = Supabase.instance.client.storage
            .from('Brain')
            .getPublicUrl(
            'profiles/${user['id']}_$nowTime.jpg');

        setState(() {
          _profilePictureUrl = imageUrl;
        });
      }

      final updateResponse = await Supabase.instance.client
          .from('user')
          .update({
        'nickname': _nicknameController.text,
        'age': int.tryParse(_ageController.text),
        'school': _schoolController.text,
        'profile_url': imageUrl ?? _profilePictureUrl,
      })
          .eq('email', user['email']);

      if (updateResponse == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('프로필 업데이트 완료되었습니다.'),
          ),
        );
        showDialog(
          context: context,
          builder: (BuildContext dialogContext) {
            return CupertinoAlertDialog(
              content: Text('회원 정보 수정완료'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    Navigator.pop(context);
                  },
                  child: Text('닫기'),
                ),
              ],
            );
          },
        );


      } else if (updateResponse.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('프로필 업데이트 실패: ${updateResponse.error!.message}'),
          ),
        );
      } else {
      }
    } catch (error) {
      print('Error updating profile: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('프로필 업데이트 중 오류 발생: $error'),
        ),
      );
    }
  }


  @override
  void dispose() {
    _nicknameController.dispose();
    _ageController.dispose();
    _schoolController.dispose();
    super.dispose();
  }
}
