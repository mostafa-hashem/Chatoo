import 'package:chat_app/ui/widgets/default_text_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateScreen extends StatelessWidget {
  const UpdateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Please update Chatoo app to continue",
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontSize: 15.sp,
                      ),
                ),
                SizedBox(
                  height: 18.h,
                ),
                DefaultTextButton(
                  function: () {
                    _launchURL();
                  },
                  text: 'Update',
                  width: 100.w,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchURL() async {
    const String url =
        'https://www.mediafire.com/file/qf8w96u8m1nvitt/Chatoo_v1.0.0.apk/file';
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $uri';
    }
  }

}
