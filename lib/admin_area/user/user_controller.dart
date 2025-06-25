import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/foundation.dart';
import 'package:teb_janelajohari/admin_area/user/access_log_controller.dart';
import 'package:teb_janelajohari/admin_area/user/user.dart';

import 'package:teb_package/util/teb_return.dart';
import 'package:teb_package/util/teb_util.dart';

class UserController with ChangeNotifier {
  late User _currentUser = User();

  User get currentUser => _currentUser;

  Future<TebReturn> login({required User user}) async {
    try {
      final credential = await fb_auth.FirebaseAuth.instance.signInWithEmailAndPassword(
        email: user.email,
        password: user.password,
      );

      if (credential.user != null) {
        _currentUser = await getUserbyEmail(email: user.email);
        _currentUser.token = await credential.user!.getIdToken() ?? '';
        notifyListeners();
        AdmAccessLogController().add(email: user.email, success: true);
      }
    } on fb_auth.FirebaseAuthException catch (e) {
      AdmAccessLogController().add(email: user.email, success: false, observation: e.code);
      return TebReturn.authSignUpError(e.code);
    } catch (e) {
      AdmAccessLogController().add(email: user.email, success: false, observation: e.toString());
      return TebReturn.error(e.toString());
    }

    notifyListeners();
    return TebReturn.sucess;
  }

  void logoff() {
    _currentUser = User();
    clearCurrentUser();
  }

  Future<User> getUserbyEmail({required String email, String setToken = ''}) async {
    var userQuery = FirebaseFirestore.instance.collection(User.collectionName).where("email", isEqualTo: email);

    final users = await userQuery.get();
    final dataList = users.docs.map((doc) => doc.data()).toList();

    if (dataList.isEmpty) {
      return User();
    } else {
      return User.fromMap(map: dataList.first);
    }
  }

  Future<User> getUserData({required String userId, String setEmail = '', String setToken = ''}) async {
    final userDataRef = await FirebaseFirestore.instance.collection(User.collectionName).doc(userId).get();
    final userData = userDataRef.data();

    if (userData == null) {
      return User();
    }

    return User.fromMap(map: userData, setEmail: setEmail, setToken: setToken);
  }

  Future<TebReturn> save({required User user}) async {
    try {
      if (user.id.isEmpty) {
        final credential = await fb_auth.FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: user.email,
          password: TebUtil.encrypt(user.password),
        );
        if (credential.user == null) return TebReturn.error('Erro ao criar usuário');

        if (fb_auth.FirebaseAuth.instance.currentUser != null) {
          fb_auth.FirebaseAuth.instance.currentUser!.updateDisplayName(user.name);
        }

        user.id = credential.user!.uid;
      }

      if (user.isPasswordChanged) {
        user.password = TebUtil.encrypt(user.password);
        if (fb_auth.FirebaseAuth.instance.currentUser != null) {
          fb_auth.FirebaseAuth.instance.currentUser!.updatePassword(user.password);
        }
      }

      if (fb_auth.FirebaseAuth.instance.currentUser != null) {
        if (user.email != fb_auth.FirebaseAuth.instance.currentUser!.email) {
          fb_auth.FirebaseAuth.instance.currentUser!.verifyBeforeUpdateEmail(user.email);
        }
      }

      if (fb_auth.FirebaseAuth.instance.currentUser != null) {
        if (user.name != fb_auth.FirebaseAuth.instance.currentUser!.displayName) {
          fb_auth.FirebaseAuth.instance.currentUser!.verifyBeforeUpdateEmail(user.name);
        }
      }

      await FirebaseFirestore.instance.collection(User.collectionName).doc(user.id).set(user.toMap());

      _currentUser = User.fromMap(map: user.toMap());

      return TebReturn.sucess;
    } on fb_auth.FirebaseException catch (e) {
      return TebReturn.error(e.code);
    } catch (e) {
      return TebReturn.error(e.toString());
    }
  }

  void clearCurrentUser() async {
    _currentUser = User();
  }
}
