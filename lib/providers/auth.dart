import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String _userId;
  String _token;
  DateTime _expiry;
  Timer _authTimer;

  bool get isAuthenticate {
    return token != null;
  }

  String get token {
    if (_expiry != null && _expiry.isAfter(DateTime.now()) && _token != null) {
      return _token;
    }
    return null;
  }

  String get userId {
    return _userId;
  }

  Future<void> _authenticate(String email, String password, String urlSegment) async {
    final url = Uri.parse('https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyB18OOgjtXZFUxnn_K5dXJGS5V2tAZMGj4');
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiry = DateTime.now().add(
        Duration(
          seconds: int.parse(responseData['expiresIn']),
        ),
      );
      autoLogOut();
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiry': _expiry.toIso8601String(),
      });
      print(userData);
      prefs.setString('userData', userData);
    } catch (error) {
      throw error;
    }
  }

  Future<void> signUp(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> logIn(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedData = json.decode(prefs.getString('userData')) as Map<String, Object>;
    print(extractedData);
    final expiryDate = DateTime.parse(extractedData['expiry']);

    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }
    _token = extractedData['token'];
    _userId = extractedData['userId'];
    _expiry = expiryDate;
    notifyListeners();
    autoLogOut();
    return true;
  }

  Future<void> logOut() async {
    _token = null;
    _expiry = null;
    _userId = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
    // prefs.remove('userData');
  }

  void autoLogOut() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final timerToExpiry = _expiry.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timerToExpiry), logOut);
  }
}
