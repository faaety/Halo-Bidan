// import 'package:flutter/material.dart';
// import 'package:halobidan/models/gruop_model.dart';
// import 'chat/chat_database.dart';
// import 'models/pokemon_model.dart';
// import 'package:halobidan/chat/model_chat_massage.dart';
//
//
//
// class ChatRoomPage extends StatefulWidget {
//   final PokemonModel member;
//   const ChatRoomPage(GroupModel group, {super.key, required this.member});
//
//   @override
//   State<ChatRoomPage> createState() => _ChatRoomPageState();
// }
//
// class _ChatRoomPageState extends State<ChatRoomPage> {
//   final TextEditingController _controller = TextEditingController();
//   List<ChatMessage> _messages = [];
//   ChatMessage? _replyMessage;
//
//   final List<String> _autoReplies = [
//     "Oke 👍",
//     "Siap!",
//     "Mantap 💯",
//     "Hehe iya 😁",
//     "Betul sekali",
//     "Hmm oke deh",
//     "Bye",
//     "Sip gaskeun 🚀",
//     "Hahaha 😂",
//     "Baiklah"
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _loadMessages();
//   }
//
//   Future<void> _loadMessages() async {
//     final raw = await ChatDatabase.instance.getRawMessages(widget.member.id.toString());
//     setState(() {
//       _messages = raw.map((row) {
//         return ChatMessage(
//           id: row["id"] as int?,
//           text: row["text"] as String,
//           sender: row["sender"] as String,
//           timestamp: DateTime.parse(row["timestamp"] as String),
//           isEdited: (row["isEdited"] as int) == 1,
//           replyTo: row["replyTo"] as String?,
//           replySender: row["replySender"] as String?,
//         );
//       }).toList();
//     });
//   }
//
//   void _sendMessage() async {
//     final text = _controller.text.trim();
//     if (text.isEmpty) return;
//
//
//     final newMsg = ChatMessage(
//       text: text,
//       sender: "me",
//       timestamp: DateTime.now(),
//       replyTo: _replyMessage?.text,
//       replySender: _replyMessage?.sender,
//     );
//
//     final id = await ChatDatabase.instance.insertMessage(newMsg, widget.member.id.toString());
//     setState(() {
//       _messages.add(newMsg.copyWith(id: id));
//       _controller.clear();
//       _replyMessage = null;
//     });
//
//     Future.delayed(const Duration(seconds: 2), () async {
//       final reply = (_autoReplies..shuffle()).first;
//       final botMsg = ChatMessage(
//         text: reply,
//         sender: widget.member.name,
//         timestamp: DateTime.now(),
//       );
//
//       final botId = await ChatDatabase.instance.insertMessage(botMsg, widget.member.id.toString());
//       setState(() {
//         _messages.add(botMsg.copyWith(id: botId));
//       });
//     });
//   }
//
//   void _deleteMessage(int index) async {
//     final msg = _messages[index];
//     if (msg.id != null) {
//       await ChatDatabase.instance.deleteMessage(msg.id!);
//     }
//     setState(() {
//       _messages.removeAt(index);
//     });
//   }
//
//   void _editMessage(int index) {
//     final oldText = _messages[index].text;
//     final controller = TextEditingController(text: oldText);
//
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text("Edit pesan"),
//         content: TextField(
//           controller: controller,
//           autofocus: true,
//           decoration: const InputDecoration(
//             hintText: "Tulis ulang pesan...",
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx),
//             child: const Text("Batal"),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               final newText = controller.text.trim();
//               if (newText.isNotEmpty && _messages[index].id != null) {
//                 await ChatDatabase.instance.updateMessage(_messages[index].id!, newText);
//                 setState(() {
//                   _messages[index] = _messages[index].copyWith(
//                     text: newText,
//                     isEdited: true,
//                     timestamp: DateTime.now(),
//                   );
//                 });
//               }
//               Navigator.pop(ctx);
//             },
//             child: const Text("Simpan"),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _setReply(ChatMessage msg) {
//     setState(() {
//       _replyMessage = msg;
//     });
//   }
//
//   Widget _buildMessageBubble(ChatMessage msg, int index) {
//     final isMe = msg.sender == "me";
//     return GestureDetector(
//       onLongPress: () {
//         showModalBottomSheet(
//           context: context,
//           builder: (ctx) => Wrap(
//             children: [
//               ListTile(
//                 leading: const Icon(Icons.reply),
//                 title: const Text("Balas"),
//                 onTap: () {
//                   Navigator.pop(ctx);
//                   _setReply(msg);
//                 },
//               ),
//               if (isMe)
//                 ListTile(
//                   leading: const Icon(Icons.edit),
//                   title: const Text("Edit"),
//                   onTap: () {
//                     Navigator.pop(ctx);
//                     _editMessage(index);
//                   },
//                 ),
//               if (isMe)
//                 ListTile(
//                   leading: const Icon(Icons.delete),
//                   title: const Text("Hapus"),
//                   onTap: () {
//                     Navigator.pop(ctx);
//                     _deleteMessage(index);
//                   },
//                 ),
//             ],
//           ),
//         );
//       },
//       child: Align(
//         alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
//         child: Container(
//           margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
//           padding: const EdgeInsets.all(10),
//           decoration: BoxDecoration(
//             color: isMe ? Colors.blueAccent : Colors.grey[400],
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               if (msg.replyTo != null)
//                 Container(
//                   margin: const EdgeInsets.only(bottom: 6),
//                   padding: const EdgeInsets.all(6),
//                   decoration: BoxDecoration(
//                     color: Colors.white70,
//                     borderRadius: BorderRadius.circular(6),
//                   ),
//                   child: Text(
//                     "${msg.replySender ?? ''}: ${msg.replyTo}",
//                     style: const TextStyle(
//                       fontSize: 12,
//                       fontStyle: FontStyle.italic,
//                       color: Colors.black87,
//                     ),
//                   ),
//                 ),
//               Text(
//                 msg.text,
//                 style: const TextStyle(color: Colors.white, fontSize: 16),
//               ),
//               const SizedBox(height: 4),
//               Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     "${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}",
//                     style: const TextStyle(fontSize: 10, color: Colors.white70),
//                   ),
//                   if (msg.isEdited) ...[
//                     const SizedBox(width: 6),
//                     const Text(
//                       "(edited)",
//                       style: TextStyle(
//                         fontSize: 10,
//                         color: Colors.white70,
//                         fontStyle: FontStyle.italic,
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Row(
//           children: [
//             CircleAvatar(
//               backgroundImage: AssetImage(widget.member.imagePath),
//             ),
//             const SizedBox(width: 8),
//             Text(widget.member.name),
//           ],
//         ),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               itemCount: _messages.length,
//               itemBuilder: (context, index) {
//                 return _buildMessageBubble(_messages[index], index);
//               },
//             ),
//           ),
//             if (_replyMessage != null)
//             Container(
//               padding: const EdgeInsets.all(8),
//               color: Colors.grey[300],
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Text(
//                       "Balas: ${_replyMessage!.text}",
//                       style: const TextStyle(
//                         fontStyle: FontStyle.italic,
//                         color: Colors.black87,
//                       ),
//                     ),
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.close),
//                     onPressed: () {
//                       setState(() => _replyMessage = null);
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           Container(
//             padding: const EdgeInsets.all(8),
//             color: Colors.grey[200],
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _controller,
//                     decoration: const InputDecoration(
//                       hintText: "Tulis pesan...",
//                       border: InputBorder.none,
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.send, color: Colors.blue),
//                   onPressed: _sendMessage,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
