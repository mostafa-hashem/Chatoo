import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SearchWidget extends StatelessWidget {
  const SearchWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.r),
        border: Border.all(color: Colors.transparent),
      ),
      child: TextField(
        onChanged: (value) {},
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7.r),
            borderSide: const BorderSide(
              color: Colors.blue,
              width: 2.0,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7.r),
            borderSide: BorderSide(
              color: const Color(0xff000000).withOpacity(0.5),
              width: 2.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7.r),
            borderSide: const BorderSide(
              color: Colors.blue,
              width: 2.0,
            ),
          ),
          hintText: 'What are looking for',
          hintStyle: TextStyle(
            color: const Color(0xff000000).withOpacity(0.5),
            letterSpacing: -1,
            fontSize: 12.sp,
          ),
          suffixIcon: Icon(
            Icons.search,
            color: const Color(0xff000000).withOpacity(0.5),
          ),
        ),
      ),
    );
  }
}
