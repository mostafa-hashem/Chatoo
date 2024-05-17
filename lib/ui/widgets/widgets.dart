import 'package:chat_app/features/groups/ui/widgets/change_group_name_sheet.dart';
import 'package:chat_app/features/profile/ui/widgets/bio_edit_bottom_sheet.dart';
import 'package:chat_app/ui/widgets/language_bootom_sheet.dart';
import 'package:chat_app/ui/widgets/theme_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

InputDecoration textInoutDecoration = const InputDecoration(
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Color(0xFFee7b64), width: 2),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Color(0xFFee7b64), width: 2),
  ),
  errorBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Color(0xFFee7b64), width: 2),
  ),
);

void showSnackBar(BuildContext context, Color color, String text) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        text,
        style: const TextStyle(fontSize: 15),
      ),
      backgroundColor: color,
      duration: const Duration(seconds: 3),
    ),
  );
}

void nextScreen(BuildContext context, Widget page) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => page));
}

void nextScreenReplace(BuildContext context, Widget page) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => page),
  );
}

String getId(String res) {
  return res.substring(0, res.indexOf("_"));
}

String getName(String res) {
  return res.substring(res.indexOf("_") + 1);
}

void showLanguageSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return LanguageBottomSheet();
    },
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16.r),
    ),
  );
}

void showEditBioSheet(BuildContext context, String bio) {
  showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    builder: (context) {
      return EditBioBottomSheet(bio);
    },
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16.r),
    ),
  );
}

void showChangeGroupNameSheet(
  BuildContext context,
  String groupId,
  String groupName,
) {
  showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    builder: (context) {
      return ChangeGroupNameBottomSheet(groupName, groupId);
    },
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16.r),
    ),
  );
}

void showThemeSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return ThemeBottomSheet();
    },
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16.0.r),
    ),
  );
}

Rect getWidgetPosition(GlobalKey key, {double spacing = 40.0}) {
  final RenderBox? renderBox =
      key.currentContext?.findRenderObject() as RenderBox?;
  final offset = renderBox!.localToGlobal(Offset.zero);
  return Rect.fromLTWH(
    offset.dx - spacing,
    offset.dy + spacing,
    renderBox.size.width + (spacing * 2),
    renderBox.size.height + (spacing * 2),
  );
}
