
class WorkReport {
  const WorkReport({
    this.id,
    this.reportDate,
    this.projectName = '',
    this.taskTitle = '',
    this.description = '',
    this.workDone = '',
    this.status = '',
  });

  final int? id;
  final String? reportDate;
  final String projectName;
  final String taskTitle;
  final String description;
  final String workDone;
  final String status;

  factory WorkReport.fromJson(Map<String, dynamic> json) {
    return WorkReport(
      id: int.tryParse('${json['id'] ?? ''}'),
      reportDate: json['report_date']?.toString(),
      projectName: json['project_name']?.toString() ?? '',
      taskTitle: json['task_title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      workDone: json['work_done']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
    );
  }
}
