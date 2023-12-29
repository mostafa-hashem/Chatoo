import 'package:chat_app/features/auth/cubit/auth_cubit.dart';
import 'package:chat_app/features/auth/cubit/auth_state.dart';
import 'package:chat_app/features/auth/data/models/login_data.dart';
import 'package:chat_app/features/auth/ui/screens/register_screen.dart';
import 'package:chat_app/features/profile/cubit/profile_cubit.dart';
import 'package:chat_app/features/profile/cubit/profile_state.dart';
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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authCubit = AuthCubit.get(context);
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
          padding: EdgeInsets.zero,
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.only(
                left: 20.w,
                right: 20.w,
                top: 10.h,
                bottom: MediaQuery.of(context).viewInsets.bottom * 1.1,),
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
                    "Login now to see what they are talking!",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Image.asset("assets/images/login.png"),
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
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushNamed(context, Routes.resetPassword),
                    child: Row(
                      children: [
                        const Icon(Icons.lock_reset_outlined),
                        SizedBox(
                          width: 8.w,
                        ),
                        const Text(
                          "Forget password",
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  MultiBlocListener(
                    listeners: [
                      BlocListener<AuthCubit, AuthState>(
                        listener: (context, state) {
                          if (state is AuthLoading) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return const LoadingIndicator();
                              },
                            );
                          } else {
                            Navigator.of(context).pop();
                            if (state is AuthSuccess) {
                              ProfileCubit.get(context).getUser();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Successfully login",
                                    style: TextStyle(fontSize: 15),
                                  ),
                                  backgroundColor: AppColors.primary,
                                  duration: Duration(seconds: 3),
                                ),
                              );
                            } else if (state is AuthError) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    state.message,
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                  backgroundColor: AppColors.error,
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                            }
                          }
                        },
                      ),
                      BlocListener<ProfileCubit, ProfileState>(
                        listener: (context, state) {
                          if (state is GetUserSuccess) {
                            Navigator.pushReplacementNamed(
                              context,
                              Routes.layout,
                            );
                          }
                        },
                      ),
                    ],
                    child: DefaultTextButton(
                      function: () {
                        if (formKey.currentState!.validate()) {
                          authCubit.login(
                            LoginData(
                              email: emailController.text,
                              password: passwordController.text,
                            ),
                          );
                        }
                      },
                      text: "Login",
                      textStyle: novaFlat18WhiteDark(),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  Text.rich(
                    TextSpan(
                      text: "Don't have an account? ",
                      style: Theme.of(context).textTheme.bodySmall,
                      children: <TextSpan>[
                        TextSpan(
                          text: "Sign Up",
                          style: GoogleFonts.ubuntu(
                            color: Colors.blue,
                            fontSize: 18,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              nextScreenReplace(
                                context,
                                const RegisterScreen(),
                              );
                            },
                        ),
                      ],
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
