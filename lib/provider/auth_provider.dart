import 'package:document_saver_app/routes/routes.dart';
import 'package:document_saver_app/utils/helpers/snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  static bool isLoggedIn = false;

  setIsLoggedIn() {
    isLoggedIn = !isLoggedIn;
    notifyListeners();
  }

  signUp(
      {required BuildContext context,
      required String email,
      required String password}) async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((response) =>
              Navigator.pushReplacementNamed(context, loginPageRoute));
    } on FirebaseAuthException catch (e) {
      SnackBarHelper.showErrorMessage(context: context, message: e.message);
    }
  }

  signIn(
      {required BuildContext context,
      required String email,
      required String password}) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password)
          .then((value) {
        print("caralho");
        Navigator.pushReplacementNamed(context, homePageRoute);
      });
    } on FirebaseAuthException catch (e) {
      SnackBarHelper.showErrorMessage(context: context, message: e.message);
    }
  }

  forgotPassword({required BuildContext context, required String email}) async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: email)
          .then((value) {
        SnackBarHelper.showSuccessMessage(
            context: context,
            message: "Password recovery e-mail sent, check your inbox");
        Navigator.pushReplacementNamed(context, loginPageRoute);
      });
    } on FirebaseAuthException catch (e) {
      SnackBarHelper.showErrorMessage(context: context, message: e.message);
    }
  }

  signOut({required context}) async {
    try {
      await FirebaseAuth.instance.signOut().then((value) {
        Navigator.pushReplacementNamed(context, loginPageRoute);
      });
    } on FirebaseAuthException catch (e) {
      SnackBarHelper.showErrorMessage(context: context, message: e.message);
    }
  }
}
