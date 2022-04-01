import 'package:flutter/cupertino.dart';
import 'package:logger/logger.dart' as log;
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

const stramApiKey = 'jbtanmp4vquz';

final logger = log.Logger();

// Extensions can be used to add functionality to the SDK
extension StreamChatContext on BuildContext {
  // Fetch the current user image
  String? get currentUserImage => currentUser!.image;
  // Fetch the current user object
  User? get currentUser => StreamChatCore.of(this).currentUser;
}
