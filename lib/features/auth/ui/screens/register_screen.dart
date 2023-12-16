import 'package:chat_app/features/auth/cubit/auth_cubit.dart';
import 'package:chat_app/features/auth/cubit/auth_state.dart';
import 'package:chat_app/features/auth/data/models/register_data.dart';
import 'package:chat_app/features/auth/ui/screens/login_screen.dart';
import 'package:chat_app/route_manager.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:chat_app/ui/resources/text_style.dart';
import 'package:chat_app/ui/widgets/default_form_field.dart';
import 'package:chat_app/ui/widgets/default_password_form_filed.dart';
import 'package:chat_app/ui/widgets/default_text_button.dart';
import 'package:chat_app/ui/widgets/loading_indicator.dart';
import 'package:chat_app/utils/helper_methods.dart';
import 'package:chat_app/widgets/widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final userNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final authCubit = AuthCubit.get(context);
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
                left: 20.w,
                right: 20.w,
                top: 10.h,
                bottom: MediaQuery.of(context).viewInsets.bottom * 0.1),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Chatoo",
                    style: GoogleFonts.novaFlat(fontSize: 30.sp),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.01,
                  ),
                  Text(
                    "Create your account now to chat and explore",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Image.asset("assets/images/register.png"),
                  DefaultFormField(
                    controller: userNameController,
                    type: TextInputType.name,
                    validate: (value) => validateGeneral(value, 'User Name'),
                    label: "User Name",
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  DefaultFormField(
                    controller: emailController,
                    type: TextInputType.emailAddress,
                    validate: validateEmail,
                    label: "E-mail",
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  DefaultPasswordFormField(
                    controller: passwordController,
                    validate: validatePassword,
                    label: "Password",
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  DefaultPasswordFormField(
                    controller: confirmPasswordController,
                    validate: validatePassword,
                    label: "Confirm Password",
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  BlocListener<AuthCubit, AuthState>(
                    listener: (context, state) {
                      if (state is EmailVerifyRequestSentLoading) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return const LoadingIndicator();
                          },
                        );
                      } else {
                        Navigator.pop(context);
                        if (state is EmailVerifyRequestSentSuccess) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "A verification link has been sent to your email address. Please check your email to complete the registration process.",
                                style: TextStyle(fontSize: 15),
                              ),
                              backgroundColor: AppColors.primary,
                              duration: Duration(
                                seconds: 6,
                              ), // You can adjust the duration as per your preference
                            ),
                          );
                          Navigator.pushReplacementNamed(
                            context,
                            Routes.login,
                          );
                        } else if (state is EmailVerifyRequestSentError) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "There is an error, try again",
                                style: TextStyle(fontSize: 15),
                              ),
                              backgroundColor: AppColors.error,
                              duration: Duration(seconds: 3),
                            ),
                          );
                        }
                      }
                    },
                    child: DefaultTextButton(
                      function: () {
                        if (passwordController.text ==
                            confirmPasswordController.text) {
                          if (formKey.currentState!.validate()) {
                            authCubit.register(
                              RegisterData(
                                email: emailController.text,
                                userName: userNameController.text,
                                password: passwordController.text,
                              ),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Password dose not match, please try again",
                                style: TextStyle(fontSize: 15),
                              ),
                              backgroundColor: AppColors.error,
                              duration: Duration(seconds: 3),
                            ),
                          );
                        }
                      },
                      text: "Create account",
                      textStyle: novaFlat18WhiteDark(),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  Text.rich(
                    TextSpan(
                      text: "Already have an account? ",
                      style: Theme.of(context).textTheme.bodySmall,
                      children: <TextSpan>[
                        TextSpan(
                          text: "Sign In",
                          style: GoogleFonts.ubuntu(
                            color: Colors.blue,
                            fontSize: 18,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              nextScreenReplace(
                                context,
                                const LoginScreen(),
                              );
                            },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 35.h,
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
