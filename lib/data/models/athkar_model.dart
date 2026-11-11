class AthkarItem {
  final String id;
  final String text;
  final String? translation;
  final String source; // المصدر السني
  final String category;
  final int count; // عدد التكرار
  final String? benefit;

  const AthkarItem({
    required this.id,
    required this.text,
    this.translation,
    required this.source,
    required this.category,
    this.count = 1,
    this.benefit,
  });
}

class AthkarCategory {
  final String id;
  final String name;
  final String icon;
  final List<AthkarItem> items;

  const AthkarCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.items,
  });
}
