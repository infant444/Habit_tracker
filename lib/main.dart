import 'package:flutter/material.dart';
import 'package:habit_tracker/Components/home.component.dart';
import 'package:habit_tracker/Services/habit.services.dart';
import 'package:habit_tracker/Theme/theme_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HabitServices.initialize();
  await HabitServices().saveFirstLaunchDate();
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: HabitTracker(),
    ),
  );
}

class HabitTracker extends StatefulWidget {
  const HabitTracker({super.key});

  @override
  State<HabitTracker> createState() => _HabitTrackerState();
}

class _HabitTrackerState extends State<HabitTracker> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeProvider>(context).themeData,
      routes: {'/': (context) => HomePage()},
    );
  }
}
