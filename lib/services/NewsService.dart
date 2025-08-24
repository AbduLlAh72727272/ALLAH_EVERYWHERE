import 'dart:convert';
import 'package:http/http.dart' as http;

class NewsService {
  final String apiKey = 'your_news_api_key'; // Replace with actual News API key
  final String baseUrl = 'https://newsapi.org/v2';

  Future<List<Map<String, dynamic>>> getIslamicNews() async {
    try {
      final url = '$baseUrl/everything?q=Islam OR Islamic OR Muslim&sortBy=publishedAt&apiKey=$apiKey';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<Map<String, dynamic>> articles = [];
        
        for (var article in data['articles'].take(20)) {
          if (article['title'] != null && article['urlToImage'] != null) {
            articles.add({
              'title': article['title'],
              'description': article['description'] ?? '',
              'url': article['url'],
              'urlToImage': article['urlToImage'],
              'publishedAt': article['publishedAt'],
              'source': article['source']['name'],
            });
          }
        }
        return articles;
      }
    } catch (e) {
      print('News API Error: $e');
    }
    
    return _getLocalNews();
  }

  List<Map<String, dynamic>> _getLocalNews() {
    return [
      {
        'title': 'Ramadan Preparation Guidelines for Muslims Worldwide',
        'description': 'Essential tips and guidelines for preparing for the holy month of Ramadan',
        'url': 'https://example.com/ramadan-guidelines',
        'urlToImage': 'https://example.com/ramadan-image.jpg',
        'publishedAt': DateTime.now().subtract(Duration(hours: 2)).toIso8601String(),
        'source': 'Islamic News Network',
      },
      {
        'title': 'New Mosque Opens in Downtown with Modern Islamic Architecture',
        'description': 'The beautiful new mosque features traditional Islamic design with modern amenities',
        'url': 'https://example.com/new-mosque',
        'urlToImage': 'https://example.com/mosque-image.jpg',
        'publishedAt': DateTime.now().subtract(Duration(hours: 5)).toIso8601String(),
        'source': 'Community News',
      },
      {
        'title': 'Islamic Finance Gains Popularity in Global Markets',
        'description': 'Sharia-compliant banking and finance solutions are expanding worldwide',
        'url': 'https://example.com/islamic-finance',
        'urlToImage': 'https://example.com/finance-image.jpg',
        'publishedAt': DateTime.now().subtract(Duration(hours: 8)).toIso8601String(),
        'source': 'Financial Islamic Times',
      },
      {
        'title': 'Hajj 2024: Important Updates for Pilgrims',
        'description': 'Latest information and requirements for Hajj pilgrimage this year',
        'url': 'https://example.com/hajj-updates',
        'urlToImage': 'https://example.com/hajj-image.jpg',
        'publishedAt': DateTime.now().subtract(Duration(hours: 12)).toIso8601String(),
        'source': 'Hajj News Portal',
      },
      {
        'title': 'Muslim Youth Conference Addresses Modern Challenges',
        'description': 'Young Muslims gather to discuss faith, education, and community involvement',
        'url': 'https://example.com/youth-conference',
        'urlToImage': 'https://example.com/youth-image.jpg',
        'publishedAt': DateTime.now().subtract(Duration(days: 1)).toIso8601String(),
        'source': 'Youth Islamic Forum',
      },
    ];
  }

  Future<List<Map<String, dynamic>>> searchNews(String query) async {
    try {
      final url = '$baseUrl/everything?q=$query&sortBy=publishedAt&apiKey=$apiKey';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<Map<String, dynamic>> articles = [];
        
        for (var article in data['articles'].take(10)) {
          if (article['title'] != null) {
            articles.add({
              'title': article['title'],
              'description': article['description'] ?? '',
              'url': article['url'],
              'urlToImage': article['urlToImage'],
              'publishedAt': article['publishedAt'],
              'source': article['source']['name'],
            });
          }
        }
        return articles;
      }
    } catch (e) {
      print('News Search API Error: $e');
    }
    
    return [];
  }
}
