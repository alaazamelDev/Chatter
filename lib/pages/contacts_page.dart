import 'package:chatter/configs/app.dart';
import 'package:chatter/screens/chat_screen.dart';
import 'package:chatter/widgets/avatar.dart';
import 'package:chatter/widgets/display_error_message.dart';
import 'package:flutter/material.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

class ContactsPage extends StatelessWidget {
  const ContactsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return UserListCore(
      limit: 20,
      filter: Filter.notEqual('id', context.currentUser!.id),
      errorBuilder: (context, error) {
        return DisplayErrorMessage(error: error);
      },
      emptyBuilder: (context) {
        return const Center(
          child: Text('There are no users'),
        );
      },
      loadingBuilder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
      listBuilder: (context, contacts) {
        return Scrollbar(
          child: ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              return contacts[index].when(
                headerItem: (_) => const SizedBox.shrink(),
                userItem: (user) => _ContactTile(
                  user: user,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    Key? key,
    required this.user,
  }) : super(key: key);

  final User user;

  // Create  a new messsaging channel
  Future<void> _createChannel(BuildContext context) async {
    final core = StreamChatCore.of(context);
    final channel = core.client.channel('messaging', extraData: {
      'members': [
        core.currentUser!.id, // Current User
        user.id, // User to contact with
      ],
    });
    // watch the created channel
    await channel.watch();
    Navigator.push(context, ChatScreen.routeWithChannel(channel));
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        _createChannel(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
        child: Row(
          children: [
            Avatar.small(
              url: user.image,
            ),
            const SizedBox(width: 16),
            Text(user.name)
          ],
        ),
      ),
    );
  }
}
