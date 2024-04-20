import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:chat_app/ui/resources/text_style.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomProfileContainer extends StatefulWidget {
  final TextEditingController controller;
  final void Function()? onTap;
  final void Function(String country)? onSelectCountry;
  final void Function()? suffixPressed;
  final bool? isClickable;
  final bool? isReadOnly;
  final int? maxLines;
  final TextInputType textInputType;
  final String labelText;
  final IconData? icon;
  final String? Function(String?) validator;

  const CustomProfileContainer({
    required this.labelText,
    required this.textInputType,
    this.icon,
    required this.controller,
    this.onTap,
    this.onSelectCountry,
    this.suffixPressed,
    this.isClickable = true,
    this.isReadOnly = false,
    this.maxLines,
    required this.validator,
  });

  @override
  State<CustomProfileContainer> createState() => _CustomProfileContainerState();
}

class _CustomProfileContainerState extends State<CustomProfileContainer> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.labelText,
          style: novaFlat18WhiteLight().copyWith(color: AppColors.primary),
        ),
        SizedBox(
          height: 8.h,
        ),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                validator: widget.validator,
                controller: widget.controller,
                readOnly: widget.isReadOnly!,
                enabled: widget.isClickable,
                style: Theme.of(context).textTheme.bodyMedium,
                keyboardType: widget.textInputType,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(12),
                  border: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: AppColors.borderColor, width: 2.w),
                    borderRadius: BorderRadius.circular(7.r),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: AppColors.borderColor, width: 2.w),
                    borderRadius: BorderRadius.circular(7.r),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: AppColors.borderColor, width: 2.w),
                    borderRadius: BorderRadius.circular(7.r),
                  ),
                ),
              ),
            ),
            if (widget.labelText == "Country")
              const SizedBox(
                width: 20,
              )
            else
              const SizedBox.shrink(),
            if (widget.labelText == "Country")
              SizedBox(
                width: 30,
                child: GestureDetector(
                  onTap: () => showCountryPicker(
                    context: context,
                    countryListTheme: CountryListThemeData(
                      flagSize: 25,
                      backgroundColor: Colors.white,
                      textStyle: const TextStyle(
                        fontSize: 16,
                        color: Colors.blueGrey,
                      ),
                      bottomSheetHeight: 500,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        topRight: Radius.circular(20.0),
                      ),
                      //Optional. Styles the search field.
                      inputDecoration: InputDecoration(
                        labelText: 'Search',
                        hintText: 'Start typing to search',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: const Color(0xFF8C98A8).withOpacity(0.2),
                          ),
                        ),
                      ),
                    ),
                    onSelect: (Country country) {
                      widget.onSelectCountry!(country.name);
                    },
                  ),
                  child: const Icon(Icons.list_outlined),
                ),
              )
            else
              const SizedBox.shrink(),
          ],
        ),
      ],
    );
  }
}
