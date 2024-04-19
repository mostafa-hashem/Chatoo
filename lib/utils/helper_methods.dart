import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String? validateEmail(String? value) {
  final RegExp regex = RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
  );
  if (value == null || value.isEmpty) {
    return "Please Enter Email";
  } else {
    if (!regex.hasMatch(value)) {
      return 'Enter valid Email';
    } else {
      return null;
    }
  }
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter password';
  } else if (value.length < 6) {
    return "Password can't be less than 6 characters";
  }
  return null;
}

String? validateConfirmPassword(String? value, String password) {
  if (value != password) {
    return "Password doesn't match";
  }
  return null;
}

String? validatePhoneNumber(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter your phone number only for search';
  }
  return null;
}

String? validateGeneral(String? value, String label) {
  if (value == null || value.isEmpty) {
    return 'Please enter $label';
  }
  return null;
}

String getFormattedTime(int timeOfMessage) {
  final dateTime = DateTime.fromMillisecondsSinceEpoch(timeOfMessage);
  final formatter = DateFormat.Hm();
  return formatter.format(dateTime);
}

void showImageDialog(BuildContext context, String imageUrl) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        child: SizedBox(
          width: 400,
          height: 350,
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
          ),
        ),
      );
    },
  );
}
