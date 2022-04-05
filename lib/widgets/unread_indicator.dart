import 'package:chatter/configs/theme.dart';
import 'package:flutter/material.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

// Widget to show an unread indicator
class UnreadIndicator extends StatelessWidget {
  /// Consrtuctor for creating an [UnreadIndicator]
  const UnreadIndicator({
    Key? key,
    required this.channel,
  }) : super(key: key);
  final Channel channel;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: BetterStreamBuilder<int>(
        stream: channel.state!.unreadCountStream,
        initialData: channel.state!.unreadCount,
        builder: (context, count) {
          if (count == 0) {
            return const SizedBox();
          }
          return Material(
            borderRadius: BorderRadius.circular(8),
            color: AppColors.secondary,
            child: Padding(
              padding: const EdgeInsets.only(
                left: 5,
                right: 5,
                top: 2,
                bottom: 2,
              ),
              child: Center(
                child: Text(
                  '${count > 99 ? '99+' : count}', // if it's great number show 99+ otherwise show the number
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
