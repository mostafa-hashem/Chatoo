// import 'package:chat_app/screens/chats/frinds_chat_screen.dart';
// import 'package:chat_app/services/database_services.dart';
// import 'package:chat_app/ui/resources/app_colors.dart';
// import 'package:chat_app/widgets/widgets.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:google_fonts/google_fonts.dart';
//
// class SearchOnFriendsScreen extends StatefulWidget {
//   const SearchOnFriendsScreen({super.key});
//
//   @override
//   State<SearchOnFriendsScreen> createState() => _SearchOnFriendsScreenState();
// }
//
// class _SearchOnFriendsScreenState extends State<SearchOnFriendsScreen> {
//   TextEditingController searchOnFriendsController = TextEditingController();
//   bool isLoading = false;
//   QuerySnapshot? searchSnapshot;
//   bool hasUserSearched = false;
//   bool isFriend = false;
//   String? friendId;
//   String? friendName;
//   String? bio;
//   User? user;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         toolbarHeight: 60,
//         elevation: 0,
//         backgroundColor: AppColors.primary,
//         title: Text(
//           "Search",
//           style: GoogleFonts.ubuntu(
//               fontSize: 18.sp,
//               fontWeight: FontWeight.w400,
//               color: Colors.white,),
//         ),
//       ),
//       body: Column(
//         children: [
//           Container(
//             color: AppColors.primary,
//             padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: searchOnFriendsController,
//                     style: GoogleFonts.ubuntu(color: Colors.white),
//                     decoration: InputDecoration(
//                         border: InputBorder.none,
//                         hintText: "Search friends....",
//                         hintStyle: GoogleFonts.novaFlat(
//                             color: Colors.white, fontSize: 16,),),
//                   ),
//                 ),
//                 GestureDetector(
//                   onTap: () {
//                     searchOnFriendsMethod();
//                   },
//                   child: Container(
//                     width: 40,
//                     height: 40,
//                     decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(40),),
//                     child: const Icon(
//                       Icons.search,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           if (isLoading) const Center(
//             child:
//             CircularProgressIndicator(color: AppColors.primary),
//           ) else friendList(),
//         ],
//       ),
//     );
//   }
//
//   Future<void> searchOnFriendsMethod() async {
//     setState(() {
//       isLoading = true;
//       hasUserSearched = false;
//     });
//
//     await DatabaseServices()
//         .searchFriendsByName(searchOnFriendsController.text)
//         .then((snapshot) {
//       setState(() {
//         searchSnapshot = snapshot;
//         isLoading = false;
//         hasUserSearched = true;
//       });
//     });
//   }
//
//   Widget friendList() {
//     return hasUserSearched
//         ? ListView.builder(
//         shrinkWrap: true,
//         itemCount: searchSnapshot!.docs.length,
//         itemBuilder: (context, index) {
//           return friendTitle(
//             searchSnapshot!.docs[index]["fullName"],
//             searchSnapshot!.docs[index]["uid"],
//           );
//         },)
//         : Center(
//         child: Text(
//           "No results found.",
//           style: Theme.of(context).textTheme.bodyMedium,
//         ),);
//   }
//
//   friendOrNot( String friendName,  String friendId,) async {
//     await DatabaseServices(uid: user!.uid)
//         .isUserFriend(friendName, friendId)
//         .then((value) {
//       setState(() {
//         isFriend = value;
//       });
//     });
//   }
//
//   Widget friendTitle(String friendName, String friendId) {
//     //check whether user already exists in group
//     friendOrNot(friendName, friendId);
//     return InkWell(
//       onTap: () {
//         isFriend
//             ? nextScreen(
//                 context,
//                 FriendsChatScreen(
//                   friendId: friendId,
//                   friendName: friendName,
//                   bio: '',
//                 ),)
//             : null;
//       },
//       child: Padding(
//         padding: const EdgeInsets.all(8),
//         child: ListTile(
//           leading: CircleAvatar(
//             radius: 30,
//             backgroundColor: AppColors.primary,
//             child: Text(
//               getName(friendName).substring(0, 1).toUpperCase(),
//               style: GoogleFonts.ubuntu(
//                   fontWeight: FontWeight.w500, color: Colors.white,),
//             ),
//           ),
//           title: Text(
//             getName(friendName),
//             style: Theme.of(context).textTheme.bodyMedium,
//           ),
//           trailing: InkWell(
//             onTap: () async {
//               await DatabaseServices(uid: user!.uid)
//                   .toggleFriendOrNot(friendId, friendName);
//               if (isFriend) {
//                 setState(() {
//                   isFriend = !isFriend;
//                 });
//                 showSnackBar(
//                     context, Colors.green, "Successfully added",);
//                 Future.delayed(const Duration(seconds: 2), () {
//                   nextScreen(
//                       context,
//                       FriendsChatScreen(
//                         friendName: friendName,
//                         friendId: friendId,
//                         bio: "",
//                       ),);
//                 });
//               } else {
//                 setState(() {
//                   isFriend = !isFriend;
//                   showSnackBar(context, Colors.red, "Unfriend $friendName");
//                 });
//               }
//             },
//             child: isFriend
//                 ? Container(
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(10),
//                       color: Colors.black,
//                       border: Border.all(color: Colors.white),
//                     ),
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                     child: Text("Already friend",
//                         style: GoogleFonts.ubuntu(color: Colors.white),),
//                   )
//                 : Container(
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(10),
//                       color: AppColors.primary,
//                     ),
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                     child: Text("Add friend",
//                         style: GoogleFonts.ubuntu(color: Colors.white),),
//                   ),
//           ),
//         ),
//       ),
//     );
//   }
// }
