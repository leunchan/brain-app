import 'package:flutter/material.dart';
import 'package:moonje_mate/screen/storage_date_screen.dart';
import 'package:moonje_mate/widget/buttons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/problem.dart';
import '../widget/text_fields.dart';
import 'chat_screen.dart';

class StorageScreen extends StatefulWidget {
  const StorageScreen({super.key});

  @override
  State<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen> {
  final supabase = Supabase.instance.client;
  late Future<List<ProblemModel>> _problems;
  late Future<List<String>> _tags;
  String? _selectedTag;
  final TextEditingController _tagController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _problems = fetchProblems();
    _tags = fetchTags();
  }

  Future<List<String>> fetchTags() async {
    final response = await supabase
        .from('problem')
        .select('tag')
        .eq('user_mail', supabase.auth.currentUser!.email!);

    final data = response as List<dynamic>;
    final tags = data.map((e) => e['tag'] as String).toSet().toList();
    tags.insert(0, '전체'); // '전체' 옵션 추가
    return tags; // 중복 제거
  }

  Future<List<ProblemModel>> fetchProblems({String? tag}) async {
    var query = supabase
        .from('problem')
        .select()
        .eq('user_mail', supabase.auth.currentUser!.email!);

    if (tag != null && tag != '전체') {
      query = query.eq('tag', tag);
    }

    final response = await query.order('created_at', ascending: false); // 날짜별 정렬 추가
    final data = response as List<dynamic>;
    return data.map((e) => ProblemModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  void _onTagSelected(String tag) {
    setState(() {
      _selectedTag = tag;
      _problems = fetchProblems(tag: tag);
    });
  }

  void _changetag(String value, int problemId) async {
    final response = await supabase
        .from('problem')
        .update({'tag': value})
        .eq('id', problemId);

    if (response.error != null) {
      throw response.error!;
    }

    setState(() {
      _problems = fetchProblems(tag: _selectedTag);
    });
  }

  void _deleteproblem(int problemId) async {
    final response = await supabase
        .from('problem')
        .delete()
        .eq('id', problemId);

    setState(() {
      _problems = fetchProblems(tag: _selectedTag);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('보관함_태그형'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: FutureBuilder<List<String>>(
                future: _tags,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No tags found.'));
                  } else {
                    final tags = snapshot.data!;
                    return Wrap(
                      spacing: 8.0,
                      children: tags.map((tag) {
                        return ChoiceChip(
                          label: Text(tag),
                          selected: _selectedTag == tag,
                          onSelected: (selected) {
                            _onTagSelected(tag);
                          },
                        );
                      }).toList(),
                    );
                  }
                },
              ),
            ),
            FutureBuilder<List<ProblemModel>>(
              future: _problems,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No problems found.'));
                } else {
                  final problems = snapshot.data!;
                  return Column(
                    children: problems.map((problem) {
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                problem.createdAt!.toLocal().toString().split(' ')[0],
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Container(
                                color: Colors.white,
                                width: double.infinity,
                                padding: EdgeInsets.all(16),
                                child: Text(
                                  problem.problem_des,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButtionCustom(
                                    text: '해설',
                                    backgroundColor: Color(0xffa3a3a3),
                                    textColor: Colors.white,
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('해설'),
                                            content: SingleChildScrollView(
                                              child: Text(
                                                problem.problem_ans,
                                                style: TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text('닫기'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  ),
                                  SizedBox(width: 8),
                                  ElevatedButtionCustom(
                                    text: '태그변경',
                                    backgroundColor: Color(0xffa3a3a3),
                                    textColor: Colors.white,
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('태그변경'),
                                            content: SingleChildScrollView(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  TextFormFieldCustom(
                                                    hintText: '변경할 태그를 입력하세요',
                                                    isPasswordField: false,
                                                    isReadOnly: false,
                                                    keyboardType: TextInputType.text,
                                                    textInputAction: TextInputAction.next,
                                                    validator: (value) => inputTypeValidator(value),
                                                    controller: _tagController,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text('취소'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  _changetag(_tagController.text, problem.id!);
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text('확인'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  ),
                                  SizedBox(width: 8),
                                  ElevatedButtionCustom(
                                    text: '삭제',
                                    backgroundColor: Color(0xffa3a3a3),
                                    textColor: Colors.white,
                                    onPressed: () {
                                      _deleteproblem(problem.id!);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
