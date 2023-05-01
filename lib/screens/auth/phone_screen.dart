import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:haverr/resources/auth_methods.dart';
import 'package:haverr/resources/colors.dart';
import 'package:haverr/utils/utils.dart';
import 'package:haverr/widgets/text_field_input.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:provider/provider.dart';

class PhoneAuthScreen extends StatefulWidget {
  final bool isCreateAccount;
  const PhoneAuthScreen({required this.isCreateAccount, Key? key})
      : super(key: key);

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final TextEditingController phoneController = TextEditingController();
  String phoneNumber = '';

  @override
  void dispose() {
    super.dispose();
    phoneController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Phone Number"),
        automaticallyImplyLeading: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // TextFieldInput(
            //   hintText: 'Enter phone number',
            //   textInputType: TextInputType.phone,
            //   textEditingController: phoneController,
            //   isPass: false,
            // ),

            InternationalPhoneNumberInput(
              onInputChanged: (PhoneNumber number) {
                setState(() {
                  phoneNumber = number.phoneNumber!;
                });
              },
              onInputValidated: (bool value) {
                print(value);
              },
              selectorConfig: const SelectorConfig(
                selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
              ),
              ignoreBlank: true,
              autoValidateMode: AutovalidateMode.disabled,
              selectorTextStyle: const TextStyle(color: Colors.white),
              textFieldController: phoneController,
              formatInput: true,
              keyboardType: const TextInputType.numberWithOptions(
                  signed: true, decimal: true),
              inputBorder: const OutlineInputBorder(),
              onSaved: (PhoneNumber number) {
                log('On Saved: $number');
              },
            ),
            const SizedBox(
              height: 15,
            ),

            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: mainColor),
                onPressed: () async {
                  if (phoneController.text.isEmpty) {
                    showFloatingFlushBar(context, "Error", "Field is empty");
                  } else {
                    if (phoneController.text.startsWith("+")) {
                      showFloatingFlushBar(
                          context, "Error", "Please add a correct number");
                    } else {
                      showFloatingFlushBar(context, "Success", "Please Wait");
                      AuthMethods().phoneSignIn(
                          widget.isCreateAccount, context, phoneNumber);
                      // showFloatingFlushBar(context, "Success", "Enter");
                    }
                  }
                },
                child: const Text("Continue")),
          ],
        ),
      ),
    );
  }
}
