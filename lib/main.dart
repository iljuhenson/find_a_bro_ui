import 'package:find_a_bro/screens/find_people_screen.dart';
import 'package:find_a_bro/widgets/custom_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => TabManagementState(),
      child: const MainApp(),
    ),
  );
}

class TabManagementState extends ChangeNotifier {
  int index = 0;

  void switchToTab(int index) {
    this.index = index;
    notifyListeners();
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    var state = context.watch<TabManagementState>();
    int tabIndex = state.index;

    List<Widget> tabs = <Widget>[
      Placeholder(),
      FindPeopleScreen(),
      Placeholder(),
      Placeholder()
    ];

    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreen),
      ),
      home: Scaffold(
        body: tabs[tabIndex],
        bottomNavigationBar: CustomBottomNavigationBar(),
      ),
    );
  }
}
