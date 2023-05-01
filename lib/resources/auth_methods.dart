import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:haverr/models/user.dart' as model;
import 'package:haverr/resources/storage_methods.dart';
import 'package:haverr/responsive/mobile_screen_layout.dart';
import 'package:haverr/responsive/responsive_layout.dart';
import 'package:haverr/responsive/web_screen_layout.dart';
import 'package:haverr/screens/signup_screen.dart';
import 'package:haverr/utils/global_variable.dart';
import 'package:haverr/utils/utils.dart';

class AuthMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // get user details
  Future<model.UserModel> getUserDetails() async {
    User currentUser = _auth.currentUser!;

    DocumentSnapshot documentSnapshot =
        await _firestore.collection('users').doc(currentUser.uid).get();

    return model.UserModel.fromSnap(documentSnapshot);
  }

  // Signing Up User

  Future<String> signUpUser({
    required bool isPhoneNumber,
    required String email,
    required String password,
    required String username,
    required String bio,
    required Uint8List file,
  }) async {
    String res = "Some error Occurred";
    try {
      if (email.isNotEmpty ||
          password.isNotEmpty ||
          username.isNotEmpty ||
          bio.isNotEmpty ||
          file != null) {
        String uid;
        if (!isPhoneNumber) {
          // registering user in auth with email and password
          UserCredential cred = await _auth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
          uid = cred.user!.uid;
        }
        uid = FirebaseAuth.instance.currentUser!.uid;

        String photoUrl = await StorageMethods()
            .uploadImageToStorage('profilePics', file, false);

        model.UserModel user = model.UserModel(
          phoneNumber: "",
          isOnline: false,
          username: username,
          uid: uid,
          photoUrl: photoUrl,
          email: email,
          bio: bio,
          followers: [],
          following: [],
          likings: [],
          blockList: [],
          dob: "",
          fullName: "",
          passion: "",
          saved: [],
          isVerified: false,
          showStatus: false,
          token: "",
        );
        if (isPhoneNumber) {
          await _firestore.collection("users").doc(uid).update(user.toJson());
        } else {
          await _firestore.collection("users").doc(uid).set(user.toJson());
        }

        res = "success";
      } else {
        res = "Please enter all the fields";
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  // logging in user
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = "Some error Occurred";
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        // logging in user with email and password
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        res = "success";
      } else {
        res = "Please enter all the fields";
      }
    } catch (err) {
      return err.toString();
    }
    return res;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // EMAIL VERIFICATION
  Future<void> sendEmailVerification(BuildContext context) async {
    try {
      globalFirebaseAuth.currentUser!.sendEmailVerification();
      showSnackBar(context, 'Email verification sent!');
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message!); // Display error message
    }
  }

  // PHONE SIGN IN
  Future<void> phoneSignIn(
    bool isCreateAccount,
    BuildContext context,
    String phoneNumber,
  ) async {
    TextEditingController codeController = TextEditingController();
    // if (kIsWeb) {
    //   // !!! Works only on web !!!
    //   ConfirmationResult result =
    //       await globalFirebaseAuth.signInWithPhoneNumber(phoneNumber);

    //   // Diplay Dialog Box To accept OTP
    //   showOTPDialog(
    //     codeController: codeController,
    //     context: context,
    //     onPressed: () async {
    //       PhoneAuthCredential credential = PhoneAuthProvider.credential(
    //         verificationId: result.verificationId,
    //         smsCode: codeController.text.trim(),
    //       );

    //       await globalFirebaseAuth.signInWithCredential(credential);
    //       Navigator.of(context).pop(); // Remove the dialog box
    //     },
    //   );
    // } else
    {
      // FOR ANDROID, IOS
      await globalFirebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        //  Automatic handling of the SMS code
        verificationCompleted: (PhoneAuthCredential credential) async {
          // !!! works only on android !!!
          await globalFirebaseAuth.signInWithCredential(credential);
        },
        // Displays a message when verification fails
        verificationFailed: (e) {
          showSnackBar(context, e.message!);
        },
        // Displays a dialog box when OTP is sent
        codeSent: ((String verificationId, int? resendToken) async {
          showOTPDialog(
            codeController: codeController,
            context: context,
            onPressed: () async {
              PhoneAuthCredential credential = PhoneAuthProvider.credential(
                verificationId: verificationId,
                smsCode: codeController.text.trim(),
              );

              // !!! Works only on Android, iOS !!!
              await globalFirebaseAuth.signInWithCredential(credential);
              Navigator.of(context).pop(); // Remove the dialog box

              showFloatingFlushBar(context, "Please wait", "Processing");
              if (isCreateAccount) {
                model.UserModel user = model.UserModel(
                  phoneNumber: phoneNumber,
                  isOnline: false,
                  username: '',
                  uid: globalFirebaseAuth.currentUser!.uid,
                  photoUrl: "",
                  email: "",
                  bio: "",
                  followers: [],
                  following: [],
                  likings: [],
                  blockList: [],
                  dob: "",
                  fullName: "",
                  passion: "",
                  saved: [],
                  isVerified: false,
                  showStatus: false,
                  token: "",
                );

                // adding user in our database
                await _firestore
                    .collection("users")
                    .doc(globalFirebaseAuth.currentUser!.uid)
                    .set(user.toJson());
              }

              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) => isCreateAccount
                          ? const SignupScreen(
                              isPhoneNumber: true,
                            )
                          : const ResponsiveLayout(
                              mobileScreenLayout: MobileScreenLayout(),
                              webScreenLayout: WebScreenLayout(),
                            )),
                  (route) => false);
            },
          );
        }),
        codeAutoRetrievalTimeout: (String verificationId) {
          // Auto-resolution timed out...
        },
      );
    }
  }
}
