
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/reports_controller.dart';
import '../models/work_report.dart';

class ReportFormView extends StatefulWidget {
  const ReportFormView({
    super.key,
    this.report,
  });

  final WorkReport? report;

  @override
  State<ReportFormView> createState() => _ReportFormViewState();
}

class _ReportFormViewState extends State<ReportFormView> {
  final _formKey = GlobalKey<FormState>();
  final ReportsController controller = Get.find<ReportsController>();

  final _project = TextEditingController();
  final _task = TextEditingController();
  final _description = TextEditingController();
  final _workDone = TextEditingController();

  DateTime _date = DateTime.now();

  File? _attachment;
  String? _attachmentName;

  bool get _isEditing => widget.report != null;

  String get _dateText {
    final year = _date.year.toString().padLeft(4, '0');
    final month = _date.month.toString().padLeft(2, '0');
    final day = _date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  @override
  void initState() {
    super.initState();

    final report = widget.report;

    if (report != null) {
      _project.text = report.projectName;
      _task.text = report.taskTitle;
      _description.text = report.description;
      _workDone.text = report.workDone;

      if (report.reportDate != null) {
        final parsedDate = DateTime.tryParse(report.reportDate!);
        if (parsedDate != null) {
          _date = parsedDate;
        }
      }
    }
  }

  Future<void> _chooseDate() async {
    final today = DateTime.now();

    final selected = await showDatePicker(
      context: context,
      initialDate: _date.isAfter(today) ? today : _date,
      firstDate: DateTime(2020),
      lastDate: today,
    );

    if (selected != null && mounted) {
      setState(() {
        _date = selected;
      });
    }
  }

  Future<void> _pickAttachment() async {
    try {
      final PlatformFile? pickedFile = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx'],
      );

      if (pickedFile == null) {
        return;
      }

      final String? path = pickedFile.path;

      if (path == null) {
        Get.snackbar(
          'File Error',
          'The selected file path is unavailable.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final String? extension = pickedFile.extension?.toLowerCase();

      if (extension != 'pdf' && extension != 'docx') {
        Get.snackbar(
          'Unsupported File',
          'Please select a PDF or DOCX file.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      setState(() {
        _attachment = File(path);
        _attachmentName = pickedFile.name;
      });
    } catch (e) {
      Get.snackbar(
        'File Selection Failed',
        'Unable to select the file. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Widget _attachmentField() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E8F1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Form File',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A5490),
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Upload a PDF or DOCX document.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 12),
          if (_attachmentName != null) ...[
            Row(
              children: [
                const Icon(
                  Icons.insert_drive_file_outlined,
                  color: Color(0xFF178FB4),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _attachmentName!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  tooltip: 'Remove file',
                  onPressed: () {
                    setState(() {
                      _attachment = null;
                      _attachmentName = null;
                    });
                  },
                  icon: const Icon(
                    Icons.close,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          OutlinedButton.icon(
            onPressed: _pickAttachment,
            icon: const Icon(Icons.upload_file_outlined),
            label: Text(
              _attachmentName == null ? 'Choose file' : 'Change file',
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF1A5490),
              side: const BorderSide(color: Color(0xFF1A5490)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    if (!_isEditing && _attachment == null) {
      Get.snackbar(
        'Attachment Required',
        'Please select a PDF or DOCX file.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final report = widget.report;

    if (report != null && report.id == null) {
      Get.snackbar(
        'Update Failed',
        'This report does not have a valid ID.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          _isEditing ? 'Save report changes?' : 'Submit work report?',
        ),
        content: const Text(
          'Please confirm that the report details are correct.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Review'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(_isEditing ? 'Save changes' : 'Submit'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final bool success;

    if (report == null) {
      success = await controller.submitReport(
        reportDate: _dateText,
        projectName: _project.text,
        taskTitle: _task.text,
        description: _description.text,
        workDone: _workDone.text,
        attachment: _attachment,
      );
    } else {
      success = await controller.updateReport(
        reportId: report.id!,
        reportDate: _dateText,
        projectName: _project.text,
        taskTitle: _task.text,
        description: _description.text,
        workDone: _workDone.text,
      );
    }

    if (success && mounted) {
      Get.back();

      Get.snackbar(
        _isEditing ? 'Report Updated' : 'Report Submitted',
        _isEditing
            ? 'The server accepted the report update.'
            : 'The server accepted the report.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Widget _field(
      String label,
      TextEditingController textController, {
        int lines = 1,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: textController,
        maxLines: lines,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          labelText: label,
          alignLabelWithHint: lines > 1,
          filled: true,
          fillColor: const Color(0xFFF5F8FC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E8F1)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E8F1)),
          ),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return '$label is required';
          }
          return null;
        },
      ),
    );
  }

  @override
  void dispose() {
    _project.dispose();
    _task.dispose();
    _description.dispose();
    _workDone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FC),
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Work Report' : 'New Work Report'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A5490),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              _isEditing ? 'Update work summary' : 'Daily work summary',
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A5490),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _isEditing
                  ? 'Review and update your report details.'
                  : 'Enter the work you completed today.',
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 24),
            InkWell(
              onTap: _chooseDate,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Report date',
                  prefixIcon: const Icon(Icons.calendar_today_outlined),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(_dateText),
              ),
            ),
            const SizedBox(height: 16),
            _field('Project name', _project),
            _field('Task title', _task),
            _field('Description', _description, lines: 3),
            _field('Work done', _workDone, lines: 4),
            if (!_isEditing) _attachmentField(),
            Obx(
                  () => SizedBox(
                height: 50,
                child: FilledButton(
                  onPressed:
                  controller.isSubmitting.value ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1A5490),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: controller.isSubmitting.value
                      ? const SizedBox(
                    height: 21,
                    width: 21,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : Text(
                    _isEditing
                        ? 'Save changes'
                        : 'Confirm and submit',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
