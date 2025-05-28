import 'package:flutter/material.dart';
import 'category_screen.dart';
import 'dashboard_screen.dart';
import 'task_list_screen.dart';

class AppDrawer extends StatelessWidget {
  final String currentScreen;

  const AppDrawer({super.key, required this.currentScreen});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue[800]),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                "Task Manager",
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
          ),
          _buildDrawerItem(
              context, "Tasks", TaskListScreen(), currentScreen == "Tasks"),
          _buildDrawerItem(context, "Projects", ProjectDashboardScreen(),
              currentScreen == "Projects"),
          _buildDrawerItem(context, "Categories", CategoryScreen(),
              currentScreen == "Categories"),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
      BuildContext context, String title, Widget screen, bool isSelected) {
    return ListTile(
      title: Text(title),
      selected: isSelected,
      onTap: () {
        Navigator.pop(context);
        if (!isSelected) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => screen),
          );
        }
      },
    );
  }
}
