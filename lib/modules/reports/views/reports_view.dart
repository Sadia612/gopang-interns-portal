
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/reports_controller.dart';
import '../widgets/report_card.dart';
import 'report_form_view.dart';

class ReportsView extends StatelessWidget {
  ReportsView({super.key});

  final ReportsController controller =
  Get.isRegistered<ReportsController>()
      ? Get.find<ReportsController>()
      : Get.put(ReportsController());

  static const Color navy = Color(0xFF1A5490);
  static const Color background = Color(0xFFF5F8FC);

  Future<void> _pickDate({
    required BuildContext context,
    required bool isFrom,
  }) async {
    final now = DateTime.now();

    final selected = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2020),
      lastDate: now.add(const Duration(days: 365)),
    );

    if (selected == null) return;

    final value =
        '${selected.year.toString().padLeft(4, '0')}-'
        '${selected.month.toString().padLeft(2, '0')}-'
        '${selected.day.toString().padLeft(2, '0')}';

    if (isFrom) {
      controller.fromController.text = value;
    } else {
      controller.toController.text = value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text('Daily Work Reports'),
        backgroundColor: Colors.white,
        foregroundColor: navy,
        elevation: 0,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => controller.loadReports(
            page: controller.currentPage.value,
          ),
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Work history',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: navy,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Review your submitted daily reports.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: () {
                      Get.to(() => const ReportFormView());
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('New report'),
                    style: FilledButton.styleFrom(
                      backgroundColor: navy,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Obx(
                    () => Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF1A5490),
                        Color(0xFF178FB4),
                        Color(0xFF2BB6C6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.description_outlined,
                        color: Colors.white,
                        size: 30,
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Text(
                          'Reports found',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Text(
                        '${controller.totalReports.value}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 27,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFE5ECF4),
                  ),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: controller.searchController,
                      onSubmitted: (_) => controller.loadReports(page: 1),
                      decoration: InputDecoration(
                        hintText: 'Search reports...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                          tooltip: 'Search',
                          onPressed: () => controller.loadReports(page: 1),
                          icon: const Icon(Icons.arrow_forward),
                        ),
                        filled: true,
                        fillColor: background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Obx(
                          () => DropdownButtonFormField<String>(
                        value: controller.selectedStatus.value,
                        decoration: InputDecoration(
                          labelText: 'Status',
                          filled: true,
                          fillColor: background,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'all',
                            child: Text('All statuses'),
                          ),
                          DropdownMenuItem(
                            value: 'pending',
                            child: Text('Pending'),
                          ),
                          DropdownMenuItem(
                            value: 'approved',
                            child: Text('Approved'),
                          ),
                          DropdownMenuItem(
                            value: 'rejected',
                            child: Text('Rejected'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          controller.selectedStatus.value = value;
                          controller.loadReports(page: 1);
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller.fromController,
                            readOnly: true,
                            onTap: () => _pickDate(
                              context: context,
                              isFrom: true,
                            ),
                            decoration: InputDecoration(
                              labelText: 'From date',
                              hintText: 'YYYY-MM-DD',
                              suffixIcon: const Icon(
                                Icons.calendar_today_outlined,
                                size: 18,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: controller.toController,
                            readOnly: true,
                            onTap: () => _pickDate(
                              context: context,
                              isFrom: false,
                            ),
                            decoration: InputDecoration(
                              labelText: 'To date',
                              hintText: 'YYYY-MM-DD',
                              suffixIcon: const Icon(
                                Icons.calendar_today_outlined,
                                size: 18,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              controller.searchController.clear();
                              controller.fromController.clear();
                              controller.toController.clear();
                              controller.selectedStatus.value = 'all';
                              controller.loadReports(page: 1);
                            },
                            child: const Text('Clear filters'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton(
                            onPressed: () => controller.loadReports(page: 1),
                            style: FilledButton.styleFrom(
                              backgroundColor: navy,
                            ),
                            child: const Text('Apply filters'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Obx(() {
                if (controller.isLoading.value &&
                    controller.reports.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: CircularProgressIndicator(color: navy),
                    ),
                  );
                }

                if (controller.errorMessage.value.isNotEmpty &&
                    controller.reports.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.cloud_off_outlined,
                          size: 36,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          controller.errorMessage.value,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () => controller.loadReports(
                            page: controller.currentPage.value,
                          ),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Try again'),
                        ),
                      ],
                    ),
                  );
                }

                if (controller.reports.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 35,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                      children: [
                        Icon(
                          Icons.description_outlined,
                          size: 42,
                          color: Color(0xFF94A3B8),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'No reports found',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: navy,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Try changing the filters or create a new report.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...controller.reports.map(
                          (report) => ReportCard(
                        report: report,
                        onView: () {
                          if (report.id != null) {
                            controller.openReportDetails(report.id!);
                          }
                        },
                        onEdit: () {
                          Get.to(() => ReportFormView(report: report));
                        },
                        onDelete: () {
                          if (report.id != null) {
                            controller.confirmDeleteReport(report.id!);
                          }
                        },
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
