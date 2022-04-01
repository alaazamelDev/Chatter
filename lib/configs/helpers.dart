import 'dart:math';

import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

abstract class Helpers {
  static final random = Random();

  static String randomPictureUrl() {
    final randomInt = random.nextInt(1000);
    return 'https://picsum.photos/300/300?random=$randomInt';
  }

  static DateTime randomDate() {
    final currentDate = DateTime.now();
    return currentDate.subtract(Duration(seconds: random.nextInt(200000)));
  }

  static String? getChannelImage(Channel channel, User currentUser) {
    if (channel.image != null) {
      print(channel.image);
    } else if (channel.state?.members.isNotEmpty ?? false) {
      final otherMembers = channel.state?.members
          .where((member) => member.userId != currentUser.id)
          .toList();
      if (otherMembers?.length == 1) {
        return otherMembers?.first.user?.image;
      }
    } else {
      return null;
    }
    return null;
  }

  static String getChannelName(Channel channel, User currentUser) {
    if (channel.name != null && channel.name!.isNotEmpty) {
      return channel.name!;
    } else if (channel.state?.members.isNotEmpty ?? false) {
      final otherMembers = channel.state?.members
          .where((member) => member.userId != currentUser.id)
          .toList();
      if (otherMembers?.length == 1) {
        return otherMembers!.first.user?.name ?? 'No name';
      }
    } else {
      return 'Multiple Users';
    }
    return 'No Channel Name';
  }
}
