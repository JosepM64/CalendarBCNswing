class Event {
  final int id;
  final String title;
  final String description;
  final String url;
  final DateTime startDate;
  final DateTime endDate;
  final String? imageUrl;
  final String? venueName;
  final String? venueAddress;
  final String? venueCity;
  final double? venueLat;
  final double? venueLng;
  final List<EventCategory> categories;
  final String cost;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.url,
    required this.startDate,
    required this.endDate,
    this.imageUrl,
    this.venueName,
    this.venueAddress,
    this.venueCity,
    this.venueLat,
    this.venueLng,
    this.categories = const [],
    this.cost = '',
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    final venue = json['venue'];
    final image = json['image'];
    final categories = (json['categories'] as List?)
            ?.map((c) => EventCategory.fromJson(c))
            .toList() ??
        [];

    return Event(
      id: json['id'] ?? 0,
      title: _cleanHtml(json['title'] ?? ''),
      description: json['description'] ?? '',
      url: json['url'] ?? '',
      startDate: DateTime.parse(json['start_date'] ?? json['date'] ?? ''),
      endDate: DateTime.parse(
          json['end_date'] ?? json['date'] ?? DateTime.now().toString()),
      imageUrl: image?['sizes']?['large']?['url'] ?? image?['url'],
      venueName: venue?['venue'],
      venueAddress: venue?['address'],
      venueCity: venue?['city'],
      venueLat: venue?['lat'] != null
          ? double.tryParse(venue['lat'].toString())
          : null,
      venueLng: venue?['lng'] != null
          ? double.tryParse(venue['lng'].toString())
          : null,
      categories: categories,
      cost: json['cost'] ?? '',
    );
  }

  static String _cleanHtml(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&#8211;', '–')
        .replaceAll('&#8217;', "'")
        .replaceAll('&#8220;', '"')
        .replaceAll('&#8221;', '"')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&#038;', '&')
        .replaceAll('\n', ' ')
        .trim();
  }

  String get shortDescription {
    final cleaned = _cleanHtml(description);
    return cleaned.length > 150 ? '${cleaned.substring(0, 150)}...' : cleaned;
  }

  String get categoryNames => categories.map((c) => c.name).join(', ');

  bool get isUpcoming => startDate.isAfter(DateTime.now());
}

class EventCategory {
  final int id;
  final String name;
  final String slug;

  EventCategory({
    required this.id,
    required this.name,
    required this.slug,
  });

  factory EventCategory.fromJson(Map<String, dynamic> json) {
    return EventCategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
    );
  }
}
