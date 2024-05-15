import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:moonje_mate/model/user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

import '../model/problem.dart';

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
  bool isCheckButtonClicked = false;
  bool isSolutionButtonClicked = false;
  String problem_text = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('문제메이트와 문제 생성'),
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
                            isCheckButtonClicked = false;
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
                            isProblemButtonClicked ? Colors.green : Colors.blue,
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
                            isCheckButtonClicked = true;
                            isSolutionButtonClicked = false;
                          });
                          _textState("answer_check");
                        },
                        child: Text(
                          '정답 맞추기',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                            isCheckButtonClicked ? Colors.green : Colors.blue,
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
                            isCheckButtonClicked = false;
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
                                : Colors.blue,
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
                          hintText: '생성하고싶은 문제 키워드를 입력하세요.',
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

  // 추후 생성
  void _attachFile() {}

  // 텍스트가 문제 생성인지, 정답 제공인지, 해설인지 상태를 결정할 함수
  _textState(String textType) {
    if (textType == '') {
      // 이거는 사용자가 버튼을 아무것도 선택하지 않았을 때로 이 경우에 대한 판단도 추가 필요
    } else if (textType == 'response') {
      String t = textState;
      textState = '';
      return t;
    } else {
      textState = textType;
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
                backgroundImage: isUser ? NetworkImage(profileImageUrl) : AssetImage(profileImageUrl) as ImageProvider<Object>,
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
              color: isUser ? Colors.blue : Colors.grey,
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
  String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String? problemType = ''; // problemType 변수를 선언하고 초기화
  String? problemtag = '';

  // 다이얼로그 표시
  problemType = await showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('저장하기 - $currentDate'), // 오늘 날짜 표시
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 문제 유형 선택
            TextField(
              decoration: InputDecoration(
                labelText: '문제 유형을 작성하세요.',
                hintText: 'ex) 객관식 or 주관식',
              ),
              onChanged: (value) {
                problemType = value;
              },
            ),
            const SizedBox(height: 8), // 각 텍스트 필드 사이의 간격
            // 문제 태그 선택
            TextField(
              decoration: InputDecoration(
                labelText: '문제 태그를 작성하세요.',
                hintText: 'ex) 산업공학입문',
              ),
              onChanged: (value) {
                // 사용자가 입력한 내용 저장
                problemtag = value;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // 팝업 닫기
            },
            child: Text('취소'),
          ),
          TextButton(
            onPressed: () {
              _saveToDatabase(content, problemType, problemtag); // 사용자 입력값 반환
              Navigator.of(context).pop();
            },
            child: Text('확인'),
          ),
        ],
      );
    },
  );

  if (problemType != null) {
    // 사용자가 확인을 선택하고 입력한 내용이 있을 때만 저장 처리
    _saveToDatabase(content, problemType, problemtag); // 데이터베이스에 저장하는 함수 호출
  }
}

Future<void> _saveToDatabase(String content, String? problemType, String? problemtag) async {
  var user = supabase.auth.currentUser;
  var response =
      await supabase.from('user').select('id').eq('email', user!.email!);
  var myInstance = _ChatScreenState();
  //int user_id = response![0]['id'];

  await supabase.from('problem').insert(
        ProblemModel(
          problem_ans: await myInstance._fetchResponse(content, 'solution'),
          problem_des: content,
          types: problemType!,
          // id: user_id,
          tag: problemtag,
        ).toMap(),
      );
}
