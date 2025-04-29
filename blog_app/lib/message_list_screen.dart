import 'package:flutter/material.dart';
import 'helpers/database_helper.dart';
import 'models/message.dart';
import 'message_form_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'message_detail_screen.dart';
import 'package:blog_app/services/twitter_service.dart';


class MessageListScreen extends StatefulWidget {
  @override
  _MessageListScreenState createState() => _MessageListScreenState();
}

class _MessageListScreenState extends State<MessageListScreen> {
  List<Message> _messages = [];
  List<int> _selectedIds = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  // void _uploadGroupToTwitter() async {
  //   final selectedMessages = _messages.where((msg) => _selectedIds.contains(msg.id)).toList();
  //   if (selectedMessages.isEmpty) return;
  //
  //   String content = '';
  //   for (var message in selectedMessages) {
  //     content += message.content;
  //     if (message.description != null && message.description!.isNotEmpty) {
  //       content += '\n${message.description}';
  //     }
  //     content += '\n\n';
  //   }
  //
  //   try {
  //     // Initialize TwitterService
  //     final twitterService = TwitterService();
  //
  //     // Post the tweet using TwitterService
  //     await twitterService.postTweet(content);
  //
  //     // Show success message
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Successfully posted to Twitter')));
  //   } catch (e) {
  //     // Handle error posting tweet
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error posting to Twitter')));
  //   }
  // }

