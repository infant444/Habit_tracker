import 'package:flutter/cupertino.dart';
import 'package:habit_tracker/model/app_settings.dart';
import 'package:habit_tracker/model/habit.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class HabitServices extends ChangeNotifier {
  static late Isar isar;

  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open([
      HabitSchema,
      AppSettingsSchema,
    ], directory: dir.path);
  }

  Future<void> saveFirstLaunchDate() async {
    final existingSetting = await isar.appSettings.where().findFirst();
    if (existingSetting == null) {
      final settings = AppSettings()..firstLaunchDate = DateTime.now();
      await isar.writeTxn(() => isar.appSettings.put(settings));
    }
  }

  Future<DateTime?> getFirstLaunchDate() async {
    final setting = await isar.appSettings.where().findFirst();
    return setting?.firstLaunchDate;
  }

  final List<Habit> currentHabit = [];

  Future<void> addHabit(String habitName) async {
    final newHabit = Habit()..name = habitName;
    await isar.writeTxn(() => isar.habits.put(newHabit));
    readHabit();
  }

  Future<void> readHabit() async {
    List<Habit> fetchedHabit = await isar.habits.where().findAll();
    currentHabit.clear();
    currentHabit.addAll(fetchedHabit);
    notifyListeners();
  }

  Future<void> updateHabitCompletion(int id, bool isCompleted) async {
    final habit = await isar.habits.get(id);
    if (habit != null) {
      await isar.writeTxn(() async {
        if (isCompleted && !habit.completeDate.contains(DateTime.now())) {
          final today = DateTime.now();
          habit.completeDate.add(DateTime(today.year, today.month, today.day));
        } else {
          habit.completeDate.removeWhere(
            (data) =>
                data.year == DateTime.now().year &&
                data.month == DateTime.now().month &&
                data.day == DateTime.now().day,
          );
        }
        await isar.habits.put(habit);
      });
    }
    readHabit();
  }

  Future<void> updateHabitName(int id, String name) async {
    final habit = await isar.habits.get(id);
    if (habit != null) {
      await isar.writeTxn(() async {
        habit.name = name;
        await isar.habits.put(habit);
      });
    }
    readHabit();
  }

  Future<void> deleteHabit(int id) async {
    await isar.writeTxn(() async {
      await isar.habits.delete(id);
    });
    readHabit();
  }
}
