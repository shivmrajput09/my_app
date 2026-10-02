import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class ApiServices {

  // Humne function mein ek optional 'searchName' query parameter le liya
  Future<List<UserModel>> getUsers({String? searchQuery}) async { 
    try {
      
      // 1. QUERY PARAMETERS: 
      // Agar user ne search query di hai, toh usko map mein daal do.
      // Ye URL banayega: https://jsonplaceholder.typicode.com/users?username=Bret
      final Map<String, dynamic> queryParams = {};
      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['username'] = searchQuery;
      }

      // Uri.https use karne se URL aur Query Parameters automatic properly ban jaate hain.
      final uri = Uri.https(
        'jsonplaceholder.typicode.com', 
        '/users', 
        queryParams.isNotEmpty ? queryParams : null,
      );

      // 2. HEADERS:
      // Server ko batane ke liye ki hum JSON format accept kar rahe hain 
      // aur hamare paas authorization token hai.
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // 'Authorization': 'Bearer YOUR_TOKEN_HERE', // Agar token ho toh yahan aayega
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data as List)
            .map((json) => UserModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load users. Status Code: ${response.statusCode}');
      }
      
    } catch (e) {
      throw Exception('Something went Wrong : $e');
    }
  }
}