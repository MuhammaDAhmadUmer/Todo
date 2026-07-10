import 'package:flutter/material.dart';
import 'package:api_practice/models/task.dart';
import 'package:api_practice/Provider/task.dart';
import 'package:api_practice/Provider/user.dart';
import 'package:api_practice/utils/app_theme.dart';
import 'package:api_practice/widgets/app_widgets.dart';
import 'package:provider/provider.dart';

/// Opens a bottom sheet to add a new task, or edit an existing one
/// when [task] is provided.
Future<void> showAddEditTaskSheet(BuildContext context, {Task? task}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _AddEditTaskSheet(task: task),
  );
}

class _AddEditTaskSheet extends StatefulWidget {
  final Task? task;
  const _AddEditTaskSheet({this.task});

  @override
  State<_AddEditTaskSheet> createState() => _AddEditTaskSheetState();
}

class _AddEditTaskSheetState extends State<_AddEditTaskSheet> {
  late final TextEditingController controller;
  bool isSaving = false;

  bool get isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.task?.description ?? '');
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final description = controller.text.trim();
    if (description.isEmpty) return;

    setState(() => isSaving = true);

    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final token = Provider.of<UserProvider>(context, listen: false).getToken();

    if (token == null) {
      setState(() => isSaving = false);
      return;
    }

    bool success;
    if (isEditing) {
      success = await taskProvider.updateTask(
        token,
        widget.task!.id ?? '',
        description,
      );
    } else {
      success = await taskProvider.addTask(token, description);
    }

    if (!mounted) return;
    setState(() => isSaving = false);

    if (success) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(taskProvider.error ?? 'Something went wrong')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              isEditing ? 'Edit task' : 'New task',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            AppTextField(
              controller: controller,
              label: 'What needs to be done?',
              icon: Icons.task_alt_outlined,
            ),
            const SizedBox(height: 20),
            LoadingButton(
              isLoading: isSaving,
              label: isEditing ? 'Save Changes' : 'Add Task',
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
