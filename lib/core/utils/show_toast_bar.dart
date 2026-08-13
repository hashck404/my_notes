import 'package:fluttertoast/fluttertoast.dart';

void showToastBar(String message) {
  Fluttertoast.cancel();
  Fluttertoast.showToast(msg: message);
}
