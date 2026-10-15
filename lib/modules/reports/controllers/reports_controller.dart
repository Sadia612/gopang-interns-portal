import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/work_report.dart';
import '../services/reports_service.dart';

class ReportsController extends GetxController {
  final ReportsService _service = ReportsService();

  final reports = <WorkReport>[].obs;
  final isLoading = false.obs;
  final isSubmitting = false.obs;
  final errorMessage = ''.obs;

  final searchController = TextEditingController();
  final fromController = TextEditingController();
  final toController = TextEditingController();

  final selectedStatus = 'all'.obs;
  final currentPage = 1.obs;
  final totalReports = 0.obs;
  final lastPage = 1.obs;

  @override
  void onInit() {
    super.onInit();
    loadReports();
  }

  Future<void> loadReports({int page = 1}) async {
    if (isLoading.value) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final status = selectedStatus.value == 'all'
          ? null
          : selectedStatus.value;

      final response = await _service.getReports(
        status: status,
        search: searchController.text.trim(),
        from: fromController.text.trim(),
        to: toController.text.trim(),
        page: page,
      );

      final payload = response['reports'];

      final Map<String, dynamic> pagination =
      payload is Map<String, dynamic> ? payload : {};

      final rawData = pagination['data'];
      final items = rawData is List ? rawData : <dynamic>[];

      reports.assignAll(
        items
            .whereType<Map>()
            .map(
              (item) => WorkReport.fromJson(
            Map<String, dynamic>.from(item),
          ),
        ),
      );

      currentPage.value =
          int.tryParse('${pagination['current_page'] ?? page}') ?? page;

      lastPage.value =
          int.tryParse('${pagination['last_page'] ?? 1}') ?? 1;

      totalReports.value =
          int.tryParse('${pagination['total'] ?? items.length}') ??
              items.length;
    } on ReportsApiException catch (e) {
      errorMessage.value = e.message;
    } catch (_) {
      errorMessage.value =
      'Failed to load reports. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> submitReport({
    required String reportDate,
    required String projectName,
    required String taskTitle,
    required String description,
    required String workDone,
    File? attachment,
  }) async {
    if (isSubmitting.value) return false;

    isSubmitting.value = true;

    try {
      await _service.createReport(
        {
          'report_date': reportDate,
          'project_name': projectName.trim(),
          'task_title': taskTitle.trim(),
          'description': description.trim(),
          'work_done': workDone.trim(),
        },
        attachment: attachment,
      );

      await loadReports(page: 1);
      return true;
    } on ReportsApiException catch (e) {
      Get.snackbar(
        'Report submission failed',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } catch (_) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred while submitting the report.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> updateReport({
    required int reportId,
    required String reportDate,
    required String projectName,
    required String taskTitle,
    required String description,
    required String workDone,
  }) async {
    if (isSubmitting.value) return false;

    isSubmitting.value = true;

    try {
      await _service.updateReport(reportId, {
        'report_date': reportDate,
        'project_name': projectName.trim(),
        'task_title': taskTitle.trim(),
        'description': description.trim(),
        'work_done': workDone.trim(),
      });

      await loadReports(page: currentPage.value);
      return true;
    } on ReportsApiException catch (e) {
      Get.snackbar(
        'Update failed',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } catch (_) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred while updating the report.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> openReportDetails(int reportId) async {
    try {
      final response = await _service.getReportDetails(reportId);

      dynamic reportData =
          response['report'] ?? response['data'] ?? response;

      if (reportData is Map && reportData['report'] is Map) {
        reportData = reportData['report'];
      }

      if (reportData is! Map) {
        throw const ReportsApiException(
          'The server returned an unsupported report format.',
        );
      }

      final report = WorkReport.fromJson(
        Map<String, dynamic>.from(reportData),
      );

      await Get.dialog<void>(
        AlertDialog(
          title: const Text('Report Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _detailRow(
                  'Report ID',
                  report.id?.toString() ?? 'N/A',
                ),
                _detailRow(
                  'Report Date',
                  report.reportDate ?? 'N/A',
                ),
                _detailRow(
                  'Project',
                  report.projectName.isEmpty
                      ? 'N/A'
                      : report.projectName,
                ),
                _detailRow(
                  'Task',
                  report.taskTitle.isEmpty
                      ? 'N/A'
                      : report.taskTitle,
                ),
                _detailRow(
                  'Description',
                  report.description.isEmpty
                      ? 'N/A'
                      : report.description,
                ),
                _detailRow(
                  'Work Done',
                  report.workDone.isEmpty
                      ? 'N/A'
                      : report.workDone,
                ),
                _detailRow(
                  'Status',
                  report.status.isEmpty
                      ? 'N/A'
                      : report.status,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back<void>(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } on ReportsApiException catch (e) {
      Get.snackbar(
        'Unable to load report',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      Get.snackbar(
        'Error',
        'Unable to open report details. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          SelectableText(value),
        ],
      ),
    );
  }

  Future<void> confirmDeleteReport(int reportId) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Report?'),
        content: const Text(
          'Are you sure you want to delete this report? '
              'This action may not be reversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back<bool>(result: false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Get.back<bool>(result: true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _service.deleteReport(reportId);

      Get.snackbar(
        'Success',
        'Report deleted successfully.',
        snackPosition: SnackPosition.BOTTOM,
      );

      final pageToLoad = currentPage.value > 1 &&
          reports.length == 1
          ? currentPage.value - 1
          : currentPage.value;

      await loadReports(page: pageToLoad);
    } on ReportsApiException catch (e) {
      Get.snackbar(
        'Delete failed',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      Get.snackbar(
        'Error',
        'Unable to delete the report. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    fromController.dispose();
    toController.dispose();
    _service.dispose();
    super.onClose();
  }
}