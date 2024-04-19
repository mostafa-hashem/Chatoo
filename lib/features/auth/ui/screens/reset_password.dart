import 'package:chat_app/features/auth/cubit/auth_cubit.dart';
import 'package:chat_app/features/auth/cubit/auth_state.dart';
import 'package:chat_app/ui/resources/text_style.dart';
import 'package:chat_app/ui/widgets/default_form_field.dart';
import 'package:chat_app/ui/widgets/default_text_button.dart';
import 'package:chat_app/utils/helper_methods.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen();

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final resetPassword = AuthCubit.get(context);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                left: 16.0.w,
                right: 16.0.w,
                top: 20.h,
                bottom: MediaQuery.of(context).viewInsets.bottom * 1.1,
              ),
              child: Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 44.w,
                        height: 42.h,
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(11.76.r),
                          ),
                          shadows: const [
                            BoxShadow(
                              color: Color(0x23EA6A58),
                              blurRadius: 20,
                              offset: Offset(0, 4.41),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_outlined,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Align(
                      child: SizedBox(
                        height: 200.h,
                        child: Image.asset("assets/images/forget.jpg"),
                      ),
                    ),
                    SizedBox(
                      height: 15.h,
                    ),
                    Text(
                      "Reset Password",
                      style: novaFlat18WhiteLight(),
                    ),
                    SizedBox(
                      height: 5.h,
                    ),
                    Text(
                      "please enter your mail address to resets your password",
                      style: novaFlat18WhiteLight().copyWith(
                        letterSpacing: -0.41,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(
                      height: 37.h,
                    ),
                    DefaultFormField(
                      controller: emailController,
                      type: TextInputType.emailAddress,
                      validate: validateEmail,
                      label: "Email",
                    ),
                    SizedBox(
                      height: 31.h,
                    ),
                    BlocListener<AuthCubit, AuthState>(
                      listener: (_, state) {
                        if (state is PasswordResetRequestSent) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'A password reset code has been sent to your email.',
                              ),
                            ),
                          );
                        }
                      },
                      child: DefaultTextButton(
                        function: () {
                          resetPassword
                              .requestPasswordReset(emailController.text);
                        },
                        text: "Send",
                        textStyle: novaFlat12WhiteDark(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
