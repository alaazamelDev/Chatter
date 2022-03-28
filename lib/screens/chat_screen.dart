import 'package:chatter/models/message_data.dart';
import 'package:chatter/widgets/icon_border.dart';
import 'package:chatter/widgets/icon_buttons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  static Route route(MessageData data) => MaterialPageRoute(
        builder: (context) => ChatScreen(
          messageData: data,
        ),
      );

  const ChatScreen({
    Key? key,
    required this.messageData,
  }) : super(key: key);

  final MessageData messageData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 54,
        leading: Align(
          alignment: Alignment.centerRight,
          child: IconBackground(
            icon: CupertinoIcons.back,
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconBorder(
              icon: CupertinoIcons.phone_fill,
              onTap: () {},
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: IconBorder(
              icon: CupertinoIcons.video_camera_solid,
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}
