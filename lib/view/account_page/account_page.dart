import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:movie_recommender/constants/constant_texts.dart';
import 'package:movie_recommender/constants/constant_typography.dart';
import 'package:movie_recommender/view/widgets/custom_button.dart';
import 'package:movie_recommender/view/widgets/input_field.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController repeatPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(MY_ACCOUNT),
      ),
      body: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 100),
            const Text(
              CHANGE_PASSWORD,
              style: CHANGE_PASSWORD_STYLE,
            ),
            const SizedBox(height: 30),
            CustomInputField(
              controller: currentPasswordController,
              obscureText: true,
              labelText: CURRENT_PASSWORD,
            ),
            const SizedBox(height: 20),
            CustomInputField(
              controller: newPasswordController,
              obscureText: true,
              labelText: NEW_PASSWORD,
            ),
            const SizedBox(height: 20),
            CustomInputField(
              controller: repeatPasswordController,
              obscureText: true,
              labelText: REPEAT_PASSWORD,
            ),
            const SizedBox(height: 30),
            CustomButton(
              onPressed: _changePassword,
              text: CHANGE_PASSWORD,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _changePassword() async {
    final User? user = FirebaseAuth.instance.currentUser;
    String email = FirebaseAuth.instance.currentUser?.email ?? '';
    final AuthCredential cred = EmailAuthProvider.credential(
      email: email,
      password: currentPasswordController.text,
    );

    user?.reauthenticateWithCredential(cred).then((value) {
      if (newPasswordController.text == repeatPasswordController.text) {
        user.updatePassword(newPasswordController.text).then((_) {
          Fluttertoast.showToast(
            msg: PASSWORD_CHANGE,
            backgroundColor: Colors.grey,
          );
          Navigator.of(context).pop();
        }).catchError((error) {
          Fluttertoast.showToast(
            msg: TRY_AGAIN,
            backgroundColor: Colors.grey,
          );
        });
      } else {
        Fluttertoast.showToast(
          msg: DIFFERENT_REPEATED,
          backgroundColor: Colors.grey,
        );
      }
    }).catchError((err) {
      Fluttertoast.showToast(
        msg: INVALID_PASSWORD,
        backgroundColor: Colors.grey,
      );
    });
  }
}
