import 'dart:io';
import 'package:chat_app/features/auth/cubit/auth_cubit.dart';
import 'package:chat_app/features/auth/cubit/auth_state.dart';
import 'package:chat_app/features/notifications/cubit/notifications_cubit.dart';
import 'package:chat_app/features/profile/cubit/profile_cubit.dart';
import 'package:chat_app/features/profile/cubit/profile_state.dart';
import 'package:chat_app/features/profile/ui/widgets/custom_profile_container.dart';
import 'package:chat_app/provider/app_provider.dart';
import 'package:chat_app/route_manager.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:chat_app/ui/widgets/default_text_button.dart';
import 'package:chat_app/ui/widgets/error_indicator.dart';
import 'package:chat_app/ui/widgets/loading_indicator.dart';
import 'package:chat_app/ui/widgets/widgets.dart';
import 'package:chat_app/utils/constants.dart';
import 'package:chat_app/utils/data/models/user.dart';
import 'package:chat_app/utils/helper_methods.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
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
  final formKey = GlobalKey<FormState>();
  final GlobalKey menuKey = GlobalKey();
  late ProfileCubit profile;

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
  void didChangeDependencies() {
    profile = ProfileCubit.get(context);
    super.didChangeDependencies();
  }

  Future<void> _pickAndCropImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9,
        ],
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: AppColors.primary,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: 'Crop Image',
            minimumAspectRatio: 1.0,
          ),
          WebUiSettings(
            context: context,
            boundary: const CroppieBoundary(
              width: 520,
              height: 520,
            ),
            viewPort:
                const CroppieViewPort(width: 480, height: 480, type: 'circle'),
            enableExif: true,
            enableZoom: true,
            showZoomer: true,
          ),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          imageFile = File(croppedFile.path);
        });
        if (context.mounted) {
          profile.uploadProfileImageToFireStorage(
            oldImageUrl: profile.user.profileImage ?? '',
            imageFile: imageFile!,
          );
        }
      }
    }
  }

  void _showPopupMenu(BuildContext context) {
    final RenderBox renderBox =
        menuKey.currentContext!.findRenderObject()! as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + renderBox.size.width,
        position.dy + renderBox.size.height,
      ),
      items: [
        PopupMenuItem(
          child: TextButton(
            onPressed: () {
              _pickAndCropImage();
              Navigator.pop(context);
            },
            child: const Text('Change'),
          ),
        ),
        PopupMenuItem(
          child: TextButton(
            onPressed: () {
              Navigator.pop(context);
              showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) {
                  return AlertDialog(
                    content: const Text(
                      "Are you sure you want delete profile picture?",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () {
                          profile.deleteProfileImage(
                            oldImageUrl: profile.user.profileImage ?? '',
                          );
                          Navigator.pop(context);
                        },
                        child: const Text("Delete"),
                      ),
                    ],
                  );
                },
              );
            },
            child: const Text('Remove'),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final authCubit = AuthCubit.get(context);
    final provider = Provider.of<MyAppProvider>(context);
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
              padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 22.h),
              child: Form(
                key: formKey,
                autovalidateMode: AutovalidateMode.always,
                child: Column(
                  children: [
                    SizedBox(height: 16.h),
                    _buildProfileImage(context, profile),
                    SizedBox(height: 24.h),
                    _buildBioSection(context),
                    SizedBox(height: 24.h),
                    Divider(
                      color: provider.themeMode == ThemeMode.dark
                          ? Colors.white
                          : Colors.black,
                    ),
                    SizedBox(height: 24.h),
                     Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'USER INFO',style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    _buildTextFields(context),
                    SizedBox(height: 40.h),
                    _buildSaveButton(context, profile, provider),
                    SizedBox(height: 24.h),
                    BlocListener<AuthCubit, AuthState>(
                      listener: (context, state) {
                        if (state is DeleteAccountLoading) {
                          const LoadingIndicator();
                        } else {
                          if (state is DeleteAccountSuccess) {
                            showSnackBar(
                              context,
                              Colors.green,
                              "Account deleted successfully",
                            );

                            if (context.mounted) {
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                Routes.login,
                                (route) => false,
                              );
                            }
                          }
                          if (state is DeleteAccountError) {
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                            const ErrorIndicator();
                          }
                        }
                      },
                      child: InkWell(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Delete account?'),
                                actionsOverflowDirection:
                                    VerticalDirection.down,
                                actions: [
                                  TextButton(
                                    child: const Text('Cancel'),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                  TextButton(
                                    child: const Text('Delete'),
                                    onPressed: () {
                                      authCubit.deleteAccount();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.black,
                              border: Border.all(color: Colors.white),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            child: Text(
                              "Delete account",
                              style: GoogleFonts.ubuntu(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage(BuildContext context, ProfileCubit profile) {
    return BlocConsumer<ProfileCubit, ProfileState>(
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
            if (context.mounted) {
              Navigator.pop(context);
              _showSnackBar(context, state.message, AppColors.error);
            }
          }
          if (state is UploadProfileImageSuccess) {
            _showSnackBar(context, "Successfully Uploaded", AppColors.primary);
            if (context.mounted) {
              Navigator.pop(context);
            }
          }
        }
        if (state is DeleteProfileImageLoading) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const LoadingIndicator();
            },
          );
        } else {
          if (state is DeleteProfileImageError) {
            if (context.mounted) {
              Navigator.pop(context);
              _showSnackBar(context, state.message, AppColors.error);
            }
          }
          if (state is DeleteProfileImageSuccess) {
            _showSnackBar(context, "Removed Successfully", AppColors.primary);
            if (context.mounted) {
              Navigator.pop(context);
            }
          }
        }
      },
      builder: (_, state) {
        return Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              height: 150.h,
              width: 165.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40.r),
              ),
              child: profile.user.profileImage != null &&
                      profile.user.profileImage!.isNotEmpty
                  ? InkWell(
                      onTap: () => showImageDialog(
                        context: context,
                        imageUrl: profile.user.profileImage!,
                        chatName: 'You',
                      ),
                      child: CircleAvatar(
                        backgroundColor: Colors.transparent,
                        child: FancyShimmerImage(
                          imageUrl: profile.user.profileImage!,
                          boxFit: BoxFit.cover,
                          width: 150.w,
                          height: 150.h,
                          imageBuilder: (context, imageProvider) =>
                              CircleAvatar(
                            backgroundImage: imageProvider,
                            radius: 50.r,
                          ),
                        ),
                      ),
                    )
                  : CircleAvatar(
                      backgroundColor: Colors.transparent,
                      radius: 135.r,
                      backgroundImage:
                          const NetworkImage(FirebasePath.defaultImage),
                    ),
            ),
            GestureDetector(
              key: menuKey,
              onTap: () => _showPopupMenu(context),
              child: const Icon(Icons.edit),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBioSection(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Bio"),
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: () {
                showEditBioSheet(context, bioController.text);
              },
              child: const Icon(Icons.edit, size: 24),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        BlocBuilder<ProfileCubit, ProfileState>(
          buildWhen: (_, current) =>
              current is UpdateUserBioLoading ||
              current is UpdateUserBioSuccess ||
              current is UpdateUserBioError,
          builder: (_, state) {
            return Text(
              bioController.text,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(color: AppColors.primary),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTextFields(BuildContext context) {
    return Column(
      children: [
        BlocBuilder<ProfileCubit, ProfileState>(
          builder: (_, state) {
            return CustomProfileContainer(
              labelText: "User Name",
              textInputType: TextInputType.name,
              controller: userNameController,
              validator: (value) => validateGeneral(value, 'user name'),
            );
          },
        ),
        SizedBox(height: 18.h,),
        CustomProfileContainer(
          labelText: "Email",
          isClickable: false,
          textInputType: TextInputType.emailAddress,
          controller: emailController,
          validator: validateEmail,
        ),
        SizedBox(height: 18.h,),
        BlocBuilder<ProfileCubit, ProfileState>(
          builder: (_, state) {
            return CustomProfileContainer(
              labelText: "Phone Number",
              textInputType: TextInputType.phone,
              controller: phoneNumberController,
              validator: validatePhoneNumber,
            );
          },
        ),
        SizedBox(height: 18.h,),
        BlocBuilder<ProfileCubit, ProfileState>(
          builder: (_, state) {
            return CustomProfileContainer(
              labelText: "Country",
              textInputType: TextInputType.text,
              isReadOnly: true,
              controller: addressController,
              onSelectCountry: (country) {
                setState(() {
                  addressController.text = country;
                });
              },
              validator: (value) => null,
            );
          },
        ),
      ],
    );
  }

  Widget _buildSaveButton(
    BuildContext context,
    ProfileCubit profile,
    MyAppProvider provider,
  ) {
    return BlocListener<ProfileCubit, ProfileState>(
      listener: (_, state) {
        if (state is UpdateUserSuccess) {
          profile.getUser();
          _showSnackBar(context, "Successfully Updated", AppColors.primary);
        }
      },
      child: DefaultTextButton(
        function: () {
          if (formKey.currentState!.validate()) {
            if (userNameController.text != profile.user.userName ||
                emailController.text != profile.user.email ||
                bioController.text != profile.user.bio ||
                phoneNumberController.text != profile.user.phoneNumber ||
                addressController.text != profile.user.city) {
              profile.updateUser(
                User(
                  fCMToken: NotificationsCubit.get(context).fCMToken,
                  id: profile.user.id,
                  userName: userNameController.text,
                  email: profile.user.email,
                  phoneNumber: phoneNumberController.text,
                  bio: profile.user.bio,
                  friends: profile.user.friends,
                  groups: profile.user.groups,
                  requests: profile.user.requests,
                  profileImage: profile.user.profileImage,
                  city: addressController.text,
                ),
              );
            }
          }
        },
        text: provider.language == "en" ? "Save changes" : "حفظ التعديلات",
      ),
    );
  }

  void _showSnackBar(
    BuildContext context,
    String message,
    Color backgroundColor,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontSize: 15)),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
