import 'package:xtimer/data/database.dart';
import 'package:xtimer/model/task_model.dart';

class TaskManager {
  final DatabaseProvider dbProvider;

  TaskManager({required this.dbProvider});

  Future<void> addNewTask(Task task) async {
    await dbProvider.insert(task);
  }

  Future<List<Task>> loadAllTasks() async {
    return dbProvider.getAll();
  }

  Future<void> deleteTask(Task task) async {
    if (task.id == null) return;   // null-safety 보호
    await dbProvider.delete(task.id!);
  }
}
