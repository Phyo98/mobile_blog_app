import 'dart:async';
import 'dart:io';
import 'package:twitter_api_v2/twitter_api_v2.dart' as v2;

class TwitterService {
  final v2.TwitterApi _twitterApi;

  // Use OAuth 1.0a tokens
  TwitterService()
      : _twitterApi = v2.TwitterApi(
    oauthTokens: v2.OAuthTokens(
      consumerKey: 'YkgCDefw2aT1u1b33pPmyCOAl',
      consumerSecret: 'Y5jN3r33SKfJjdg3sp5itQe86rCTJhlpXpUBljLQTKZObI2XtR',
      accessToken: '1912422146326040576-B1J4XMcuwj9hoJ9XKq4Pcr3nj0uYgG',
      accessTokenSecret: '0slpjjzFFilFe8etQ5G0lUsrzI9hMSvTBfbwJWlFSGNE2',
    ),
    timeout: Duration(seconds: 30), bearerToken: '', // Optional timeout for API requests
  );

  Future<void> postTweetWithTextAndMedia(String text, String imagePath) async {
    try {
      if (imagePath.isNotEmpty) {
        // Upload media if image path is provided
        final uploadedMedia = await _twitterApi.media.uploadMedia(
          file: File(imagePath),
          altText: 'Image uploaded with tweet',
        );

        // Post the tweet with both text and media
        await _twitterApi.tweets.createTweet(
          text: text,
          media: v2.TweetMediaParam(
            mediaIds: [uploadedMedia.data.id],  // Attach the uploaded image
          ),
        );
      } else {
        // If no image, just post the text
        await _twitterApi.tweets.createTweet(text: text);
      }

      print('Tweet posted successfully: $text');
    } catch (e) {
      print('Error posting tweet: $e');
    }
  }
}







// import 'dart:async';
// import 'dart:io';
//
// import 'package:twitter_api_v2/twitter_api_v2.dart' as v2;
//
// Future<void> postTweetWithTextAndImage(String text, String imagePath) async {
//   // Set up Twitter API client
//   final twitter = v2.TwitterApi(
//     bearerToken: 'AAAAAAAAAAAAAAAAAAAAALfQ0gEAAAAA%2FQ61OI9gUnmiXB%2Fs0fMIctQJcYg%3Dxa5e71AwyWvn8wUT7a4x4EMwNxR4vxvKCnbssow2mOTARTfU6O',
//     oauthTokens: v2.OAuthTokens(
//       consumerKey: 'YkgCDefw2aT1u1b33pPmyCOAl',
//       consumerSecret: 'Y5jN3r33SKfJjdg3sp5itQe86rCTJhlpXpUBljLQTKZObI2XtR',
//       accessToken: '1912422146326040576-B1J4XMcuwj9hoJ9XKq4Pcr3nj0uYgG',
//       accessTokenSecret: '0slpjjzFFilFe8etQ5G0lUsrzI9hMSvTBfbwJWlFSGNE2',
//     ),
//   );
//
//   try {
//     // Upload the image
//     final uploadedMedia = await twitter.media.uploadMedia(
//       file: File.fromUri(Uri.file(imagePath)),
//       altText: 'This is an image uploaded with my tweet',
//       onProgress: (event) {
//         print('Upload progress: ${event.progress}%');
//       },
//       onFailed: (error) {
//         print('Upload failed: ${error.message}');
//       },
//     );
//
//     // Create a tweet with text and image
//     final tweet = await twitter.tweets.createTweet(
//       text: text,  // The text content for the tweet
//       media: v2.TweetMediaParam(
//         mediaIds: [uploadedMedia.data.id],  // Attach the uploaded image
//       ),
//     );
//
//     print('Tweet posted successfully: ${tweet.data.text}');
//   } catch (e) {
//     print('Error posting tweet: $e');
//   }
// }

// class TwitterService {
//   final TwitterApi _twitterApi;
//
//   TwitterService()
//       : _twitterApi = TwitterApi(
//     bearerToken:'AAAAAAAAAAAAAAAAAAAAALfQ0gEAAAAA%2FQ61OI9gUnmiXB%2Fs0fMIctQJcYg%3Dxa5e71AwyWvn8wUT7a4x4EMwNxR4vxvKCnbssow2mOTARTfU6O',
//     oauthTokens: OAuthTokens(
//       consumerKey: 'YkgCDefw2aT1u1b33pPmyCOAl',
//       consumerSecret: 'Y5jN3r33SKfJjdg3sp5itQe86rCTJhlpXpUBljLQTKZObI2XtR',
//       accessToken: '1912422146326040576-B1J4XMcuwj9hoJ9XKq4Pcr3nj0uYgG',
//       accessTokenSecret: '0slpjjzFFilFe8etQ5G0lUsrzI9hMSvTBfbwJWlFSGNE2',
//     ),
//   );

  // Future<void> postTweet(String content) async {
  //   try {
  //     final tweet = await _twitterApi.tweetsService.createTweet(text: content);
  //     print('✅ Tweet posted: ${tweet.data.text}');
  //   } catch (e) {
  //     print('❌ Failed to post tweet: $e');
  //     throw Exception('Error posting tweet: $e');
  //   }
  // }


