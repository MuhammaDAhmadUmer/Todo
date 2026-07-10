import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:api_practice/models/task.dart';
import 'package:api_practice/Provider/task.dart';
import 'package:api_practice/Provider/user.dart';
import 'package:api_practice/utils/app_theme.dart';
import 'package:api_practice/views/add_edit_task.dart';
import 'package:api_practice/views/profile.dart';
import 'package:api_practice/widgets/app_widgets.dart';
import 'package:api_practice/widgets/task_card.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _showSearchField = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      taskProvider.setFilter(TaskFilter.values[_tabController.index]);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadTasks());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    final token = Provider.of<UserProvider>(context, listen: false).getToken();
    if (token == null) return;
    await Provider.of<TaskProvider>(context, listen: false).loadTasks(token);
  }

  Future<void> _handleToggle(Task task) async {
    final token = Provider.of<UserProvider>(context, listen: false).getToken();
    if (token == null) return;
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final success = await taskProvider.toggleComplete(token, task);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(taskProvider.error ?? 'Could not update task')),
      );
    }
  }

  Future<void> _handleDelete(Task task) async {
    final token = Provider.of<UserProvider>(context, listen: false).getToken();
    if (token == null || task.id == null) return;
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final success = await taskProvider.deleteTask(token, task.id!);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Task deleted' : (taskProvider.error ?? 'Could not delete task')),
      ),
    );
  }

  Future<void> _handleSearch(String keyword) async {
    final token = Provider.of<UserProvider>(context, listen: false).getToken();
    if (token == null) return;
    await Provider.of<TaskProvider>(context, listen: false).search(token, keyword);
  }

  void _closeSearch() {
    setState(() => _showSearchField = false);
    _searchController.clear();
    Provider.of<TaskProvider>(context, listen: false).clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.getUser().user;

    return Scaffold(
      appBar: AppBar(
        title: _showSearchField
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search tasks...',
                  border: InputBorder.none,
                ),
                onSubmitted: _handleSearch,
                onChanged: (value) {
                  if (value.trim().isEmpty) {
                    Provider.of<TaskProvider>(context, listen: false).clearSearch();
                  }
                },
              )
            : const Text('My Tasks'),
        actions: [
          IconButton(
            tooltip: _showSearchField ? 'Close search' : 'Search',
            icon: Icon(_showSearchField ? Icons.close : Icons.search),
            onPressed: () {
              if (_showSearchField) {
                _closeSearch();
              } else {
                setState(() => _showSearchField = true);
              }
            },
          ),
          if (!_showSearchField)
            IconButton(
              tooltip: 'Profile',
              icon: CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                child: Text(
                  (user?.name?.isNotEmpty == true)
                      ? user!.name![0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileView()),
                );
              },
            ),
          const SizedBox(width: 12),
        ],
        bottom: _showSearchField
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Consumer<TaskProvider>(
                  builder: (context, taskProvider, _) => TabBar(
                    controller: _tabController,
                    tabs: [
                      Tab(text: 'All (${taskProvider.totalCount})'),
                      Tab(text: 'Active (${taskProvider.activeCount})'),
                      Tab(text: 'Done (${taskProvider.completedCount})'),
                    ],
                  ),
                ),
              ),
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, _) {
          // Search mode takes over the body entirely.
          if (taskProvider.isSearching) {
            if (taskProvider.searchLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (taskProvider.searchResults.isEmpty) {
              return const EmptyState(
                icon: Icons.search_off,
                title: 'No matches',
                subtitle: 'Try a different keyword.',
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: taskProvider.searchResults.length,
              itemBuilder: (context, index) {
                final task = taskProvider.searchResults[index];
                return TaskCard(
                  task: task,
                  onToggle: (_) => _handleToggle(task),
                  onEdit: () => showAddEditTaskSheet(context, task: task),
                  onDelete: () => _handleDelete(task),
                );
              },
            );
          }

          if (taskProvider.isLoading && taskProvider.tasks.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (taskProvider.error != null && taskProvider.tasks.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: AppColors.danger),
                    const SizedBox(height: 12),
                    Text(
                      taskProvider.error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadTasks,
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          final tasks = taskProvider.filteredTasks;

          if (tasks.isEmpty) {
            return RefreshIndicator(
              onRefresh: _loadTasks,
              child: ListView(
                children: const [
                  SizedBox(height: 120),
                  EmptyState(
                    icon: Icons.task_alt,
                    title: 'No tasks here',
                    subtitle: 'Tap the + button below to add your first task.',
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadTasks,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return TaskCard(
                  task: task,
                  onToggle: (_) => _handleToggle(task),
                  onEdit: () => showAddEditTaskSheet(context, task: task),
                  onDelete: () => _handleDelete(task),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAddEditTaskSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }
}
