import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

          return SingleChildScrollView(
          child :Container(
            child: Padding(
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
                  Container(
                    width: 180,
                    height: 32,
                  child:ElevatedButtionCustom(
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

                          // 업로드 된 파일의 이미지 URL을 취득
                          imageUrl = Supabase.instance.client.storage
                              .from('Brain')
                              .getPublicUrl(
                              'profiles/${user['id']}_$nowTime.jpg');

                          setState(() {
                            _profilePictureUrl = imageUrl;
                          });
                        }

                        final response = await Supabase.instance.client.from('user').update({
                          'nickname': _nicknameController.text,
                          'age': int.tryParse(_ageController.text),
                          'school': _schoolController.text,
                          'profile_url': imageUrl ?? _profilePictureUrl,
                        }).eq('id', user['id']);

                        if (response.error != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  '프로필 업데이트 실패: ${response.error!.message}'),
                            ),
                          );
                        } else {
                          // 응답을 받은 후에 다이얼로그를 표시합니다.
                          if (mounted) return;
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

  _buildProfile() {
    if (profileImg == null) {
      /// 프로필 이미지가 없을 경우
      return Center(
        child: CircleAvatar(
          backgroundColor: Colors.grey,
          radius: 48,
          child: Image.asset('assets/default_user_img.png')
          ),
      );
    } else {
      /// 프로필 이미지가 있을 경우
      return Center(
        child: CircleAvatar(
          backgroundColor: Colors.grey,
          radius: 48,
          backgroundImage: FileImage(profileImg!),
        ),
      );
    }
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
              /// 사진촬영버튼
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

              /// 앨범에서 사진 선택
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

              /// 프로필 사진 삭제
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

  Future<void> getCameraImage() async {
    var image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        profileImg = File(image.path);
      });
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

    }
  }

  void deleteProfileImg() {
    setState(() {
      profileImg = null;
    });
  }

  inputAgeValidator(value) {
    if (value.isEmpty) {
      return '나이를 입력해주세요';
    }
    return null;
  }

  inputSchoolValidator(value) {
    if (value.isEmpty) {
      return '현재학력을 입력해주세요';
    }
    return null;
  }

  inputNameValidator(value) {
    if (value.isEmpty) {
      return '닉네임을 입력해주세요';
    }
    return null;
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _ageController.dispose();
    _schoolController.dispose();
    super.dispose();
  }
}