  void _uploadGroupToTwitter() async {
    final selectedMessages = _messages.where((msg) => _selectedIds.contains(msg.id)).toList();
    if (selectedMessages.isEmpty) return;

    String content = '';
    for (var message in selectedMessages) {
      content += message.content;
      if (message.description != null && message.description!.isNotEmpty) {
        content += '\n${message.description}';
      }
      content += '\n\n';
    }

    // Show confirmation dialog before posting to Twitter
    bool? confirmUpload = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Upload to Twitter'),
          content: Text(
              'You are about to upload the selected messages as text. No images will be posted. Proceed?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Upload'),
            ),
          ],
        );
      },
    );

    // If confirmed, proceed with upload to Twitter
    if (confirmUpload == true) {
      try {
        // Initialize TwitterService
        final twitterService = TwitterService();

        // Post the tweet using TwitterService (only the text content)
        await twitterService.postTweet(content);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Successfully posted to Twitter')));
      } catch (e) {
        // Handle error posting tweet
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error posting to Twitter')));
      }
    }
  }

  Future<void> _loadMessages() async {
    final messages = await DatabaseHelper().getMessages();
    setState(() {
      _messages = messages.reversed.toList(); // Reverse the list to show latest at the top
    });
  }

  void _searchMessages(String query) async {
    final results = await DatabaseHelper().searchMessages(query);
    setState(() {
      _messages = results.reversed.toList(); // Reverse search results to keep latest on top
    });
  }

  void _deleteSelected() async {
    // Show confirmation dialog
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Messages'),
          content: Text('Are you sure you want to delete all selected messages?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );

    // If confirmed, proceed with deletion
    if (confirmDelete == true) {
      await DatabaseHelper().deleteMultipleMessages(_selectedIds);
      setState(() {
        _selectedIds.clear();
      });
      _loadMessages();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Selected messages deleted')));
    }
  }

  void _deleteMessage(int id) async {
    await DatabaseHelper().deleteMessage(id);
    _loadMessages();
  }

  void _editMessage(Message message) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MessageFormScreen(existingMessage: message),
      ),
    ).then((_) => _loadMessages());
  }

  // void _uploadGroupToWeb() async {
  //   final selectedMessages = _messages.where((msg) => _selectedIds.contains(msg.id)).toList();
  //   if (selectedMessages.isEmpty) return;
  //
  //   String content = '';
  //   for (var message in selectedMessages) {
  //     content += message.content;
  //     if (message.description != null && message.description!.isNotEmpty) {
  //       content += '\n${message.description}';
  //     }
  //     content += '\n\n';
  //   }
  //
  //   final encodedContent = Uri.encodeComponent(content);
  //   final twitterUrl = Uri.parse("https://twitter.com/intent/tweet?text=$encodedContent");
  //
  //   try {
  //     bool launched = await launchUrl(twitterUrl, mode: LaunchMode.externalApplication);
  //     if (!launched) {
  //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not open Twitter URL')));
  //     }
  //   } catch (e) {
  //     print('Error launching URL: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error launching URL')));
  //   }
  // }

  Widget _buildListItem(Message message) {
    final isSelected = _selectedIds.contains(message.id ?? 0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isSelected ? Colors.black.withOpacity(0.5) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => message_detail_screen(message: message),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (message.imagePath != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(message.imagePath!),
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        const SizedBox(height: 12),
                        Text(
                          message.content,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? Colors.black : Colors.black,
                          ),
                        ),
                        if (message.description != null && message.description!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Text(
                              message.description!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        const SizedBox(height: 8),
                        Text(
                          message.createdAt != null
                              ? DateFormat('MMM dd, yyyy – hh:mm a').format(message.createdAt!)
                              : "",
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),

                // Divider
                Divider(
                  color: Colors.grey.shade300,
                  thickness: 1,
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                ),

                // Actions with icons and labels
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildIconTextButton(
                        icon: Icons.share,
                        label: 'Share',
                        onPressed: () async {
                          String content = message.content;
                          if (message.description != null && message.description!.isNotEmpty) {
                            content += '\n\n${message.description}';
                          }
                          List<XFile> imageFiles = [];
                          if (message.imagePath != null) {
                            imageFiles.add(XFile(message.imagePath!));
                          }

                          if (imageFiles.isNotEmpty) {
                            await Share.shareXFiles(imageFiles, text: content);
                          } else {
                            await Share.share(content);
                          }
                        },
                      ),
                      _buildIconTextButton(
                        icon: Icons.edit,
                        label: 'Edit',
                        onPressed: () => _editMessage(message),
                      ),
                      _buildIconTextButton(
                        icon: Icons.delete_forever,
                        label: 'Delete',
                        onPressed: () async {
                          bool? confirmDelete = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Delete Message'),
                                content: Text('Are you sure you want to delete this message?'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    child: Text('Delete'),
                                  ),
                                ],
                              );
                            },
                          );

                          if (confirmDelete == true) {
                            _deleteMessage(message.id!);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Selection check icon
            Positioned(
              top: 8,
              right: 16,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedIds.remove(message.id);
                    } else {
                      _selectedIds.add(message.id!);
                    }
                  });
                },
                child: Icon(
                  isSelected ? Icons.check_circle : Icons.check_circle_outline,
                  color: isSelected ? Colors.black : Colors.grey,
                  size: 28,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconTextButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.black),
      label: Text(label, style: TextStyle(color: Colors.black)),
      style: TextButton.styleFrom(
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Blog", style: TextStyle(fontFamily: 'Poppins')),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => MessageFormScreen()),
              ).then((_) {
                _loadMessages();
              });
            },
            icon: Icon(Icons.add, color: Colors.black),
            label: Text(
              "Add new",
              style: TextStyle(color: Colors.black),
            ),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 8),
            ),
          ),

          // PopupMenuButton for Delete and Upload
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                if (_selectedIds.isNotEmpty) _deleteSelected();
              } else if (value == 'upload') {
                if (_selectedIds.isNotEmpty) _uploadGroupToTwitter();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'delete',
                enabled: _selectedIds.isNotEmpty,
                child: Row(
                  children: [
                    Icon(Icons.delete_forever, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete All'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'upload',
                enabled: _selectedIds.isNotEmpty,
                child: Row(
                  children: [
                    Icon(Icons.cloud_upload, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Upload to Twitter'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: _searchMessages,
              decoration: InputDecoration(
                hintText: 'Search blog messages...',
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),

      body: SafeArea(
        child: ListView.builder(
          physics: BouncingScrollPhysics(),
          itemCount: _messages.length,
          itemBuilder: (context, index) {
            return _buildListItem(_messages[index]);
          },
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(builder: (_) => MessageFormScreen()),
      //     ).then((_) => _loadMessages());
      //   },
      //   child: Icon(Icons.add),
      // ),
    );
  }
}