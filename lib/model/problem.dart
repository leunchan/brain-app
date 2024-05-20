class ProblemModel {
  int? id;
  String problem_des;
  String problem_ans;
  String? tag;
  String types;
  DateTime? createdAt;
  String user_mail;

  ProblemModel({
    this.id,
    required this.problem_des,
    required this.problem_ans,
    this.tag,
    required this.types,
    this.createdAt,
    required this.user_mail,
  });

  Map<String, dynamic> toMap() {
    return {
      'problem_des' : problem_des,
      'problem_ans' : problem_ans,
      'types' : types,
      'user_mail' : user_mail,
      'tag' : tag,
    };
  }

  factory ProblemModel.fromJson(Map<dynamic, dynamic> json) {
    return ProblemModel(
      id : json['id'],
      problem_des: json['problem_des'],
      problem_ans: json['problem_ans'],
      tag: json['tag'],
      types: json['types'],
      user_mail: json['user_mail'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

}
