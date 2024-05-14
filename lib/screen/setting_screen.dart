import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moonje_mate/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widget/buttons.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  File? profileImg; // 프로필 이미지 파일
  String? profileImgUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          profileImgUrl = user['profile_url'];
          return SingleChildScrollView(
            child: Column(
              children: [
                // 프로필 이미지 표시
                const SizedBox(height: 64),
                CircleAvatar(
                  backgroundImage: profileImgUrl != null
                      ? NetworkImage(profileImgUrl!)
                      : null, // 기본 이미지는 설정하지 않음
                  child: profileImgUrl == null
                      ? Image.asset(
                    'assets/default_user_img.png',
                    width: 120,
                    height:120,) // 기본 이미지로 사용할 아이콘
                      : null, // 프로필 이미지가 있을 경우에는 아이콘 표시하지 않음
                  radius: 80,
                ),
                const SizedBox(height: 54),
                // 회원정보 수정 버튼
                Container(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButtionCustom(
                    text: ' ➡️ 회원정보 수정',
                    backgroundColor: Color(0xff979797),
                    textColor: Colors.black,
                    onPressed: () {
                      // 회원정보 수정 화면 이동
                      Navigator.pushNamed(context, '/client');
                    },
                  ),
                ),
                const SizedBox(height: 44),
                // 로그아웃 버튼
                Container(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButtionCustom(
                    text: ' ➡️ 로그아웃',
                    backgroundColor: Color(0xff979797),
                    textColor: Colors.black,
                    onPressed: () {
                      showCupertinoModalPopup<void>(
                        context: context,
                        builder: (BuildContext context) =>
                            CupertinoAlertDialog(
                              title: const Text('알림'),
                              content: const Text('로그아웃하시겠습니까?'),
                              actions: <CupertinoDialogAction>[
                                CupertinoDialogAction(
                                  isDefaultAction: true,
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('아니오'),
                                ),
                                CupertinoDialogAction(
                                  isDestructiveAction: true,
                                  onPressed: () {
                                    Navigator.of(context).pushAndRemoveUntil(
                                        CupertinoPageRoute(
                                            builder: (context) => MyApp()),
                                            (route) => false
                                    );
                                  },
                                  child: Text('예'),
                                ),
                              ],
                            ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 44),
                // 탈퇴 버튼 ---> 아직 구현못했어..
                Container(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButtionCustom(
                    text: ' ➡️ 탈퇴',
                    backgroundColor: Color(0xff979797),
                    textColor: Colors.black,
                    onPressed: () async {
                      // 회원 탈퇴 기능 수행
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}