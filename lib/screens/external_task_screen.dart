import 'package:flutter/material.dart';

import '../models/external_todo.dart';
import '../services/external_todo_service.dart';
import '../widgets/state_views.dart';

/// External Task Feed: data dari REST API JSONPlaceholder.
/// State: LOADING, SUCCESS, EMPTY, ERROR (+ retry).
class ExternalTaskScreen extends StatefulWidget {
  const ExternalTaskScreen({super.key});

  @override
  State<ExternalTaskScreen> createState() => _ExternalTaskScreenState();
}

class _ExternalTaskScreenState extends State<ExternalTaskScreen> {
  final ExternalTodoService _service = ExternalTodoService();

  List<ExternalTodo> _todos = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTodos(); // otomatis mengambil data saat screen dibuka
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  Future<void> _loadTodos({bool simulateFailure = false}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final todos = await _service.fetchTodos(simulateFailure: simulateFailure);
      if (!mounted) return;
      setState(() => _todos = todos);
    } on ExternalTodoException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage =
            'Data eksternal belum dapat dimuat. Periksa koneksi dan coba lagi.';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tugas Eksternal'),
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : () => _loadTodos(),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'fail') _loadTodos(simulateFailure: true);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'fail',
                child: Text('Uji kondisi gagal (endpoint salah)'),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  /// Decision flow seperti materi:
  /// loading -> error + retry -> empty -> success
  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingView(message: 'Mengambil data dari REST API...');
    }
    if (_errorMessage != null) {
      return ErrorView(message: _errorMessage!, onRetry: _loadTodos);
    }
    if (_todos.isEmpty) {
      return const EmptyView(
        icon: Icons.cloud_queue,
        title: 'Belum ada data eksternal',
        subtitle: 'Tarik ke bawah atau tekan muat ulang.',
      );
    }

    final doneCount = _todos.where((t) => t.completed).length;

    return RefreshIndicator(
      onRefresh: _loadTodos,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: _todos.length + 1,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.cloud_done_outlined),
                    title: Text('${_todos.length} tugas dari REST API'),
                    subtitle: Text(
                      '$doneCount selesai • sumber: jsonplaceholder.typicode.com',
                    ),
                  ),
                );
              }

              final todo = _todos[index - 1];
              return Card(
                child: ListTile(
                  leading: Icon(
                    todo.completed
                        ? Icons.check_circle_outline
                        : Icons.radio_button_unchecked,
                  ),
                  title: Text(todo.title),
                  subtitle: Text('Tugas eksternal #${todo.id}'),
                  trailing: Text(todo.completed ? 'Selesai' : 'Terbuka'),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
