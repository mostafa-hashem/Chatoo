// import 'package:chat_app/features/friends/ui/screens/friend_chat_screen.dart';
// import 'package:chat_app/ui/resources/app_colors.dart';
// import 'package:chat_app/widgets/widgets.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
//
// class FriendTile extends StatefulWidget {
//   const FriendTile({
//     super.key,
//     required this.friendId,
//     required this.friendName,
//     required this.bio,
//   });
//
//   final String friendName;
//   final String friendId;
//   final String bio;
//
//   @override
//   State<FriendTile> createState() => _FriendTileState();
// }
//
// class _FriendTileState extends State<FriendTile> {
//   String userName = "";
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         nextScreen(
//           context,
//           FriendsChatScreen(
//             friendName: widget.friendName,
//             friendId: widget.friendId,
//             bio: widget.bio,
//           ),
//         );
//       },
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
//         child: ListTile(
//           leading: CircleAvatar(
//             radius: 30,
//             backgroundColor: AppColors.primary,
//             child: Text(
//               widget.friendName.substring(0, 1).toUpperCase(),
//               textAlign: TextAlign.center,
//               style: GoogleFonts.ubuntu(
//                 fontWeight: FontWeight.w500,
//                 color: Colors.white,
//               ),
//             ),
//           ),
//           title: Text(
//             widget.friendName,
//             style: GoogleFonts.novaSquare(fontWeight: FontWeight.bold),
//           ),
//           subtitle: Text(
//             widget.bio,
//             style: GoogleFonts.ubuntu(fontSize: 13),
//           ),
//         ),
//       ),
//     );
//   }
// }
