// import 'package:shared_preferences/shared_preferences.dart';
//
// class HelperFunctions {
//   static String userLoggedInKey = "USERLOGGEDINKEY";
//   static String userNameKey = "USERNameKEY";
//   static String userEmailKey = "USEREMAILKEY";
//
//   // saving the data to SP
//   static Future<bool?> saveUserLoggedInStatus(bool isUserLoggedIn) async {
//     final SharedPreferences sp = await SharedPreferences.getInstance();
//     return await sp.setBool(userLoggedInKey, isUserLoggedIn);
//   }
//
//   static Future<bool?> saveUserNameSp(String userName) async {
//     final SharedPreferences sp = await SharedPreferences.getInstance();
//     return await sp.setString(userNameKey, userName);
//   }
//
//   static Future<bool?> saveUserEmailSp(String email) async {
//     final SharedPreferences sp = await SharedPreferences.getInstance();
//     return await sp.setString(userEmailKey, email);
//   }
//
//   // getting the data to SP
//   static Future<bool?> getUserLoggedInStatus() async {
//     final SharedPreferences sp = await SharedPreferences.getInstance();
//     return sp.getBool(userLoggedInKey);
//   }
//
//   static Future<String?> getUserEmailFromSp() async {
//     final SharedPreferences sf = await SharedPreferences.getInstance();
//     return sf.getString(userEmailKey);
//   }
//
//   static Future<String?> getUserNameFromSp() async {
//     final SharedPreferences sf = await SharedPreferences.getInstance();
//     return sf.getString(userNameKey);
//   }
// }
