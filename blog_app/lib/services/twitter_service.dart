import 'package:twitter_api_v2/twitter_api_v2.dart';

class TwitterService {
  final TwitterApi _twitterApi;

  TwitterService()
      : _twitterApi = TwitterApi(
    bearerToken:'AAAAAAAAAAAAAAAAAAAAALfQ0gEAAAAA%2FQ61OI9gUnmiXB%2Fs0fMIctQJcYg%3Dxa5e71AwyWvn8wUT7a4x4EMwNxR4vxvKCnbssow2mOTARTfU6O',
    oauthTokens: OAuthTokens(
      consumerKey: 'YkgCDefw2aT1u1b33pPmyCOAl',
      consumerSecret: 'Y5jN3r33SKfJjdg3sp5itQe86rCTJhlpXpUBljLQTKZObI2XtR',
      accessToken: '1912422146326040576-B1J4XMcuwj9hoJ9XKq4Pcr3nj0uYgG',
      accessTokenSecret: '0slpjjzFFilFe8etQ5G0lUsrzI9hMSvTBfbwJWlFSGNE2',
    ),
  );

  Future<void> postTweet(String content) async {
    try {
      final tweet = await _twitterApi.tweetsService.createTweet(text: content);
      print('✅ Tweet posted: ${tweet.data.text}');
    } catch (e) {
      print('❌ Failed to post tweet: $e');
      throw Exception('Error posting tweet: $e');
    }
  }
}
