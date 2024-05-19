import 'package:flutter/material.dart';
import 'package:moonje_mate/model/user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../common/snackbar_util.dart';
import '../widget/buttons.dart';
import '../widget/text_fields.dart';
import '../widget/texts.dart';

/// 로그인 확인
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final supabase = Supabase.instance.client;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 160),
                const Center(
                  child: Text(
                    '문제메이트',
                    style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 53),

                /// 이메일
                SectionText(text: '이메일', textColor: Color(0xff979797)),
                const SizedBox(height: 8),
                TextFormFieldCustom(
                  isPasswordField: false,
                  isReadOnly: false,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (value) => inputEmailValidator(value),
                  controller: _emailController,
                ),

                const SizedBox(height: 24),

                /// 비밀번호
                SectionText(text: '비밀번호', textColor: Color(0xff979797)),
                const SizedBox(height: 8),
                TextFormFieldCustom(
                  // 이걸 해줘야 비밀번호가 뜬다하심
                  maxLines: 1,
                  isPasswordField: true,
                  isReadOnly: false,
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.done,
                  validator: (value) => inputPasswordValidator(value),
                  controller: _passwordController,
                ),

                const SizedBox(height: 40),

                /// 로그인 버튼
                Container(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButtionCustom(
                    text: '로그인',
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                      onPressed: () async {
                        // 로그인
                        String emailValue = _emailController.text;
                        String passwordValue = _passwordController.text;

                        // 유효성 검사 체크
                        if (!formKey.currentState!.validate()) {
                          return;
                        }

                        // 이메일과 비밀번호로 로그인 시도
                        bool isLoginSuccess = await loginWithEmail(emailValue, passwordValue);

                        if (!context.mounted) return;
                        if (!isLoginSuccess) {
                          showSnackBar(context, '로그인을 실패하였습니다');
                          return;
                        }

                        // 사용자 정보 가져오기
                        UserModel? userInfo = await getUserInfo(emailValue);
                        // 회원탈퇴 시 authentication에서 지워지는 걸 못해서 일단 이렇게 구현해뒀어 차차 구현해볼게
                        // 닉네임 변수 확인
                        if (userInfo == null || userInfo.nickname == null || userInfo.nickname.isEmpty) {
                          // 사용자 정보가 없거나 닉네임 변수가 비어 있는 경우 로그인 실패 처리
                          showSnackBar(context, '로그인을 실패하였습니다. 닉네임이 없습니다.');
                          return;
                        }

                        // 로그인을 성공하여 메인으로 이동
                        // 로그인 화면을 죽여주고 가야하기때문에 popAndPushNamed 사용
                        Navigator.popAndPushNamed(context, '/main');
                      }
                  ),
                ),

                const SizedBox(height: 16),

                /// 회원가입 버튼
                Container(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButtionCustom(
                    text: '회원가입',
                    backgroundColor: Color(0xff979797),
                    textColor: Colors.white,
                    onPressed: () {
                      // 회원가입 화면 이동
                      Navigator.pushNamed(context, '/register');
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Future<UserModel?> getUserInfo(String email) async {
    // Supabase 클라이언트 생성
    final supabaseClient = SupabaseClient('https://sdncltappldozngyrnhu.supabase.co', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNkbmNsdGFwcGxkb3puZ3lybmh1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTE3MTM2MjAsImV4cCI6MjAyNzI4OTYyMH0.g2UQuA4z6T8_KUoAJve-uI4Ps31cD8ZD0s9vKQtTDx0');

    // 사용자 정보 가져오기
    final response = await supabaseClient.from('user')
        .select()
        .eq('email', email)
        .single();

    // 가져온 사용자 정보를 UserInfo 모델로 변환하여 반환
      // 정상적으로 사용자 정보를 가져온 경우
      final userData = response as Map<String, dynamic>;
      return UserModel.fromJson(userData);
  }
  inputEmailValidator(value) {
    /// 이메일 필드 검증 함수
    if (value.isEmpty) {
      return '이메일을 입력해주세요';
    }
    return null;
  }

  inputPasswordValidator(value) {
    /// 비밀번호 필드 검증 함수
    if (value.isEmpty) {
      return '비밀번호를 입력해주세요';
    }
    return null;
  }

  Future<bool> loginWithEmail(String emailValue, String passwordValue) async {
    // 이메일 로그인 (수파베이스)
    bool isLoginSuccess = false;
    final AuthResponse response = await supabase.auth.signInWithPassword(
        email: emailValue, password: passwordValue);
    if (response.user! != null) {
      isLoginSuccess = true;
    } else {
      isLoginSuccess = false;
    }
    return isLoginSuccess;
  }
}