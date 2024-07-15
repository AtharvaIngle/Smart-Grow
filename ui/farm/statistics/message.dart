import 'package:dialog_flowtter/dialog_flowtter.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MessagesScreen extends StatefulWidget {
  final List messages;

  const MessagesScreen({Key key, this.messages}) : super(key: key);

  @override
  _MessagesScreenState createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    return ListView.separated(
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: widget.messages[index]['isUserMessage']
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(
                        widget.messages[index]['isUserMessage'] ? 0 : 20),
                    topLeft: Radius.circular(
                        widget.messages[index]['isUserMessage'] ? 20 : 0),
                  ),
                  color: widget.messages[index]['isUserMessage']
                      ? Colors.green.shade200.withOpacity(0.9)
                      : Colors.brown.shade200.withOpacity(0.8),
                ),
                constraints: BoxConstraints(maxWidth: w * 2 / 3),
                child: _buildMessageContent(widget.messages[index]['message']),
              ),
            ],
          ),
        );
      },
      separatorBuilder: (_, i) => Padding(padding: EdgeInsets.only(top: 10)),
      itemCount: widget.messages.length,
    );
  }

  Widget _buildMessageContent(Message message) {
    if (message.payload != null && message.payload.containsKey('richContent')) {
      var richContentList = message.payload['richContent'] as List;

      if (richContentList.isNotEmpty && richContentList[0] is List) {
        var richContent = richContentList[0] as List;

        if (richContent.isNotEmpty && richContent[0] is Map<String, dynamic>) {
          var contentItem = richContent[0] as Map<String, dynamic>;

          if (contentItem.containsKey('type')) {
            switch (contentItem['type']) {
              case 'info':
                if (contentItem.containsKey('actionLink')) {
                  // Handle info type with actionLink
                  return InkWell(
                    onTap: () async {
                      if (await canLaunch(contentItem['actionLink'])) {
                        await launch(contentItem['actionLink']);
                      } else {
                        throw 'Could not launch ${contentItem['actionLink']}';
                      }
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          contentItem['title'] ?? '',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Type: ${contentItem['type']}',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }
                break;
              case 'image':
                if (contentItem.containsKey('rawUrl')) {
                  // Handle image type
                  return InkWell(
                    onTap: () async {
                      // Handle image type click action
                    },
                    child: Image.network(
                      contentItem['rawUrl'] ?? '',
                      // Add additional image properties if needed
                    ),
                  );
                }
                break;
              // Add more cases for other types if necessary
            }
          }
        }
      }
    }

    // Default to displaying text if no rich response type is detected
    try {
      if (message.text.text.isNotEmpty) {
        return Text(
          message.text.text[0],
          style: TextStyle(color: Colors.black), // Change text color
        );
      } else {
        // Handle empty text case
        return Container();
      }
    } catch (e) {
      return Container();
    }
  }
}
