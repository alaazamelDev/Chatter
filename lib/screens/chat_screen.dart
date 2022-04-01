import 'package:chatter/configs/app.dart';
import 'package:chatter/configs/helpers.dart';
import 'package:chatter/configs/theme.dart';
import 'package:chatter/widgets/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';
import 'package:jiffy/jiffy.dart';

class ChatScreen extends StatelessWidget {
  static Route routeWithChannel(Channel channel) => MaterialPageRoute(
        builder: (context) => StreamChannel(
          channel: channel,
          child: const ChatScreen(),
        ),
      );

  const ChatScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const _AppBarTitle(),
        iconTheme: Theme.of(context).iconTheme,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 54,
        leading: AppBarBackButton(onTap: () {
          Navigator.pop(context);
        }),
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
      body: Column(
        children: [
          Expanded(
            child: MessageListCore(
              loadingBuilder: (context) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
              emptyBuilder: (context) => const SizedBox.shrink(),
              errorBuilder: (context, error) =>
                  DisplayErrorMessage(error: error),
              messageListBuilder:
                  (BuildContext context, List<Message> messages) {
                // Build the ListView which contains actual messages
                return _DemoMessageList(messages: messages);
              },
            ),
          ),
          const _ActionBar(),
        ],
      ),
    );
  }
}

