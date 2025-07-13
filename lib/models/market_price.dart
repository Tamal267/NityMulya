// Data model for market price entries
class MarketPrice {
  final String serial;
  final String title;
  final String time;
  final String date;

  MarketPrice({
    required this.serial,
    required this.title,
    required this.time,
    required this.date,
  });

  // Convert from Map (useful for JSON parsing)
  factory MarketPrice.fromMap(Map<String, dynamic> map) {
    return MarketPrice(
      serial: map['serial'] ?? '',
      title: map['title'] ?? '',
      time: map['time'] ?? '',
      date: map['date'] ?? '',
    );
  }

  // Convert to Map (useful for JSON serialization)
  Map<String, dynamic> toMap() {
    return {
      'serial': serial,
      'title': title,
      'time': time,
      'date': date,
    };
  }
}
