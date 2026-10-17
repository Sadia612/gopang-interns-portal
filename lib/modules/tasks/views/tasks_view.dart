import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class TasksView extends StatefulWidget {
  const TasksView({super.key});

  @override
  State<TasksView> createState() => _TasksViewState();
}

class _TasksViewState extends State<TasksView> {
  static const String _baseUrl = 'https://portal.gopangitsolution.com';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const Duration _timeout = Duration(seconds: 20);

  static const List<String> _statuses = [
    'todo',
    'in_progress',
    'review',
    'done',
  ];

  static const Map<String, Color> _statusColors = {
    'todo': Color(0xFF64748B),
    'in_progress': Color(0xFF178FB4),
    'review': Color(0xFF7652E8),
    'done': Color(0xFF16866A),
  };

  bool _isLoading = true;
  bool _isUpdatingStatus = false;
  String? _error;
  Map<String, dynamic> _columns = {};
  int _total = 0;
  int _done = 0;
  String _selectedStatus = 'todo';

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final token = await _storage.read(key: 'auth_token');

      if (token == null || token.trim().isEmpty) {
        throw Exception('Your session has expired. Please sign in again.');
      }

      final response = await http
          .get(
        Uri.parse('$_baseUrl/api/tasks'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      )
          .timeout(_timeout);

      dynamic decoded;
      try {
        decoded = jsonDecode(response.body);
      } on FormatException {
        if (response.statusCode < 200 || response.statusCode >= 300) {
          throw Exception('Unable to retrieve task information at this time.');
        }
        rethrow;
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final message = decoded is Map
            ? decoded['message']?.toString()
            : null;
        throw Exception(
          message ?? 'Unable to retrieve task information at this time.',
        );
      }

      if (decoded is! Map || decoded['ok'] != true) {
        throw Exception('Invalid server response received.');
      }

      final rawColumns = decoded['columns'];
      if (rawColumns is! Map) {
        throw Exception('Task board structure was not found.');
      }

      final parsedColumns = <String, dynamic>{};
      for (final key in _statuses) {
        final column = rawColumns[key];
        if (column is Map) {
          parsedColumns[key] = Map<String, dynamic>.from(column);
        }
      }

      if (!mounted) return;

      final computedTotal = _statuses.fold<int>(
        0,
            (sum, key) => sum + _tasksForFrom(parsedColumns, key).length,
      );

      final computedDone = _tasksForFrom(parsedColumns, 'done').length;

      setState(() {
        _columns = parsedColumns;
        _total = computedTotal;
        _done = computedDone;
        _isLoading = false;
      });
    } on TimeoutException {
      _showError('The request timed out. Please check your connection.');
    } on SocketException {
      _showError('Network unavailable. Please verify your connection.');
    } on FormatException {
      _showError('An unexpected data format was received.');
    } catch (e) {
      _showError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _updateTaskStatus(dynamic task, String newStatus) async {
    final taskId = task is Map ? task['id'] : null;
    if (taskId == null) return;

    setState(() => _isUpdatingStatus = true);

    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) throw Exception('Session expired.');

      final response = await http.post(
        Uri.parse('$_baseUrl/api/tasks/$taskId/status'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'status': newStatus}),
      ).timeout(_timeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        await _loadTasks();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Task moved to ${_labelFor(newStatus)}'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        throw Exception('Failed to update task status.');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdatingStatus = false);
    }
  }

  List<dynamic> _tasksForFrom(Map<String, dynamic> columns, String key) {
    final column = columns[key];
    if (column is! Map) return [];
    final tasks = column['tasks'];
    return tasks is List ? tasks : [];
  }

  void _showError(String message) {
    if (!mounted) return;
    setState(() {
      _error = message;
      _isLoading = false;
    });
  }

  List<dynamic> _tasksFor(String key) => _tasksForFrom(_columns, key);

  String _labelFor(String key) {
    switch (key) {
      case 'todo':
        return 'New';
      case 'in_progress':
        return 'In Progress';
      case 'review':
        return 'Review';
      case 'done':
        return 'Completed';
      default:
        return key;
    }
  }

  String _cleanTitle(dynamic task) {
    final rawTitle = task is Map
        ? (task['title'] ?? task['name'] ?? 'Work Item').toString()
        : task.toString();

    final cleaned = rawTitle
        .replaceAll(RegExp(r'\bapi\b', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    return cleaned.isEmpty ? 'Work Item' : cleaned;
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF1A5490);
    const background = Color(0xFFF5F8FC);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'My Tasks',
          style: TextStyle(
            color: primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh tasks',
            onPressed: _isLoading ? null : _loadTasks,
            icon: const Icon(Icons.refresh_rounded, color: primary),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _loadTasks,
            child: _buildBody(primary),
          ),
          if (_isUpdatingStatus)
            Container(
              color: Colors.black12,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildBody(Color primary) {
    if (_isLoading) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 180),
          Center(child: CircularProgressIndicator()),
          SizedBox(height: 16),
          Center(
            child: Text(
              'Loading workspace tasks...',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
          ),
        ],
      );
    }

    if (_error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 100),
          const Icon(
            Icons.cloud_off_rounded,
            size: 54,
            color: Colors.blueGrey,
          ),
          const SizedBox(height: 16),
          const Text(
            'Unable to Load Tasks',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 18),
          Center(
            child: ElevatedButton.icon(
              onPressed: _loadTasks,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A5490), Color(0xFF178FB4)],
            ),
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.task_alt_rounded,
                color: Colors.white,
                size: 34,
              ),
              SizedBox(height: 14),
              Text(
                'My Task Board',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Track and manage your assigned work items',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: _summaryCard(
                label: 'Total Tasks',
                value: _total,
                icon: Icons.assignment_outlined,
                color: primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _summaryCard(
                label: 'Completed',
                value: _done,
                icon: Icons.check_circle_outline_rounded,
                color: const Color(0xFF16866A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'Work Items',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final key in _statuses)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: DragTarget<Object>(
                    onAcceptWithDetails: (details) {
                      _updateTaskStatus(details.data, key);
                    },
                    builder: (context, candidateData, rejectedData) {
                      final isSelected = _selectedStatus == key;
                      final isHovered = candidateData.isNotEmpty;
                      return ChoiceChip(
                        label: Text('${_labelFor(key)} (${_tasksFor(key).length})'),
                        selected: isSelected || isHovered,
                        onSelected: (_) {
                          setState(() => _selectedStatus = key);
                        },
                        selectedColor: _statusColors[key]!.withValues(alpha: 0.20),
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          color: (isSelected || isHovered)
                              ? _statusColors[key]
                              : const Color(0xFF64748B),
                          fontWeight: FontWeight.w700,
                        ),
                        side: BorderSide(
                          color: (isSelected || isHovered)
                              ? _statusColors[key]!
                              : const Color(0xFFE2E8F0),
                          width: isHovered ? 2 : 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        showCheckmark: false,
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _buildSelectedTasks(primary),
      ],
    );
  }

  Widget _summaryCard({
    required String label,
    required int value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE3EAF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            '$value',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedTasks(Color primary) {
    final tasks = _tasksFor(_selectedStatus);
    final statusColor = _statusColors[_selectedStatus]!;

    if (tasks.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE3EAF2)),
        ),
        child: Column(
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.task_rounded,
                size: 32,
                color: statusColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No ${_labelFor(_selectedStatus).toLowerCase()} tasks',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'There are no active items assigned in this section.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _isLoading ? null : _loadTasks,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Refresh Workspace'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: tasks.map((task) {
        final title = _cleanTitle(task);
        final description = task is Map
            ? (task['description'] ?? task['details'])?.toString()
            : null;

        Widget cardContent = Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE3EAF2)),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  Icons.drag_indicator_rounded,
                  color: statusColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    if (description != null && description.trim().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _labelFor(_selectedStatus),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

        return LongPressDraggable<Object>(
          data: task as Object,
          feedback: Material(
            color: Colors.transparent,
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 32,
              child: Opacity(
                opacity: 0.85,
                child: cardContent,
              ),
            ),
          ),
          childWhenDragging: Opacity(
            opacity: 0.3,
            child: cardContent,
          ),
          child: cardContent,
        );
      }).toList(),
    );
  }
}