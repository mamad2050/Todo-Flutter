import 'package:hive_flutter/adapters.dart';
import 'package:todo/data/data.dart';
import 'package:todo/data/source/source.dart';

class HiveTaskDataSource implements DataSource<TaskData> {
  final Box<TaskData> box;

  HiveTaskDataSource({required this.box});

  @override
  Future<TaskData> createOrUpdate(TaskData data) async {
    if (data.isInBox) {
      data.save();
    } else {
      data.id = await box.add(data);
    }
    return data;
  }

  @override
  Future<void> delete(TaskData data) async {
    return data.delete();
  }

  @override
  Future<void> deleteAll() {
    return box.clear();
  }

  @override
  Future<void> deleteById(id) {
    return box.delete(id);
  }

  @override
  Future<TaskData> findById(id) async {
    return box.values.firstWhere((element) => element.id == id);
  }

  @override
  Future<List<TaskData>> getAll({String searchKeyword = ''}) async {
    if (searchKeyword.isNotEmpty) {
      return box.values
          .where((task) => task.name.contains(searchKeyword))
          .toList();
    } else {
      return box.values.toList();
    }
  }
}
