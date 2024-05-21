import 'dart:io';

import 'package:chat_app/features/notifications/cubit/notifications_cubit.dart';
import 'package:chat_app/features/profile/cubit/profile_cubit.dart';
import 'package:chat_app/features/profile/cubit/profile_state.dart';
import 'package:chat_app/features/profile/ui/widgets/custom_profile_container.dart';
import 'package:chat_app/provider/app_provider.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:chat_app/ui/widgets/default_text_button.dart';
import 'package:chat_app/ui/widgets/loading_indicator.dart';
import 'package:chat_app/ui/widgets/widgets.dart';
import 'package:chat_app/utils/constants.dart';
import 'package:chat_app/utils/data/models/user.dart';
import 'package:chat_app/utils/helper_methods.dart';
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
          CropAspectRatioPreset.ratio16x9
        ],
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.deepOrange,
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
          final profile = ProfileCubit.get(context);
          profile.uploadProfileImageToFireStorage(
            profile.user.id!,
            imageFile!,
          );
        }
      }
    }
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
              child: Form(
                key: formKey,
                autovalidateMode: AutovalidateMode.always,
                child: Column(
                  children: [
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
                            height: 150.h,
                            width: 165.w,
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
                                    child: CircleAvatar(
                                      backgroundColor: Colors.transparent,
                                      backgroundImage: NetworkImage(
                                        profile.user.profileImage!,
                                      ),
                                    ),
                                  )
                                : CircleAvatar(
                                    backgroundColor: Colors.transparent,
                                    radius: 135.r,
                                    backgroundImage: const NetworkImage(
                                      FirebasePath.defaultImage,
                                    ),
                                  ),
                          ),
                          GestureDetector(
                            onTap: _pickAndCropImage,
                            child: const Icon(Icons.edit),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.03,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Bio"),
                        SizedBox(
                          width: 8.w,
                        ),
                        GestureDetector(
                          onTap: () {
                            showEditBioSheet(context, bioController.text);
                          },
                          child: const Icon(
                            Icons.edit,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.01,
                    ),
                    BlocBuilder<ProfileCubit, ProfileState>(
                      buildWhen: (_, currentState) =>
                          currentState is UpdateUserBioLoading ||
                          currentState is UpdateUserBioSuccess ||
                          currentState is UpdateUserBioError,
                      builder: (context, state) {
                        return Text(
                          bioController.text,
                          style:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: AppColors.primary,
                                  ),
                        );
                      },
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.02,
                    ),
                    BlocBuilder<ProfileCubit, ProfileState>(
                      builder: (_, state) => CustomProfileContainer(
                        labelText: "User Name",
                        textInputType: TextInputType.name,
                        controller: userNameController,
                        validator: (value) =>
                            validateGeneral(value, 'user name'),
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
                      validator: validateEmail,
                    ),
                    Divider(
                      height: 30.h,
                    ),
                    BlocBuilder<ProfileCubit, ProfileState>(
                      builder: (_, state) => CustomProfileContainer(
                        labelText: "Phone Num",
                        textInputType: TextInputType.number,
                        controller: phoneNumberController,
                        validator: validatePhoneNumber,
                      ),
                    ),
                    Divider(
                      height: 30.h,
                    ),
                    BlocBuilder<ProfileCubit, ProfileState>(
                      builder: (_, state) => CustomProfileContainer(
                        labelText: "Country",
                        textInputType: TextInputType.name,
                        isReadOnly: true,
                        controller: addressController,
                        onSelectCountry: (country) {
                          setState(() {
                            addressController.text = country;
                          });
                        },
                        validator: (value) {
                          return null;
                        },
                      ),
                    ),
                    Divider(
                      height: 30.h,
                    ),
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
                          if (formKey.currentState!.validate()) {
                            if (userNameController.text !=
                                    profile.user.userName! ||
                                emailController.text != profile.user.email! ||
                                bioController.text != profile.user.bio! ||
                                phoneNumberController.text !=
                                    profile.user.phoneNumber! ||
                                addressController.text != profile.user.city!) {
                              profile.updateUser(
                                User(
                                  fCMToken:
                                      NotificationsCubit.get(context).fCMToken,
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
                        text: provider.language == "en"
                            ? "Save changes"
                            : "حفظ التعديلات",
                      ),
                    ),
                    SizedBox(
                      height: 24.h,
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
