import 'package:chatter/configs/app.dart';
import 'package:chatter/configs/helpers.dart';
import 'package:chatter/configs/theme.dart';
import 'package:chatter/models/models.dart';
import 'package:chatter/screens/chat_screen.dart';
import 'package:chatter/widgets/widgets.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({Key? key}) : super(key: key);

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final _controller = ChannelListController();
  @override
  Widget build(BuildContext context) {
    return ChannelListCore(
      channelListController: _controller,
      filter: Filter.and([
        Filter.equal('type', 'messaging'),
        Filter.in_('members', [
          context.currentUser!.id,
        ]),
      ]),
      errorBuilder: (context, error) => DisplayErrorMessage(error: error),
      emptyBuilder: (context) {
        return const Center(
          child: Text(
            'So Empty.\nGo and make a new chat',
            textAlign: TextAlign.center,
          ),
        );
      },
      loadingBuilder: (context) => const Center(
        child: SizedBox(
          width: 100,
          height: 100,
          child: CircularProgressIndicator(),
        ),
      ),
      listBuilder: (context, channels) {
        return CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: _Stories(),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return _MessageTile(channel: channels[index]);
                },
                childCount: channels.length,
              ),
            )
          ],
        );
      },
    );
  }
}

class _MessageTile extends StatelessWidget {
  const _MessageTile({
    Key? key,
    required this.channel,
  }) : super(key: key);
  final Channel channel;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Go to chat screen
        Navigator.push(context, ChatScreen.routeWithChannel(channel));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        height: 100,
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey,
              width: 0.2,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Avatar.medium(
                  url: Helpers.getChannelImage(channel, context.currentUser!),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        Helpers.getChannelName(channel, context.currentUser!),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.2,
                          wordSpacing: 1.5,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                      child: _buildLastMessage(),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const SizedBox(height: 4),
                    _buildLastMessageAt(),
                    const SizedBox(height: 8),
                    // Container(
                    //   width: 18,
                    //   height: 18,
                    //   decoration: const BoxDecoration(
                    //     shape: BoxShape.circle,
                    //     color: AppColors.secondary,
                    //   ),
                    //   child: Center(
                    //     child: UnreadIndicator(
                    //       channel: channel,
                    //     ),
                    //   ),
                    // ),
                    UnreadIndicator(
                      channel: channel,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLastMessage() {
    return BetterStreamBuilder<int>(
      stream: channel.state!.unreadCountStream,
      initialData: channel.state!.unreadCount,
      builder: (BuildContext context, int count) {
        return BetterStreamBuilder<Message>(
          stream: channel.state!.lastMessageStream,
          initialData: channel.state!.lastMessage,
          builder: (BuildContext context, Message lastMessage) {
            return Text(
              lastMessage.text ?? '',
              overflow: TextOverflow.ellipsis,
              style: count > 0
                  ? const TextStyle(
                      color: AppColors.secondary,
                      fontSize: 12,
                    )
                  : const TextStyle(
                      color: AppColors.textFaded,
                      fontSize: 12,
                    ),
            );
          },
        );
      },
    );
  }

  Widget _buildLastMessageAt() {
    return BetterStreamBuilder<DateTime>(
      stream: channel.lastMessageAtStream,
      initialData: channel.lastMessageAt,
      builder: (context, date) {
        // get last message date
        final lastMessageAt = date.toLocal();
        String stringDate;

        final now = DateTime.now();

        // set the time of recieveing message as starting point
        final startOfDay = DateTime(now.year, now.month, now.day);

        if (lastMessageAt.millisecondsSinceEpoch >=
            startOfDay.millisecondsSinceEpoch) {
          stringDate = Jiffy(lastMessageAt.toLocal()).jm;
        } else if (lastMessageAt.millisecondsSinceEpoch >=
            startOfDay
                .subtract(const Duration(days: 1))
                .millisecondsSinceEpoch) {
          stringDate = 'YESTERDAY';
        } else if (startOfDay.difference(lastMessageAt).inDays < 7) {
          stringDate = Jiffy(lastMessageAt.toLocal()).EEEE;
        } else {
          stringDate = Jiffy(lastMessageAt.toLocal()).yMd;
        }

        return Text(
          stringDate,
          style: const TextStyle(
            fontSize: 11,
            letterSpacing: -0.2,
            fontWeight: FontWeight.w600,
            color: AppColors.textFaded,
          ),
        );
      },
    );
  }
}

// Top ListView that shows the stories of user's contacts
class _Stories extends StatelessWidget {
  const _Stories({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: SizedBox(
        height: 134,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 16, top: 8, left: 16),
              child: Text(
                'Stories',
                style: TextStyle(
                  color: AppColors.textFaded,
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  final faker = Faker();
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 60,
                      child: _StoryCard(
                        storyData: StoryData(
                          name: faker.person.name(),
                          url: Helpers.randomPictureUrl(),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoryCard extends StatelessWidget {
  const _StoryCard({
    Key? key,
    required this.storyData,
  }) : super(key: key);

  final StoryData storyData;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Avatar.medium(url: storyData.url),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              storyData.name,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                letterSpacing: 0.3,
              ),
            ),
          ),
        )
      ],
    );
  }
}
