
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase initialize
import 'package:firebase_auth/firebase_auth.dart'; // Login, logout aur auth state

import 'firebase_options.dart'; // Firebase platform configuration
import 'auth_screen.dart'; // Login aur Signup screen

import 'service/api_services.dart'; // Existing API service
import 'model/user_model.dart'; // Existing user model

// APP START
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter engine ready

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Firebase initialize
  );

  runApp(const MyApp()); // App start
}

// ROOT APP
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = false; // Existing theme state

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),

      // Firebase login state decide karegi kaunsi screen dikhani hai
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Firebase abhi auth state check kar raha hai
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // User logged in hai to existing HomeScreen
          if (snapshot.hasData) {
            return HomeScreen(
              isDarkMode: isDarkMode,
              onThemeChanged: (value) {
                setState(() {
                  isDarkMode = value; // Existing dark mode toggle
                });
              },
            );
          }

          // User logged out hai to Login/Signup screen
          return const AuthScreen();
        },
      ),
    );
  }
}

// EXISTING HOME SCREEN
class HomeScreen extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  const HomeScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiServices apiServices = ApiServices(); // Existing API service

  List<UserModel> usersList = []; // API users list
  bool isLoading = false; // API loading state
  String errorMessage = ''; // API error message
  int counter = 0; // Existing counter

  // GET USERS
  void fetchUsersData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final result = await apiServices.getUsers();

      if (!mounted) return; // Screen dispose ho chuki ho to stop

      setState(() {
        usersList = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  // CLEAR USERS LIST
  void clearUsersData() {
    setState(() {
      usersList = [];
      errorMessage = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API & Firebase Learning'),
        actions: [
          // LOGOUT BUTTON
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signOut();
                // authStateChanges() automatically AuthScreen dikhayega
              } catch (e) {
                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Logout failed: $e')),
                );
              }
            },
          ),

          // EXISTING DARK MODE SWITCH
          Switch(
            value: widget.isDarkMode,
            onChanged: widget.onThemeChanged,
          ),
        ],
      ),

      body: Column(
        children: [
          const SizedBox(height: 10),

          // EXISTING COUNTER
          Text(
            'Counter: $counter',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),

          // GET USERS
          ElevatedButton(
            onPressed: fetchUsersData,
            child: const Text('Get Users'),
          ),
          const SizedBox(height: 10),

          // CLEAR LIST
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            onPressed: clearUsersData,
            child: const Text(
              'Clear List',
              style: TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(height: 5),

          // CREATE USER
          ElevatedButton(
            onPressed: () {
              apiServices.createUser();
            },
            child: const Text('Create User'),
          ),
          const SizedBox(height: 5),

          // PATCH USER
          ElevatedButton(
            onPressed: () {
              apiServices.patchUser(11);
            },
            child: const Text('Patch User'),
          ),
          const SizedBox(height: 5),

          // PUT USER
          ElevatedButton(
            onPressed: () {
              apiServices.putUser(1);
            },
            child: const Text('Put User'),
          ),
          const SizedBox(height: 5),

          // DELETE USER
          ElevatedButton(
            onPressed: () {
              apiServices.deleteUser(1);
            },
            child: const Text('Delete User'),
          ),

          // EXISTING API RESULTS
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : errorMessage.isNotEmpty
                    ? Center(
                        child: Text(
                          errorMessage,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : usersList.isEmpty
                        ? const Center(
                            child: Text(
                              'Click the button to load users.',
                            ),
                          )
                        : ListView.builder(
                            itemCount: usersList.length,
                            itemBuilder: (context, index) {
                              final user = usersList[index];

                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    child: Text(user.id.toString()),
                                  ),
                                  title: Text(user.name),
                                  subtitle: Text(user.email),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),

      // EXISTING COUNTER BUTTON
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            counter++;
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}