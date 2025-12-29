import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models/outfit_item.dart';

class RemoteDatabaseService {
  // Use 10.0.2.2 for Android Emulator to connect to localhost on your PC
  static const String _baseUrl = "http://10.0.2.2/php_api/api.php";

  Future<void> saveUser(Map<String, dynamic> user) async {
    try {
      print("Syncing user to remote: ${user['email']}");
      final response = await http.post(
        Uri.parse("$_baseUrl?action=save_user"),
        body: jsonEncode(user),
        headers: {"Content-Type": "application/json"},
      );
      _handleResponse(response);
    } catch (e) {
      print("Remote Connection failed (User): $e");
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print("Attempting remote login: $email");
      final response = await http.post(
        Uri.parse("$_baseUrl?action=login"),
        body: jsonEncode({'email': email, 'password': password}),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("Remote Login failed: $e");
    }
    return {'success': false, 'error': 'Connection failed'};
  }

  Future<void> addFavorite(Map<String, dynamic> outfit) async {
    try {
      print("Syncing favorite to remote: ${outfit['title']}");
      final response = await http.post(
        Uri.parse("$_baseUrl?action=add_favorite"),
        body: jsonEncode(outfit),
        headers: {"Content-Type": "application/json"},
      );
      _handleResponse(response);
    } catch (e) {
      print("Remote Connection failed (Favorite): $e");
    }
  }

  Future<void> createOrder(
      Map<String, dynamic> order, List<Map<String, dynamic>> items) async {
    try {
      print("Syncing order to remote for: ${order['user_email']}");
      final payload = {
        "order": order,
        "items": items,
      };

      final response = await http.post(
        Uri.parse("$_baseUrl?action=create_order"),
        body: jsonEncode(payload),
        headers: {"Content-Type": "application/json"},
      );
      _handleResponse(response);
    } catch (e) {
      print("Remote Connection failed (Order): $e");
    }
  }

  void _handleResponse(http.Response response) {
    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          print("Remote Sync Successful: ${response.body}");
        } else {
          print(
              "Remote Sync Failed (Logic): ${data['error'] ?? response.body}");
        }
      } catch (e) {
        print("Remote Response wasn't valid JSON: ${response.body}");
      }
    } else {
      print(
          "Remote Server Error (HTTP ${response.statusCode}): ${response.body}");
    }
  }

  Future<List<OutfitItem>> getProducts(String? target) async {
    try {
      final uri =
          Uri.parse("$_baseUrl?action=get_products&target=${target ?? ''}");
      print("Fetching products from: $uri");

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> productsJson = data['products'];
          return productsJson.map((json) {
            return OutfitItem.fromMap(json);
          }).toList();
        }
      }
    } catch (e) {
      print("Error fetching products: $e");
    }
    return [];
  }
}
