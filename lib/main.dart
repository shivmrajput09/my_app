import 'package:flutter/material.dart';
import 'services/api_services.dart';
import 'models/user_model.dart'; // UserModel ko import karna zaroori hai

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: HomeScreen(
        isDarkMode: isDarkMode,
        onThemeChanged: (value) {
          setState(() {
            isDarkMode = value;
          });
        },
      ),
    );
  }
}

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
  // ApiServices ka object (jo tumne banaya hai)
  final ApiServices apiServices = ApiServices();

  // ----------------------------------------------------
  // NAYI STATES (ApiServices ke data ko handle karne ke liye)
  // ----------------------------------------------------
  List<UserModel> usersList = [];
  bool isLoading = false;
  String errorMessage = '';
  int counter = 0; // Tumhara purana counter

  // ----------------------------------------------------
  // API FETCH FUNCTION
  // ----------------------------------------------------
  void fetchUsersData() async {
    setState(() {
      isLoading = true;   // Jab data aana shuru ho, loader on kar do
      errorMessage = '';  // Purana error clear kar do
    });

    try {
      // Tumhare ApiServices wala getUsers() call ho raha hai
      final result = await apiServices.getUsers();
      
      setState(() {
        usersList = result;   // Data mil gaya, list mein save kar liya
        isLoading = false;    // Loading khatam
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString(); // Jo exception ApiServices se aayi, use save kar liya
        isLoading = false;           // Error aane par bhi loading band
      });
    }
  }
  // 1. Ek naya function jo list ko khaali kar dega
void clearUsersData() {
  setState(() {
    usersList = [];       // List ko wapas empty kar diya
    errorMessage = '';    // Agar koi error thi toh use bhi saaf kar diya
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Learning Sequence'),
        actions: [
          Switch(
            value: widget.isDarkMode,
            onChanged: widget.onThemeChanged,
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Text(
            'Counter: $counter',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          // Button jo ab print() ki jagah fetchUsersData() chalayega
          ElevatedButton(
            onPressed: fetchUsersData,
            child: const Text('Get Users'),
          ),
          const SizedBox(height: 10),
          // Clear Users Button
    ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
      onPressed: clearUsersData, // Yeh function list saaf kar dega
      child: const Text('Clear List', style: TextStyle(color: Colors.white)),
    ),
SizedBox(height: 5),
    //create user
    ElevatedButton(onPressed:  (){
      apiServices.createUser();
    }, child:  
  const Text('Create User'),),
SizedBox(height: 5),
    //create user
    ElevatedButton(onPressed:  (){
      apiServices.patchUser(11);
    }, child:  
  const Text(' patch User'),),
SizedBox(height: 5),
    //create user
    ElevatedButton(onPressed:  (){
      apiServices.putUser(1);
    }, child:  
  const Text(' Put User'),),
SizedBox(height: 5),
    //delete user
    ElevatedButton(onPressed:  (){
      apiServices.deleteUser(1);
    }, child:  
  const Text(' Delete User'),),

          // ----------------------------------------------------
          // UI DISPLAY (Loading, Error, ya ListView.builder)
          // ----------------------------------------------------
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(), // 1. Jab data load ho raha ho
                  )
                : errorMessage.isNotEmpty
                    ? Center(
                        child: Text(
                          errorMessage,
                          style: const TextStyle(color: Colors.red, fontSize: 16),
                          textAlign: TextAlign.center,
                        ), // 2. Jab koi error aaye
                      )
                    : usersList.isEmpty
                        ? const Center(
                            child: Text('Click the button to load users.'),
                          ) // 3. Jab list empty ho
                        : ListView.builder(
                            // 4. Jab data successfully aa jaye
                            itemCount: usersList.length,
                            itemBuilder: (context, index) {
                              final user = usersList[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    child: Text(user.id.toString()),
                                  ),
                                  title: Text(user.name), // user ka naam
                                  subtitle: Text(user.email), // user ki email
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
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