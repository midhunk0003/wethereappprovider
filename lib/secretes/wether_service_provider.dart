import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:wetherappapiprovider/models/wether_response_model.dart';
import 'package:wetherappapiprovider/secretes/api.dart';

import 'package:http/http.dart' as http;

class WetherServiceProvider extends ChangeNotifier {
  WetherModel? _wether;
  WetherModel? get wether => _wether;

  bool _isLoading = false;
  bool get isloading => _isLoading;

  String? _errors = "";
  String? get errors => _errors;

  Future<void> fetchWetherData(String city, BuildContext context) async {
    _isLoading = true;
    print(city);
    _errors = "";
    notifyListeners();

    try {
      final apiUrl =
          "${APIEndPoints().cityUrlapi}${city}${APIEndPoints().cityEndPoint}${APIEndPoints().apiKey}${APIEndPoints().unit}";
      print(apiUrl);
      print(123);
      final response = await http.get(Uri.parse(apiUrl));
      // _isLoading = true;
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data);

        _wether = WetherModel.fromJson(data);
        notifyListeners();
      } else {
        _errors = "fail to load data";
      }
    } on SocketException {
      print('no enter net');

      _errors = "Network error. \n Please check your internet connection.";
      _showErrorSnackbar(context, _errors!);
    } catch (e) {
      _errors = "Fail to load data ${e}";
    } finally {
      await Future.delayed(Duration(seconds: 2));
      _isLoading = false;
      notifyListeners();
    }
  }

  void _showErrorSnackbar(BuildContext context, String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
        backgroundColor: Colors.red,
      ),
    );
  }
}
