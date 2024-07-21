import 'package:chat_app/features/auth/cubit/auth_cubit.dart';
import 'package:chat_app/features/auth/cubit/auth_state.dart';
import 'package:chat_app/features/auth/data/models/register_data.dart';
import 'package:chat_app/features/auth/ui/screens/login_screen.dart';
import 'package:chat_app/features/notifications/cubit/notifications_cubit.dart';
import 'package:chat_app/route_manager.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:chat_app/ui/resources/text_style.dart';
import 'package:chat_app/ui/widgets/default_form_field.dart';
import 'package:chat_app/ui/widgets/default_password_form_filed.dart';
import 'package:chat_app/ui/widgets/default_text_button.dart';
import 'package:chat_app/ui/widgets/loading_indicator.dart';
import 'package:chat_app/ui/widgets/widgets.dart';
import 'package:chat_app/utils/helper_methods.dart';
import 'package:country_picker/country_picker.dart';
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
  final cityController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final authCubit = AuthCubit.get(context);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SafeArea(
        child: Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                left: 20.w,
                right: 20.w,
                top: 10.h,
                bottom: MediaQuery.of(context).viewInsets.bottom * 0.05,
              ),
              child: Form(
                key: formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
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
                    DefaultFormField(
                      controller: phoneNumberController,
                      type: TextInputType.number,
                      validate: validatePhoneNumber,
                      label: "Phone Number",
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.02,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: DefaultFormField(
                            controller: cityController,
                            type: TextInputType.none,
                            validate: (value) =>
                                validateGeneral(value, "country"),
                            label: "Country",
                            isRead: true,
                          ),
                        ),
                        SizedBox(
                          width: 20.w,
                        ),
                        SizedBox(
                          width: 30,
                          child: GestureDetector(
                            onTap: () => showCountryPicker(
                              context: context,
                              countryListTheme: CountryListThemeData(
                                flagSize: 25,
                                backgroundColor: Colors.white,
                                textStyle: TextStyle(
                                  fontSize: 16.sp,
                                  color: Colors.blueGrey,
                                ),
                                bottomSheetHeight: 500.h,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(20.0),
                                  topRight: Radius.circular(20.0),
                                ),
                                inputDecoration: InputDecoration(
                                  labelText: 'Search',
                                  labelStyle:
                                      Theme.of(context).textTheme.bodySmall,
                                  prefixIcon: const Icon(Icons.search),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: const Color(0xFF8C98A8)
                                          .withOpacity(0.2),
                                    ),
                                  ),
                                ),
                              ),
                              onSelect: (Country country) {
                                cityController.text = country.name;
                              },
                            ),
                            child: const Icon(Icons.list_outlined),
                          ),
                        ),
                      ],
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
                      validate: (value) => validateConfirmPassword(
                        value,
                        passwordController.text,
                      ),
                      label: "Confirm Password",
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.02,
                    ),
                    BlocListener<AuthCubit, AuthState>(
                      listener: (_, state) {
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
                              SnackBar(
                                content: Text(
                                  "A verification link has been sent to your email address. Please check your email to complete the registration process.",
                                  style: TextStyle(fontSize: 13.sp),
                                ),
                                backgroundColor: AppColors.snackBar,
                                duration: const Duration(
                                  seconds: 9,
                                ),
                              ),
                            );
                            Navigator.pushReplacementNamed(
                              context,
                              Routes.login,
                            );
                          } else if (state is EmailVerifyRequestSentError) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Error: ${state.message}",
                                  style: const TextStyle(fontSize: 15),
                                ),
                                backgroundColor: AppColors.error,
                                duration: const Duration(seconds: 3),
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
                              final List<String> fCMTokens = [];
                              fCMTokens.add(
                                  NotificationsCubit.get(context).fCMToken!);
                              authCubit.register(
                                RegisterData(
                                  email: emailController.text,
                                  userName: userNameController.text,
                                  password: passwordController.text,
                                  phoneNumber: phoneNumberController.text,
                                  fCMToken: fCMTokens,
                                  city: cityController.text,
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
                      height: MediaQuery.of(context).size.height * 0.05,
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
