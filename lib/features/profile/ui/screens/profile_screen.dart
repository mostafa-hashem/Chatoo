import 'dart:io';

import 'package:chat_app/features/auth/cubit/auth_cubit.dart';
import 'package:chat_app/features/auth/cubit/auth_state.dart';
import 'package:chat_app/features/friends/cubit/friend_cubit.dart';
import 'package:chat_app/features/groups/cubit/group_cubit.dart';
import 'package:chat_app/features/notifications/cubit/notifications_cubit.dart';
import 'package:chat_app/features/profile/cubit/profile_cubit.dart';
import 'package:chat_app/features/profile/cubit/profile_state.dart';
import 'package:chat_app/features/profile/ui/widgets/custom_profile_container.dart';
import 'package:chat_app/provider/app_provider.dart';
import 'package:chat_app/route_manager.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:chat_app/ui/widgets/default_button.dart';
import 'package:chat_app/ui/widgets/default_text_button.dart';
import 'package:chat_app/ui/widgets/loading_indicator.dart';
import 'package:chat_app/utils/constants.dart';
import 'package:chat_app/utils/data/models/user.dart';
import 'package:chat_app/utils/helper_methods.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
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
    addressController.text = profile.city!;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MyAppProvider>(context);
    final profile = ProfileCubit.get(context);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SafeArea(
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
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              Routes.login,
                              (route) => false,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Successfully logout",
                                  style: TextStyle(fontSize: 15),
                                ),
                                backgroundColor: AppColors.snackBar,
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
                                      GroupCubit.get(context)
                                          .allUserGroups
                                          .clear();
                                      FriendCubit.get(context)
                                          .allFriends
                                          .clear();
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
                    builder: (context, state) => Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Container(
                          height: 130.h,
                          width: 145.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(40.r),
                          ),
                          child: profile.user.profileImage != null &&
                                  profile.user.profileImage!.isNotEmpty
                              ? InkWell(
                                  onTap: () => showImageDialog(
                                    context,
                                    profile.user.profileImage!,
                                  ),
                                  child: ClipOval(
                                    child: FancyShimmerImage(
                                      imageUrl: profile.user.profileImage!,
                                      height: 150.h,
                                      width: 180.w,
                                      boxFit: BoxFit.contain,
                                      errorWidget: const Icon(
                                        Icons.error_outline_outlined,
                                      ),
                                    ),
                                  ),
                                )
                              : ClipOval(
                                  child: FancyShimmerImage(
                                    imageUrl: FirebasePath.defaultImage,
                                    height: 150.h,
                                    width: 180.w,
                                    boxFit: BoxFit.contain,
                                    errorWidget: const Icon(
                                      Icons.error_outline_outlined,
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
                  CustomProfileContainer(
                    labelText: "Email",
                    isClickable: false,
                    textInputType: TextInputType.name,
                    controller: emailController,
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
                  BlocBuilder<ProfileCubit, ProfileState>(
                    builder: (context, state) => CustomProfileContainer(
                      labelText: "Country",
                      textInputType: TextInputType.name,
                      isReadOnly: true,
                      controller: addressController,
                      onSelectCountry: (country) {
                        setState(() {
                          addressController.text = country;
                        });
                      },
                    ),
                  ),
                  Divider(
                    height: 30.h,
                  ),
                  // InfoRow(text: "Phone Num: ", info: phoneNumberController.text),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  BlocListener<ProfileCubit, ProfileState>(
                    listener: (_, state) {
                      if (state is UpdateUserSuccess) {
                        profile.getUser();
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
                        profile.updateUser(
                          User(
                            fCMToken: NotificationsCubit.get(context).fCMToken,
                            id: profile.user.id,
                            userName: userNameController.text,
                            email: profile.user.email,
                            phoneNumber: phoneNumberController.text,
                            bio: profile.user.bio,
                            friends: profile.user.friends,
                            groups: profile.user.friends,
                            profileImage: profile.user.profileImage,
                            city: addressController.text,
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
      ),
    );
  }
}
