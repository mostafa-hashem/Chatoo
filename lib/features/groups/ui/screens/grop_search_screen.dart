import 'package:chat_app/features/groups/cubit/group_cubit.dart';
import 'package:chat_app/features/groups/cubit/group_states.dart';
import 'package:chat_app/features/groups/ui/widgets/groupe_tile.dart';
import 'package:chat_app/route_manager.dart';
import 'package:chat_app/ui/resources/app_colors.dart';
import 'package:chat_app/widgets/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class GroupSearchScreen extends StatefulWidget {
  const GroupSearchScreen({super.key});

  @override
  State<GroupSearchScreen> createState() => _GroupSearchScreenState();
}

class _GroupSearchScreenState extends State<GroupSearchScreen> {
  TextEditingController searchOnGroupsController = TextEditingController();
  bool isLoading = false;
  QuerySnapshot? searchSnapshot;
  bool hasUserSearched = false;
  String userName = "";
  bool isJoined = false;
  User? user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: 60,
        elevation: 0,
        backgroundColor: AppColors.primary,
        title: Text(
          "Search",
          style: GoogleFonts.ubuntu(
            fontSize: 18.sp,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value)=> GroupCubit.get(context).searchOnGroup(value),
                    controller: searchOnGroupsController,
                    style: GoogleFonts.ubuntu(color: Colors.white),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Search groups....",
                      hintStyle: GoogleFonts.novaFlat(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {

                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<GroupCubit, GroupStates>(
                builder: (context, state) {
                  return ListView.separated(
                    itemBuilder:(context, index) => GroupTile(groupId: GroupCubit.get(context).searchedGroups[index].groupId,groupName: GroupCubit.get(context).searchedGroups[index].groupName,userName: GroupCubit.get(context).searchedGroups[index].groupId),
                    separatorBuilder: (context, index) =>
                        Divider(thickness: 4.h,),
                    itemCount: GroupCubit.get(context).searchedGroups.length,
                  );
                }
            ),
          )
        ],
      ),
    );
  }

  searchOnGroupsMethod() async {
    if (searchOnGroupsController.text.isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      // await DatabaseServices()
      //     .searchGroupsByName(searchOnGroupsController.text)
      //     .then((snapshot) {
      //   setState(() {
      //     searchSnapshot = snapshot;
      //     isLoading = false;
      //     hasUserSearched = true;
      //   });
      // });
    }
  }

// Widget groupList() {
//   return hasUserSearched
//       ? ListView.builder(
//           shrinkWrap: true,
//           itemCount: searchSnapshot!.docs.length,
//           itemBuilder: (context, index) {
//             return groupTitle(
//               userName,
//               // searchSnapshot!.docs[index]["groupId"],
//               // searchSnapshot!.docs[index]["groupName"],
//               // searchSnapshot!.docs[index]["admin"],
//             );
//           },)
//       : Center(
//           child: Text(
//           "No results found.",
//           style: Theme.of(context).textTheme.bodyMedium,
//         ),);
// }

// joinedOrNot(String userName, String groupId, String groupName,
//     String adminName,) async {
//   await DatabaseServices(uid: user!.uid)
//       .isUserJoined(groupName, groupId, userName)
//       .then((value) {
//     setState(() {
//       isJoined = value;
//     });
//   });
// }

Widget groupTitle(
    String userName, String groupId, String groupName, String adminName,) {
  //check whether user already exists in group
  return InkWell(
    onTap: () {
      isJoined
          ? Navigator.pushReplacementNamed(
              context,
              Routes.groupChatScreen,)
          : null;
    },
    child: Padding(
      padding: const EdgeInsets.all(8),
      child: ListTile(
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: AppColors.primary,
          child: Text(
            getName(groupName).substring(0, 1).toUpperCase(),
            style: GoogleFonts.ubuntu(
                fontWeight: FontWeight.w500, color: Colors.white,),
          ),
        ),
        title: Text(
          groupName,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        subtitle: Text(
          "Admin: ${getName(adminName)}",
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: InkWell(
          onTap: () async {
            if (isJoined) {
              setState(() {
                isJoined = !isJoined;
              });
              showSnackBar(
                  context, Colors.green, "Successfully joined he group",);
              Future.delayed(const Duration(seconds: 2), () {
                Navigator.pushReplacementNamed(
                    context,
                    Routes.groupChatScreen,);
              });
            } else {
              setState(() {
                isJoined = !isJoined;
                showSnackBar(context, Colors.red, "Left the group $groupName");
              });
            }
          },
          child: isJoined
              ? Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.black,
                    border: Border.all(color: Colors.white),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text("Joined",
                      style: GoogleFonts.ubuntu(color: Colors.white),),
                )
              : Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: AppColors.primary,
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text("Join",
                      style: GoogleFonts.ubuntu(color: Colors.white),),
                ),
        ),
      ),
    ),
  );
}
}
