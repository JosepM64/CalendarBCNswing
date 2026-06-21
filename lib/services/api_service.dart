import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/event.dart';

class EventsApiService {
  static const String _baseUrl = 'https://www.bcnswing.org/wp-json/tribe/events/v1';

  // Categories excloses (classe oberta)
  static const List<String> _excludedCategories = ['classe-oberta'];

  Future<List<Event>> getEvents({
    String? startDate,
    String? endDate,
    String? category,
    String? search,
    int page = 1,
    int perPage = 20,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'per_page': perPage.toString(),
      'status': 'publish',
    };

    if (startDate != null) params['start_date'] = startDate;
    if (endDate != null) params['end_date'] = endDate;
    if (category != null && category.isNotEmpty) {
      params['categories'] = category;
    }
    if (search != null && search.isNotEmpty) params['search'] = search;

    final uri = Uri.parse('$_baseUrl/events').replace(queryParameters: params);

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final events = (data['events'] as List)
            .map((e) => Event.fromJson(e))
            .where((e) => !_isExcludedCategory(e))
            .toList();
        return events;
      } else {
        throw Exception('Error carregant esdeveniments: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de connexió: $e');
    }
  }

  Future<List<EventCategory>> getCategories() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/categories'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['categories'] as List)
            .map((c) => EventCategory.fromJson(c))
            .where((c) => !_excludedCategories.contains(c.slug))
            .toList();
      } else {
        throw Exception('Error carregant categories');
      }
    } catch (e) {
      throw Exception('Error de connexió: $e');
    }
  }

  bool _isExcludedCategory(Event event) {
    return event.categories.any(
        (c) => _excludedCategories.contains(c.slug));
  }
}
