// ignore_for_file: prefer_void_to_null

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:movie_recommender/constants/texts.dart';
import 'package:movie_recommender/core/auth/auth_service.dart';

enum AuthEnum {
  EMPTY_EMAIL,
  EMPTY_PASSWORD,
  WRONG_REPEATED_PASSWORD,
  CORRECT_INPUT,
}

/// Cubit responsible for signing in, up and off.
class AuthCubit extends Cubit<bool> {
  final bool isTest;
  StreamSubscription<bool>? _userAuthStateSub;

  AuthCubit({this.isTest = false}) : super(false) {
    if (isTest) return;
    _userAuthStateSub = _initUserAuthStateSubscription();
  }

  /// Initializes user auth state listener.
  StreamSubscription<bool> _initUserAuthStateSubscription() {
    return AuthService.isUserAuthenticated().listen(emit);
  }

  /// Logs user in with provided email and password.
  Future<void> signIn(String email, String password) async {
    AuthEnum result = await validateAuthData(email, password);
    if (result != AuthEnum.CORRECT_INPUT) return;

    AuthService.signIn(email, password).catchError(
      _onFirebaseError<UserCredential>,
    );
  }

  /// Registers user in with provided email and password.
  Future<void> signUp(
    String email,
    String password,
    String repeatedPassword,
  ) async {
    AuthEnum result = await validateAuthData(
      email,
      password,
      repeatedPassword: repeatedPassword,
    );
    if (result != AuthEnum.CORRECT_INPUT) return;

    AuthService.signUp(email, password).catchError(
      _onFirebaseError<UserCredential>,
    );
  }

  /// Checks if provided email, password and repeated password are correct.
  Future<AuthEnum> validateAuthData(
    String email,
    String password, {
    String? repeatedPassword,
  }) async {
    if (email.isEmpty) {
      _displayToast(EMPTY_EMAIL);
      return AuthEnum.EMPTY_EMAIL;
    }
    if (password.isEmpty) {
      _displayToast(EMPTY_PASSWORD);
      return AuthEnum.EMPTY_PASSWORD;
    }
    if (repeatedPassword != null && password != repeatedPassword) {
      _displayToast(WRONG_REPEATED);
      return AuthEnum.WRONG_REPEATED_PASSWORD;
    }
    return AuthEnum.CORRECT_INPUT;
  }

  /// Signs user out.
  Future<void> signOut() async => AuthService.signOut();

  /// Changes current user's password.
  /// Returns boolean which says if everything went fine.
  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
    String repeatedPassword,
  ) async {
    // Basic frontend validation:
    if (currentPassword.isEmpty) {
      _displayToast(EMPTY_PASSWORD);
      return false;
    }
    if (newPassword.isEmpty) {
      _displayToast(EMPTY_NEW_PASSWORD);
      return false;
    }
    if (repeatedPassword != newPassword) {
      _displayToast(WRONG_REPEATED);
      return false;
    }
    if (FirebaseAuth.instance.currentUser == null) {
      _displayToast(TRY_AGAIN);
      return false;
    }

    // Validate provided password with Firebase:
    final User? user = FirebaseAuth.instance.currentUser;
    try {
      final AuthCredential cred = EmailAuthProvider.credential(
        email: user?.email ?? '',
        password: currentPassword,
      );
      await user?.reauthenticateWithCredential(cred);
    } catch (e, st) {
      _onFirebaseError<Null>(e, st);
      return false;
    }

    // Update password with Firebase:
    try {
      await user?.updatePassword(newPassword);
    } catch (e, st) {
      _onFirebaseError<Null>(e, st);
      return false;
    }

    _displayToast(PASSWORD_CHANGED);
    return true;
  }

  Future<bool> deleteAccount() async {
    try {
      await FirebaseAuth.instance.currentUser?.delete();
      return true;
    } catch (e, st) {
      _onFirebaseError<Null>(e, st);
      return false;
    }
  }

  /// Shows toast if request to Firebase failed.
  FutureOr<T> _onFirebaseError<T>(Object err, StackTrace st) async {
    if (err is FirebaseAuthException && err.message != null) {
      // Remove dot from the end of message:
      String msg = err.message!.endsWith('.')
          ? err.message!.substring(0, err.message!.length - 1)
          : err.message!;
      Fluttertoast.showToast(msg: msg, backgroundColor: Colors.grey);
    } else {
      Fluttertoast.showToast(msg: TRY_AGAIN, backgroundColor: Colors.grey);
    }
    return Future.error(err);
  }

  /// Shows grey toast at the bottom of the screen.
  Future<void> _displayToast(String msg) async {
    if (isTest) return;
    Fluttertoast.showToast(msg: msg, backgroundColor: Colors.grey);
  }

  @override
  Future<void> close() {
    _userAuthStateSub?.cancel();
    return super.close();
  }
}