class _AppBarTitle extends StatelessWidget {
  const _AppBarTitle({
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final channel = StreamChannel.of(context).channel;
    return Row(
      children: [
        Avatar.small(
          url: Helpers.getChannelImage(channel, context.currentUser!),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                Helpers.getChannelName(channel, context.currentUser!),
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 2),
              // Show the state of the user wheather online or offline
              BetterStreamBuilder<List<Member>>(
                stream: channel.state!.membersStream,
                initialData: channel.state!.members,
                builder: (context, members) {
                  return ConnectionStatusBuilder(
                    statusBuilder: (context, status) {
                      switch (status) {
                        case ConnectionStatus.connected:
                          return _buildConnectedTitleState(context, members);
                        case ConnectionStatus.connecting:
                          return const Text(
                            'Connecting',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.green),
                          );
                        case ConnectionStatus.disconnected:
                          return const Text(
                            'Offline',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.red),
                          );
                        default:
                          return const SizedBox.shrink();
                      }
                    },
                  );
                },
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildConnectedTitleState(
    BuildContext context,
    List<Member>? members,
  ) {
    Widget? alternativeWidget;
    final channel = StreamChannel.of(context).channel;
    final memberCount = channel.memberCount;

    if (memberCount != null && memberCount > 2) {
      var text = 'Members: $memberCount';
      final watcherCount = channel.state!.watcherCount ?? 0;
      if (watcherCount > 0) {
        text = 'watchers: $watcherCount';
      }
      alternativeWidget = Text(
        text,
        style: const TextStyle(
          fontSize: 10,
        ),
      );
    } else {
      final userId = StreamChatCore.of(context).currentUser?.id;
      final otherMember = members?.firstWhere(
        (element) => element.userId != userId,
      );

      if (otherMember != null) {
        if (otherMember.user?.online == true) {
          alternativeWidget = const Text(
            'Online',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          );
        } else {
          // calculate distance of time since last online
          alternativeWidget = Text(
            'Last seen:'
            '${Jiffy(otherMember.user?.lastActive).fromNow()}',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          );
        }
      }
    }
    return TypingIndicator(
      alternativeWidget: alternativeWidget,
    );
  }
}

class TypingIndicator extends StatelessWidget {
  const TypingIndicator({
    Key? key,
    this.alternativeWidget,
  }) : super(key: key);
  final Widget? alternativeWidget;

  @override
  Widget build(BuildContext context) {
    // get an instance of channel state object
    final channelState = StreamChannel.of(context).channel.state!;

    final altWidget = alternativeWidget ?? const Offstage();
    return BetterStreamBuilder<Iterable<User>>(
      initialData: channelState.typingEvents.keys,
      stream: channelState.typingEventsStream
          .map((typings) => typings.entries.map((e) => e.key)),
      builder: (context, data) {
        return Align(
          alignment: Alignment.centerLeft,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: data.isNotEmpty
                ? const Align(
                    alignment: Alignment.centerLeft,
                    key: ValueKey('typing-text'),
                    child: Text(
                      'Typing...',
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : Align(
                    alignment: Alignment.centerLeft,
                    key: const ValueKey('altwidget'),
                    child: altWidget,
                  ),
          ),
        );
      },
    );
  }
}

class _DemoMessageList extends StatelessWidget {
  const _DemoMessageList({
    Key? key,
    required this.messages,
  }) : super(key: key);
  final List<Message> messages;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      children: messages.map<Widget>((message) {
        final currentUserId = context.currentUser!.id;

        // To handle the right ListTile layout selection
        final isSentByMe = message.user?.id == currentUserId;

        return isSentByMe
            ? _MessageOwnTile(
                message: message.text!,
                messageDate: message.createdAt.toLocal().toString(),
              )
            : _MessageTile(
                message: message.text!,
                messageDate: message.createdAt.toLocal().toString(),
              );
      }).toList(),
      // const [
      //   _DateLable(lable: 'Yesterday'),
      //   _MessageTile(
      //     message: 'Hello Alaa, How\'re you doing Today?',
      //     messageDate: '12:48 PM',
      //   ),
      //   _MessageOwnTile(
      //     message: 'Great, How about you?',
      //     messageDate: '12:49 PM',
      //   ),
      //   _MessageTile(
      //     message: 'Same, Thanks for asking',
      //     messageDate: '12:49 PM',
      //   ),
      //   _MessageOwnTile(
      //     message: 'How does your university is going? Well?',
      //     messageDate: '12:50 PM',
      //   ),
      // ],
    );
  }
}

class _DateLable extends StatelessWidget {
  const _DateLable({
    Key? key,
    required this.lable,
  }) : super(key: key);
  final String lable;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).cardColor,
          ),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
            child: Text(
              lable,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textFaded,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageTile extends StatelessWidget {
  const _MessageTile({
    Key? key,
    required this.message,
    required this.messageDate,
  }) : super(key: key);
  final String message;
  final String messageDate;

  // for design perspictive
  final _borderRadius = 26.0;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(_borderRadius),
                  topRight: Radius.circular(_borderRadius),
                  bottomRight: Radius.circular(_borderRadius),
                ),
                color: Theme.of(context).cardColor,
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                child: Text(message),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                messageDate,
                style: const TextStyle(
                  color: AppColors.textFaded,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _MessageOwnTile extends StatelessWidget {
  const _MessageOwnTile({
    Key? key,
    required this.message,
    required this.messageDate,
  }) : super(key: key);
  final String message;
  final String messageDate;

  // for design perspictive
  final _borderRadius = 26.0;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Align(
        alignment: Alignment.centerRight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(_borderRadius),
                  bottomRight: Radius.circular(_borderRadius),
                  bottomLeft: Radius.circular(_borderRadius),
                ),
                color: AppColors.secondary,
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                child: Text(
                  message,
                  style: const TextStyle(
                    color: AppColors.textLigth,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                messageDate,
                style: const TextStyle(
                  color: AppColors.textFaded,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      top: false,
      child: Card(
        margin: const EdgeInsets.all(0),
        shape: const RoundedRectangleBorder(),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Camera icon
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      width: 2,
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Icon(
                    CupertinoIcons.camera_fill,
                  ),
                ),
              ),
              // Textfield for message typing
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 100),
                    child: const TextField(
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      style: TextStyle(fontSize: 14, height: 1.5),
                      decoration: InputDecoration(
                        hintText: 'Type something...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ),
              // Send message button
              Padding(
                padding: const EdgeInsets.only(left: 12.0, right: 20.0),
                child: GlowingActionButton(
                  size: 50,
                  spreadRadius: 2,
                  icon: Icons.send_rounded,
                  color: AppColors.accent,
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget that builds itself based on the latest snapshot of interaction with
/// a [Stream] of type [ConnectionStatus].
///
/// The widget will use the closest [StreamChatClient.wsConnectionStatusStream]
/// in case no stream is provided.
class ConnectionStatusBuilder extends StatelessWidget {
  /// Creates a new ConnectionStatusBuilder
  const ConnectionStatusBuilder({
    Key? key,
    required this.statusBuilder,
    this.connectionStatusStream,
    this.errorBuilder,
    this.loadingBuilder,
  }) : super(key: key);

  /// The asynchronous computation to which this builder is currently connected.
  final Stream<ConnectionStatus>? connectionStatusStream;

  /// The builder that will be used in case of error
  final Widget Function(BuildContext context, Object? error)? errorBuilder;

  /// The builder that will be used in case of loading
  final WidgetBuilder? loadingBuilder;

  /// The builder that will be used in case of data
  final Widget Function(BuildContext context, ConnectionStatus status)
      statusBuilder;

  @override
  Widget build(BuildContext context) {
    final stream = connectionStatusStream ??
        StreamChatCore.of(context).client.wsConnectionStatusStream;
    final client = StreamChatCore.of(context).client;
    return BetterStreamBuilder<ConnectionStatus>(
      initialData: client.wsConnectionStatus,
      stream: stream,
      noDataBuilder: loadingBuilder,
      errorBuilder: (context, error) {
        if (errorBuilder != null) {
          return errorBuilder!(context, error);
        }
        return const Offstage();
      },
      builder: statusBuilder,
    );
  }
}
