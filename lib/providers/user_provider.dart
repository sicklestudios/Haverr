import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:haverr/models/user.dart';
import 'package:haverr/resources/auth_methods.dart';
import 'package:haverr/utils/constants.dart';

class UserProvider with ChangeNotifier {
  UserModel? _user;
  final AuthMethods _authMethods = AuthMethods();

  UserModel get getUser => _user!;

  Future<void> refreshUser() async {
    UserModel user = await _authMethods.getUserDetails();
    _user = user;
    notifyListeners();
    userSaves.value = _user!.saved;
  }

  Future<void> refreshUserStream(UserModel model) async {
    {
      log(model.toString());
      _user = model;
      notifyListeners();
      userSaves.value = _user!.saved;
    }
  }
}
