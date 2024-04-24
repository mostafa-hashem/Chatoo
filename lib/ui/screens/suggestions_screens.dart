import 'package:chat_app/features/profile/cubit/profile_cubit.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:chat_app/ui/widgets/default_text_button.dart';
import 'package:chat_app/ui/widgets/widgets.dart';
import 'package:chat_app/utils/cubit/suggestion_cubit.dart';
import 'package:chat_app/utils/cubit/suggestion_state.dart';
import 'package:chat_app/utils/data/models/suggestion.dart';
import 'package:chat_app/utils/helper_methods.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SuggestionsScreen extends StatefulWidget {
  const SuggestionsScreen({super.key});

  @override
  State<SuggestionsScreen> createState() => _SuggestionsScreenState();
}

class _SuggestionsScreenState extends State<SuggestionsScreen> {
  TextEditingController suggestionController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final suggestionCubit = SuggestionCubit.get(context);
    final profileCubit = ProfileCubit.get(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "Suggestions",
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Colors.white,
                ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Form(
              key: formKey,
              autovalidateMode: AutovalidateMode.always,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    validator: (value) => validateGeneral(value, 'suggestion'),
                    controller: suggestionController,
                    minLines: 1,
                    maxLines: 4,
                    maxLength: 400,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(fontSize: 14.sp),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(12),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.primary,
                          width: 2.w,
                        ),
                        borderRadius: BorderRadius.circular(7.r),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.primary,
                          width: 2.w,
                        ),
                        borderRadius: BorderRadius.circular(7.r),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.primary,
                          width: 2.w,
                        ),
                        borderRadius: BorderRadius.circular(7.r),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.05,
                  ),
                  BlocListener<SuggestionCubit, SuggestionStates>(
                    listener: (_, state) {
                      if (state is SendSuggestionSuccess) {
                        showSnackBar(
                          context,
                          Colors.greenAccent,
                          'Successfully sent suggestion',
                        );
                      }
                      if (state is SendSuggestionError) {
                        showSnackBar(
                          context,
                          Colors.greenAccent,
                          state.message,
                        );
                      }
                    },
                    child: DefaultTextButton(
                      function: () {
                        if (formKey.currentState!.validate()) {
                          final suggestion = Suggestion(
                            userId: profileCubit.user.id,
                            user: profileCubit.user,
                            suggestion: suggestionController.text,
                            sentAt: DateTime.now(),
                          );
                          suggestionController.clear();
                          suggestionCubit.sendSuggestion(suggestion);
                        }
                      },
                      text: 'Send',
                      textStyle:
                          Theme.of(context).textTheme.bodyMedium!.copyWith(
                                fontSize: 18.sp,
                                color: Colors.white,
                              ),
                      width: 180.w,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
