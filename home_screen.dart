import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'task_list_screen.dart';
import 'dashboard_screen.dart';
import 'category_screen.dart';

class AppDrawer extends StatelessWidget {
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
          // _buildDrawerItem(context, "Tasks", TaskListScreen()),
          _buildDrawerItem(context, "Projects", ProjectDashboardScreen()),
          _buildDrawerItem(context, "Categories", CategoryScreen()),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, String title, Widget screen) {
    return ListTile(
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => screen),
        );
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? userId;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        setState(() {
          userId = user.uid;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (userId == null || userId!.isEmpty) {
      return Scaffold(
        body: Center(child: Text('No user found. Please login.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("Home")),
      drawer: AppDrawer(),
      body: Center(
        child: Text('Welcome to Task Manager!', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAuth.instance.signInAnonymously(); // Simple demo login
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(),
    );
  }
}
