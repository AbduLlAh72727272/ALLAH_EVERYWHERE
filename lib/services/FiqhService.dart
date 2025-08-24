import 'dart:convert';
import 'package:http/http.dart' as http;

class FiqhService {
  Future<List<Map<String, dynamic>>> getFiqhCategories() async {
    // Placeholder for future Fiqh API integration
    // Fallback to local if API not available
    return [{
      'id': 1,
      'title': 'Taharah (Purification)',
      'description': 'Rules of cleanliness and purification in Islam',
      'icon': '🚿',
      'color': '0xFF4CAF50',
      'topics': [
        'Wudu (Ablution)',
        'Ghusl (Full Bath)',
        'Tayammum (Dry Ablution)',
        'Cleaning Impurities',
        'Menstruation Rules'
      ]
    },{
      'id': 2,
      'title': 'Salah (Prayer)',
      'description': 'Laws and regulations regarding Islamic prayers',
      'icon': '🕌',
      'color': '0xFF2196F3',
      'topics': [
        'Five Daily Prayers',
        'Prayer Conditions',
        'Prayer in Travel',
        'Friday Prayer',
        'Eid Prayers'
      ]
    },{
      'id': 3,
      'title': 'Zakah (Charity)',
      'description': 'Islamic laws on obligatory charity and wealth purification',
      'icon': '💰',
      'color': '0xFFFF9800',
      'topics': [
        'Zakah Calculation',
        'Nisab Amounts',
        'Zakah Recipients',
        'Zakah on Gold/Silver',
        'Business Zakah'
      ]
    },{
      'id': 4,
      'title': 'Sawm (Fasting)',
      'description': 'Rules and regulations of Islamic fasting',
      'icon': '🌙',
      'color': '0xFF9C27B0',
      'topics': [
        'Ramadan Fasting',
        'Breaking Fast Rules',
        'Voluntary Fasting',
        'Fidyah and Kaffara',
        'Medical Exceptions'
      ]
    },{
      'id': 5,
      'title': 'Hajj (Pilgrimage)',
      'description': 'Laws and rituals of Islamic pilgrimage',
      'icon': '🕋',
      'color': '0xFF795548',
      'topics': [
        'Hajj Requirements',
        'Hajj Rituals',
        'Umrah Rules',
        'Ihram Conditions',
        'Hajj Duas'
      ]
    },{
      'id': 6,
      'title': 'Marriage & Family',
      'description': 'Islamic laws regarding marriage and family life',
      'icon': '💑',
      'color': '0xFFE91E63',
      'topics': [
        'Marriage Requirements',
        'Nikah Ceremony',
        'Divorce Rules',
        'Child Custody',
        'Inheritance Laws'
      ]
    },{
      'id': 7,
      'title': 'Business & Trade',
      'description': 'Islamic commercial law and business ethics',
      'icon': '🏪',
      'color': '0xFF607D8B',
      'topics': [
        'Halal Business',
        'Interest (Riba)',
        'Partnership Rules',
        'Contract Laws',
        'Islamic Banking'
      ]
    },{
      'id': 8,
      'title': 'Food & Drink',
      'description': 'Islamic dietary laws and regulations',
      'icon': '🍖',
      'color': '0xFF8BC34A',
      'topics': [
        'Halal Food',
        'Haram Substances',
        'Slaughter Rules',
        'Food Preparation',
        'Eating Etiquette'
      ]
    }];
  }

  Future<List<Map<String, dynamic>>> getFiqhTopics(int categoryId) async {
    final categories = await getFiqhCategories();
    final category = categories.firstWhere((cat) => cat['id'] == categoryId);
    
    List<String> topics = List<String>.from(category['topics']);
    
    return topics.map((topic) => {
      'title': topic,
      'description': 'Detailed explanation of $topic according to Islamic law',
      'categoryId': categoryId,
    }).toList();
  }

  Future<Map<String, dynamic>> getFiqhDetail(int categoryId, String topic) async {
    // This would typically fetch from an API or database
    // For now, returning sample detailed content
    return {
      'title': topic,
      'content': _getDetailedContent(topic),
      'references': [
        'Quran',
        'Sahih Bukhari',
        'Sahih Muslim',
        'Sunan Abu Dawood'
      ],
      'scholars': [
        'Imam Abu Hanifa',
        'Imam Malik',
        'Imam Shafi\'i',
        'Imam Ahmad'
      ]
    };
  }

  String _getDetailedContent(String topic) {
    switch (topic.toLowerCase()) {
      case 'wudu (ablution)':
        return '''
Wudu (ablution) is the Islamic procedure for cleansing parts of the body, a type of ritual purification, or preparation for formal prayers.

Prerequisites for Wudu:
1. Mental intention (Niyyah)
2. Using clean water
3. Ensuring no barriers prevent water from reaching the skin

Steps of Wudu:
1. Begin with Bismillah
2. Wash hands three times
3. Rinse mouth three times
4. Clean nostrils three times
5. Wash face three times
6. Wash arms up to elbows three times
7. Wipe head once
8. Wipe ears once
9. Wash feet up to ankles three times

Things that break Wudu:
- Using the toilet
- Passing gas
- Deep sleep
- Unconsciousness
- Touching private parts directly
        ''';
      
      case 'zakah calculation':
        return '''
Zakah is one of the Five Pillars of Islam and is obligatory charity for eligible Muslims.

Zakah Rate: 2.5% of qualifying wealth annually

Nisab (Minimum threshold):
- Gold: 85 grams
- Silver: 595 grams
- Cash equivalent to gold/silver value

Zakah on Different Assets:
1. Cash and Bank Savings: 2.5%
2. Gold and Silver: 2.5%
3. Business Inventory: 2.5%
4. Agricultural Produce: 5-10%
5. Livestock: Varies by type and number

Zakah Recipients (8 categories):
1. The poor (Fuqara)
2. The needy (Masakin)
3. Zakah administrators
4. Those whose hearts are reconciled
5. Slaves seeking freedom
6. Those in debt
7. In the path of Allah
8. Travelers in need
        ''';
      
      default:
        return '''
This is a comprehensive guide to $topic according to Islamic jurisprudence.

The ruling on this matter has been derived from the Quran, Sunnah, and the consensus of Islamic scholars throughout history.

Key Points:
- The basic principles and foundations
- Conditions and requirements
- Exceptions and special cases
- Practical applications in daily life

For more detailed information, please consult with qualified Islamic scholars or refer to authentic Islamic jurisprudence books.
        ''';
    }
  }

  Future<List<Map<String, dynamic>>> searchFiqh(String query) async {
    final categories = await getFiqhCategories();
    List<Map<String, dynamic>> results = [];
    
    for (var category in categories) {
      if (category['title'].toLowerCase().contains(query.toLowerCase()) ||
          category['description'].toLowerCase().contains(query.toLowerCase())) {
        results.add(category);
      }
      
      // Search in topics
      List<String> topics = List<String>.from(category['topics']);
      for (var topic in topics) {
        if (topic.toLowerCase().contains(query.toLowerCase())) {
          results.add({
            'title': topic,
            'description': 'From ${category['title']}',
            'categoryId': category['id'],
            'type': 'topic'
          });
        }
      }
    }
    
    return results;
  }
}
