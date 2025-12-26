import 'package:hive/hive.dart';

part 'todo_model.g.dart';

@HiveType(typeId: 0)
class TodoModel extends HiveObject {
  @HiveField(0)
  late String title;

  @HiveField(1)
  late bool isDone;

  TodoModel({required this.title, this.isDone = false});
}
