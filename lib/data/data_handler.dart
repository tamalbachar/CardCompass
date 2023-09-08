import 'dart:convert';
import 'package:http/http.dart' as http;

class DataHandler {
  Future<List<dynamic>> fetchATMDataFromMapModuleApp() async {
    try {
      final response =
          await http.get(Uri.parse('http://10.100.100.35:3100/fetch-atm-data'));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData as List<dynamic>;
      } else {
        return []; // Return an empty list if the response is not successful
      }
    } catch (e) {
      // Handle any exceptions that might occur during the API request
      return []; // Return an empty list on error
    }
  }

  Future<List<dynamic>> fetchBranchDataFromMapModuleApp() async {
    try {
      final response = await http
          .get(Uri.parse('http://10.100.100.35:3100/fetch-branches-data'));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData as List<dynamic>;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}
