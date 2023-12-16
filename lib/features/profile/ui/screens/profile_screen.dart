import 'dart:io';

import 'package:chat_app/features/auth/cubit/auth_cubit.dart';
import 'package:chat_app/features/auth/cubit/auth_state.dart';
import 'package:chat_app/features/profile/cubit/profile_cubit.dart';
import 'package:chat_app/features/profile/cubit/profile_state.dart';
import 'package:chat_app/features/profile/ui/widgets/custom_profile_container.dart';
import 'package:chat_app/route_manager.dart';
import 'package:chat_app/shared/provider/app_provider.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:chat_app/ui/widgets/default_button.dart';
import 'package:chat_app/ui/widgets/default_text_button.dart';
import 'package:chat_app/ui/widgets/loading_indicator.dart';
import 'package:chat_app/utils/data/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  TextEditingController userNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  File? imageFile;

  @override
  void initState() {
    super.initState();
    final profile = ProfileCubit.get(context).user;
    userNameController.text = profile.userName!;
    emailController.text = profile.email!;
    bioController.text = profile.bio!;
    phoneNumberController.text = profile.phoneNumber!;
    if (profile.address != null) {
      addressController.text = profile.address!.city!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MyAppProvider>(context);
    final profile = ProfileCubit.get(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Profile",
            style: GoogleFonts.novaSquare(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              left: 22.w,
              right: 22.w,
              top: 22.h,
              bottom: MediaQuery.of(context).viewInsets.bottom * 0.2,
            ),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: BlocListener<AuthCubit, AuthState>(
                    listener: (context, state) {
                      if (state is AuthLoading) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                        );
                      } else {
                        Navigator.pop(context);
                        if (state is LoggedOut) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Successfully logout",
                                style: TextStyle(fontSize: 15),
                              ),
                              backgroundColor: AppColors.primary,
                              duration: Duration(seconds: 3),
                            ),
                          );
                        } else if (state is AuthError) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "There is an error",
                                style: TextStyle(fontSize: 15),
                              ),
                              backgroundColor: AppColors.primary,
                              duration: Duration(seconds: 3),
                            ),
                          );
                        }
                      }
                    },
                    child: DefaultButton(
                      width: 40,
                      height: 50,
                      function: () {
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text("Logout"),
                              content: const Text(
                                "Are you sure you want to logout?",
                              ),
                              actions: [
                                IconButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  icon: const Icon(
                                    Icons.cancel,
                                    color: Colors.red,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    AuthCubit.get(context).logout();
                                    Navigator.pushReplacementNamed(
                                      context,
                                      Routes.login,
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.done,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      icon: Icons.logout_outlined,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                BlocConsumer<ProfileCubit, ProfileState>(
                  listener: (_, state) {
                    if (state is UploadProfileImageLoading) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return const LoadingIndicator();
                        },
                      );
                    } else {
                      if (state is UploadProfileImageError) {
                        Navigator.pop(context);
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
                      if (state is UploadProfileImageSuccess) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Successfully Uploaded",
                              style: TextStyle(fontSize: 15),
                            ),
                            backgroundColor: AppColors.primary,
                            duration: Duration(seconds: 3),
                          ),
                        );
                      }
                    }
                  },
                  builder:(context, state) => Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Container(
                        height: 130.h,
                        width: 145.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(40.r),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(
                              ProfileCubit.get(context).user.profileImage !=
                                          null &&
                                      ProfileCubit.get(context)
                                          .user
                                          .profileImage!
                                          .isNotEmpty
                                  ? ProfileCubit.get(context).user.profileImage!
                                  : "https://firebasestorage.googleapis.com/v0/b/chat-app-319.appspot.com/o/defultProfileImage%2Fuser.png?alt=media&token=bab1fe29-62a5-4338-83ac-ff462c322fbd",
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          final ImagePicker picker = ImagePicker();
                          final XFile? xFile = await picker.pickImage(
                            source: ImageSource.gallery,
                          );

                          if (xFile != null) {
                            File xFilePathToFile(XFile xFile) {
                              return File(xFile.path);
                            }

                            imageFile = xFilePathToFile(xFile);
                            if (context.mounted) {
                              profile.uploadProfileImageToFireStorage(
                                profile.user.id!,
                                imageFile!,
                              );
                            }
                          }
                        },
                        child: const Icon(Icons.edit),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.05,
                ),
                BlocBuilder<ProfileCubit, ProfileState>(
                  builder: (context, state) => CustomProfileContainer(
                    labelText: "User Name",
                    textInputType: TextInputType.name,
                    controller: userNameController,
                  ),
                ),
                Divider(
                  height: 30.h,
                ),
                BlocBuilder<ProfileCubit, ProfileState>(
                  builder: (context, state) => CustomProfileContainer(
                    labelText: "Phone Num",
                    textInputType: TextInputType.number,
                    controller: phoneNumberController,
                  ),
                ),
                // InfoRow(text: "Phone Num: ", info: phoneNumberController.text),
                Divider(
                  height: 30.h,
                ),
                CustomProfileContainer(
                  labelText: "Email",
                  isClickable: false,
                  textInputType: TextInputType.name,
                  controller: emailController,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                BlocListener<ProfileCubit, ProfileState>(
                  listener: (_, state) {
                    if (state is UpdateUserSuccess) {
                      ProfileCubit.get(context).getUser();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Successfully Updated",
                            style: TextStyle(fontSize: 15),
                          ),
                          backgroundColor: AppColors.primary,
                          duration: Duration(seconds: 3),
                        ),
                      );
                    }
                  },
                  child: DefaultTextButton(
                    function: () {
                      ProfileCubit.get(context).updateUser(
                        User(
                          id: profile.user.id,
                          userName: userNameController.text,
                          email: profile.user.email,
                          phoneNumber: phoneNumberController.text,
                          bio: profile.user.bio,
                          friends: profile.user.friends,
                          groups: profile.user.friends,
                          profileImage: profile.user.profileImage,
                          address: profile.user.address,
                        ),
                      );
                    },
                    text: provider.language == "en"
                        ? "Save changes"
                        : "حفظ التعديلات",
                  ),
                ),
                SizedBox(
                  height: 18.h,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
