import 'package:chatter/configs/app.dart';
import 'package:chatter/configs/theme.dart';
import 'package:chatter/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

void main() {
  // create stram api client
  final client = StreamChatClient(stramApiKey);

  runApp(MyApp(client: client));
}

class MyApp extends StatelessWidget {
  const MyApp({
    Key? key,
    required this.client,
  }) : super(key: key);
  final StreamChatClient client;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chatter',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.dark,
      builder: (context, child) {
        // Inject stream chat data provider
        return StreamChatCore(
          client: client,
          // Provide an injection of Channel Bloc
          child: ChannelsBloc(child: child!),
        );
      },
      home: SelectUserScreen(),
    );
  }
}
