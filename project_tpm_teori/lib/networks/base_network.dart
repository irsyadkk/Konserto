import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:project_tpm_teori/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BaseNetwork {
  static const String baseUrl =
      'https://api-konser-559917148272.us-central1.run.app/';

  // LOGIN
  static Future<User> loginUser(
      String endpoint, Map<String, dynamic> data) async {
    final response = await http.post(Uri.parse(baseUrl + endpoint),
        headers: {
          'content-type': 'application/json',
        },
        body: jsonEncode(data));
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final accessToken = body['accessToken'];
      final user = body['safeUserData'];
      if (accessToken != null && user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', accessToken);
        await prefs.setInt('user_id', user['id']);
        await prefs.setString('user_email', user['email']);
        await prefs.setInt('user_umur', user['umur']);
        await prefs.setString('user_nama', user['nama']);
        return User.fromJson(user, accessToken);
      } else {
        throw Exception("Token atau data tidak ada");
      }
    } else if (response.statusCode == 401) {
      throw Exception("Username atau password salah");
    } else {
      throw Exception("Username atau password salah${response.statusCode}");
    }
  }

  // LOGOUT
  static Future<void> logoutUser(String endpoint) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await http.delete(Uri.parse(baseUrl + endpoint));
  }

  // GET
  static Future<List<dynamic>> getData(String endpoint) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final response = await http.get(Uri.parse(baseUrl + endpoint), headers: {
      'content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'] ?? [];
    } else {
      throw Exception('Failed to load data...${response.statusCode}');
    }
  }

  // GET BY EMAIL RETURN LIST
  static Future<List<dynamic>> getDataListByEmail(
      String endpoint, String email) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final response =
        await http.get(Uri.parse('$baseUrl$endpoint/$email'), headers: {
      'content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'] ?? [];
    } else {
      throw Exception('Failed to load data...${response.statusCode}');
    }
  }

  // GET BY EMAIL
  static Future<Map<String, dynamic>> getDataByEmail(
      String endpoint, String email) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final response =
        await http.get(Uri.parse('$baseUrl$endpoint/$email'), headers: {
      'content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'] ?? {};
    } else {
      throw Exception('Failed to load data...${response.statusCode}');
    }
  }

  // DETAIL
  static Future<Map<String, dynamic>> getDetailData(
      String endpoint, int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final response =
        await http.get(Uri.parse('$baseUrl$endpoint/$id'), headers: {
      'content-type': 'application/json',
      'Authorization': 'Bearer $token',
    });
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'] ?? {};
    } else {
      throw Exception('Failed to load detail data...${response.statusCode}');
    }
  }

  // REGIS
  static Future<bool> regisUser(
      String endpoint, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse(baseUrl + endpoint),
      headers: {
        'content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );
    if (response.statusCode == 201) {
      return true;
    } else {
      throw Exception("Failed to register User...${response.statusCode}");
    }
  }

  // ORDER
  static Future<bool> order(
      String endpoint, Map<String, dynamic> data, int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final response = await http.patch(Uri.parse('$baseUrl$endpoint/$id'),
        headers: {
          'content-type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data));
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception("Failed to make order...${response.statusCode}");
    }
  }

  // EDIT
  static Future<bool> edit(
      String endpoint, Map<String, dynamic> data, int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final response = await http.patch(Uri.parse('$baseUrl$endpoint/$id'),
        headers: {
          'content-type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data));
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception("Failed to edit data...${response.statusCode}");
    }
  }

  // POST
  static Future<bool> post(String endpoint, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final response = await http.post(Uri.parse('$baseUrl$endpoint'),
        headers: {
          'content-type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data));
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      throw Exception("Failed to add data...${response.statusCode}");
    }
  }

  // DELETE
  static Future<bool> delete(String endpoint, int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final response =
        await http.delete(Uri.parse('$baseUrl$endpoint/$id'), headers: {
      'content-type': 'application/json',
      'Authorization': 'Bearer $token',
    });
    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception("Failed to delete data...${response.statusCode}");
    }
  }
}
