class ProblemModel {
  int? id;
  String problem_des;
  String problem_ans;
  String? tag;
  String types;
  DateTime? createdAt;

  ProblemModel({
    this.id,
    required this.problem_des,
    required this.problem_ans,
    this.tag,
    required this.types,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'problem_des' : problem_des,
      'problem_ans' : problem_ans,
      'types' : types,
    };
  }

  factory ProblemModel.fromJson(Map<dynamic, dynamic> json) {
    return ProblemModel(
      id : json['id'],
      problem_des: json['problem_des'],
      problem_ans: json['problem_ans'],
      tag: json['tag'],
      types: json['types'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

}
