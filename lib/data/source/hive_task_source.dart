import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_list/data/data.dart';
import 'package:todo_list/data/source/source.dart';

class HiveTaskDataSource implements DataSource<TaskEntity> {
  final Box<TaskEntity> box;

  HiveTaskDataSource(this.box);

  @override
  Future<TaskEntity> createOrUpdate(TaskEntity data) async {
    if (data.isInBox) {
      data.save();
    } else {
      data.id = await box.add(data);
    }
    return data;
  }

  @override
  Future<void> delete(TaskEntity data) async {
    return data.delete();
  }

  @override
  Future<void> deleteAll() {
    return box.clear();
  }

  @override
  Future<void> deleteById(id) async {
    return box.delete(id);
  }

  @override
  Future<TaskEntity> findById(id) async {
    return box.values.firstWhere((element) => element.id == id);
  }

  @override
  Future<List<TaskEntity>> getAll({String searchKeyword = ''}) async {
    final allTasks = box.values.toList();
    // If the search keyword is provided, filter the tasks
    if (searchKeyword.isNotEmpty) {
      return allTasks
          .where((task) =>
              task.name.toLowerCase().contains(searchKeyword.toLowerCase()))
          .toList();
    }
    return allTasks; // Otherwise, return all tasks
  }
}
