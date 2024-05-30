import 'package:flutter/material.dart';
import 'package:moonje_mate/widget/buttons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/problem.dart';
import '../widget/text_fields.dart';
import 'chat_screen.dart';

class StorageDateScreen extends StatefulWidget {
  const StorageDateScreen({super.key});

  @override
  _StorageDateScreenState createState() => _StorageDateScreenState();
}

class _StorageDateScreenState extends State<StorageDateScreen> {
  final supabase = Supabase.instance.client;
  late Future<List<ProblemModel>> _problems;

  @override
  void initState() {
    super.initState();
    _problems = fetchProblems();
  }

  Future<List<ProblemModel>> fetchProblems() async {
    final response = await supabase
        .from('problem')
        .select()
        .eq('user_mail', supabase.auth.currentUser!.email!);

    final data = response as List<dynamic>;
    return data
        .map((e) => ProblemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('보관함_목록형'),
        actions: [
          IconButton(
            icon: Icon(Icons.view_list),
            onPressed: () {
              // Toggle view mode functionality
            },
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.shop),
          ),
        ],
      ),
      body: FutureBuilder<List<ProblemModel>>(
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
            return ListView.builder(
              itemCount: problems.length,
              itemBuilder: (context, index) {
                final problem = problems[index];
                return ProblemCard(problem: problem);
              },
            );
          }
        },
      ),
    );
  }
}

class ProblemCard extends StatelessWidget {
  final ProblemModel problem;
  final TextEditingController _tagController = TextEditingController();

  ProblemCard({required this.problem});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color(0xffD9D9D9),
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
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
                  onPressed: () {
                    // 해설 기능
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('해설'),
                          content: Text(
                            problem.problem_ans,
                            style: TextStyle(fontWeight: FontWeight.bold),
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
                  onPressed: () {
                    // 태그 변경 기능
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
                                  onFieldSubmitted: _changetag,
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    );
                  },
                  text: '태그변경',
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
                ),
                SizedBox(width: 8),
                ElevatedButtionCustom(
                  onPressed: () {
                    // 삭제 기능

                  },
                  text: '삭제',
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _changetag(String value) {

  }
}
