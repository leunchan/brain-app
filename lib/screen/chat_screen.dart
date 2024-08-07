import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:moonje_mate/model/user.dart';
import 'package:moonje_mate/widget/buttons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

import '../model/problem.dart';
import '../widget/text_fields.dart';
import '../widget/texts.dart';

const apiKey = '';
const apiUrl = 'https://api.openai.com/v1/chat/completions';
final supabase = Supabase.instance.client;

// 객관식 주관식 기능 추가 예정
// 난이도 기능 추가 예정

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  List<ChatMessage> _messages = [];
  String textState = '';
  bool isProblemButtonClicked = false;
  bool isSolutionButtonClicked = false;
  String problem_text = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '문제메이트와 문제 생성',
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _messages[index];
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            // 버튼 클릭 여부 업데이트
                            isProblemButtonClicked = true;
                            isSolutionButtonClicked = false;
                          });
                          _textState("problem");
                        },
                        child: Text(
                          '문제 생성',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                            isProblemButtonClicked
                                ? Colors.green
                                : Color(0xff70b9db),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            // 버튼 클릭 여부 업데이트
                            isProblemButtonClicked = false;
                            isSolutionButtonClicked = true;
                          });
                          _textState("solution");
                        },
                        child: Text(
                          '해설 요청',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                            isSolutionButtonClicked
                                ? Colors.green
                                : Color(0xff70b9db),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: '생성하고싶은 문제 키워드 입력',
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _attachFile,
                      icon: Icon(Icons.attach_file),
                    ),
                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    String message = _messageController.text;
    String State = _textState('response');

    if (message.isNotEmpty && State != '') {
      UserModel user = await getUserInfo();
      String nickname = user.nickname;
      String? profileImageUrl = user.profileUrl;

      _addMessage(ChatMessage(
        content: message,
        isUser: true,
        nickname: nickname,
        profileImageUrl: profileImageUrl ?? 'assets.default_user_img.png',
      ));
      String response = await _fetchResponse(message, State);
      _addMessage(ChatMessage(
        content: response,
        isUser: false,
        nickname: '문제메이트',
        profileImageUrl: 'assets/logo1.png',
      ));
      _messageController.clear();
      setState(() {});
    }
  }

  Future<UserModel> getUserInfo() async {
    final response = await supabase
        .from('user')
        .select()
        .eq('uid', supabase.auth.currentUser!.id);
    return response.map((e) => UserModel.fromJson(e)).single;
  }

  Future<String> _fetchResponse(String message, String State) async {
    String role_gpt = '';
    String message_deco = '';
    String message_deco2 = '';

    if (State == 'problem') {
      role_gpt = 'You are a problem creator.';
      message_deco = '와 관련된 문제를 하나만 만들어주고, 답은 알려주지 마';
    } else if (State == 'answer_check') {
      role_gpt =
          'You only check the users answers is correct or uncorrect. Do not say correct answer';
      message_deco2 = problem_text + '이 문제의 정답이';
      message_deco = '인지 맞았습니다 틀렸습니다로 알려줘';
    } else if (State == 'solution') {
      role_gpt = 'You give a solution';
      message_deco = problem_text + '문제의 답이 왜 그런지 자세하게 설명해줄래?';
    }

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode(
        {
          "model": "gpt-4o",
          'messages': [
            {
              "role": "system",
              "content": role_gpt,
            },
            {
              "role": "user",
              "content": message_deco2 + message + message_deco,
            }
          ]
        },
      ),
    );

    if (response.statusCode == 200) {
      final responseBody = utf8.decode(response.bodyBytes);
      var data = jsonDecode(responseBody);

      if (State == 'problem') {
        problem_text = data['choices'][0]['message']['content'];
      }

      if (data != null &&
          data['choices'] != null &&
          data['choices'].isNotEmpty) {
        return data['choices'][0]['message']['content'];
      } else {
        return "Error: No response from the server.";
      }
    } else {
      return "Error: ${response.reasonPhrase}";
    }
  }

  void _addMessage(ChatMessage message) {
    setState(() {
      _messages.add(message);
    });
  }

  // 추후 생성, clova api 사용해서
  Future<void> _attachFile() async {
    UserModel user = await getUserInfo();

    final imageFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (imageFile == null) return;

    var bytes = File(imageFile.path).readAsBytesSync();
    String img64 = base64Encode(bytes);

    var url =
        'https://u61i753n2w.apigw.ntruss.com/custom/v1/31487/db949762f3619583be72351a3bf1c27134bff6b18c47525d1778ea53217e866a/general';

    var payload = {
      "version": "V1",
      "requestId": "${user.id}+${DateTime.now()}", // 여기는 고유한 값을 생성해야 합니다.
      "timestamp": DateTime.now().millisecondsSinceEpoch,
      "images": [
        {"format": "jpg", "name": "medium", "data": img64, "url": null}
      ],
      "lang": "ko",
      "resultType": "string"
    };

    var headers = {
      
      // 올바른 API 키를 사용하세요.
      "Content-Type": "application/json"
    };

    var response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);
      if (result['images'] != null && result['images'].length > 0) {
        var fields = result['images'][0]['fields'];
        if (fields != null && fields.length > 0) {
          String clovaText =
              fields.map((field) => field['inferText']).join(' ');

          setState(() {
            _addMessage(ChatMessage(
              content: clovaText,
              isUser: true,
              nickname: user.nickname,
              profileImageUrl: user.profileUrl!,
            ));

            _fetchResponse(clovaText, 'problem').then((problemText) {
              _addMessage(ChatMessage(
                content: problemText,
                isUser: false,
                nickname: "문제메이트",
                profileImageUrl: "assets/logo1.png",
              ));
            });
          });
        }
      }
    } else {
      print("HTTP 요청 실패: ${response.statusCode}");
      print("HTTP 요청 응답: ${response.body}");
    }
  }

  // 텍스트가 문제 생성인지, 정답 제공인지, 해설인지 상태를 결정할 함수
  _textState(String textType) {
    if (textType == '') {
      // 이거는 사용자가 버튼을 아무것도 선택하지 않았을 때로 이 경우에 대한 판단도 추가 필요
      return '';
    } else if (textType == 'response') {
      String t = textState;
      textState = '';
      return t;
    } else {
      textState = textType;
      return textState;
    }
  }
}

