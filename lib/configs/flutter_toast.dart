import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void flutterToast({required String message}) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.SNACKBAR,
    timeInSecForIosWeb: 2,
    backgroundColor: Colors.black45,
    textColor: Colors.white,
    fontSize: 19.5,
  );
}