class ChatMessage extends StatelessWidget {
  final String content;
  final bool isUser;
  final String nickname;
  final String profileImageUrl;

  const ChatMessage({
    required this.content,
    required this.isUser,
    required this.nickname,
    required this.profileImageUrl,
    Key? key,
  }) : super(key: key);

  // 프로필 이미지 꽉 안차게 나옴
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: Colors.transparent,
                backgroundImage: isUser
                    ? NetworkImage(profileImageUrl)
                    : AssetImage(profileImageUrl) as ImageProvider<Object>,
                radius: 20,
              ),
              const SizedBox(width: 5),
              Text(
                nickname,
                style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: isUser ? Color(0xff70b9db) : Colors.grey,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Text(
              content,
              style: TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          !isUser
              ? ElevatedButton(
                  onPressed: () {
                    _showSaveDialog(context, content);
                  },
                  child: Text(
                    '저장',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                  ),
                )
              : SizedBox(),
        ],
      ),
    );
  }
}

Future<void> _showSaveDialog(BuildContext context, String content) async {
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  // 다이얼로그 표시
  await showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('$currentDate'), // 오늘 날짜 표시
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 문제 유형 선택
              SectionText(text: '문제 유형', textColor: Colors.black),
              const SizedBox(height: 8),
              TextFormFieldCustom(
                hintText: '객관식 or 주관식',
                isPasswordField: false,
                isReadOnly: false,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                validator: (value) => inputTypeValidator(value),
                controller: _typeController,
              ),
              const SizedBox(height: 8), // 각 텍스트 필드 사이의 간격
              // 문제 태그 선택
              SectionText(text: '문제 태그', textColor: Colors.black),
              const SizedBox(height: 8),
              TextFormFieldCustom(
                hintText: 'ex) 이산수학, C언어 등',
                isPasswordField: false,
                isReadOnly: false,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                validator: (value) => inputTagValidator(value),
                controller: _tagController,
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButtionCustom(
            text: '취소',
            backgroundColor: Color(0xffa3a3a3),
            textColor: Colors.white,
            onPressed: () {
              Navigator.of(context).pop(); // 팝업 닫기
            },
          ),
          ElevatedButtionCustom(
            text: '확인',
            backgroundColor: Color(0xffa3a3a3),
            textColor: Colors.white,
            onPressed: () {
              _saveToDatabase(content, _typeController.text,
                  _tagController.text); // 사용자 입력값
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

inputTagValidator(value) {
  if (value.isEmpty) {
    return '태그를 입력해주세요';
  }
  return null;
}

inputTypeValidator(value) {
  if (value.isEmpty) {
    return '타입을 입력해주세요';
  }
  return null;
}

Future<void> _saveToDatabase(
    String content, String problemType, String problemTag) async {
  var user = supabase.auth.currentUser;
  var response =
      await supabase.from('user').select('email').eq('email', user!.email!);
  var myInstance = _ChatScreenState();
  //int user_id = response![0]['id'];

  await supabase.from('problem').insert(
        ProblemModel(
          problem_ans: await myInstance._fetchResponse(content, 'solution'),
          problem_des: content,
          types: problemType!,
          user_mail: response![0]['email'],
          // id: user_id,
          tag: problemTag!,
        ).toMap(),
      );
}
