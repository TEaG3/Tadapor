import 'package:flutter/material.dart';
import 'package:tadapor/core/theme/app_theme.dart';
import 'package:tadapor/data/models/athkar_model.dart';
import 'package:tadapor/data/sources/athkar_data.dart';

class AthkarScreen extends StatelessWidget {
  const AthkarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الأذكار'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: athkarCategories.length,
        itemBuilder: (context, index) {
          final category = athkarCategories[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: AppTheme.primaryGreen.withOpacity(0.15),
                child: Text(category.icon, style: const TextStyle(fontSize: 22)),
              ),
              title: Text(
                category.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              subtitle: Text('${category.items.length} ذكر'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AthkarDetailScreen(category: category),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class AthkarDetailScreen extends StatefulWidget {
  final AthkarCategory category;

  const AthkarDetailScreen({super.key, required this.category});

  @override
  State<AthkarDetailScreen> createState() => _AthkarDetailScreenState();
}

class _AthkarDetailScreenState extends State<AthkarDetailScreen> {
  final Map<String, int> _counters = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: widget.category.items.length,
        itemBuilder: (context, index) {
          final item = widget.category.items[index];
          final currentCount = _counters[item.id] ?? 0;

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    item.text,
                    style: const TextStyle(
                      fontSize: 20,
                      height: 1.8,
                      fontFamily: 'Amiri',
                    ),
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 12),
                  if (item.benefit != null) ...[
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryGold.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'فضل: ${item.benefit}',
                        style: const TextStyle(fontSize: 13, color: Colors.black87),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'المصدر: ${item.source}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      Text(
                        'التكرار: ${item.count}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // عداد
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _counters[item.id] = 0;
                          });
                        },
                        icon: const Icon(Icons.refresh),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          if (currentCount < item.count) {
                            setState(() {
                              _counters[item.id] = currentCount + 1;
                            });
                          }
                        },
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: currentCount >= item.count
                                ? AppTheme.primaryGreen
                                : AppTheme.primaryGreen.withOpacity(0.15),
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.primaryGreen, width: 2),
                          ),
                          child: Center(
                            child: Text(
                              '$currentCount',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: currentCount >= item.count ? Colors.white : AppTheme.primaryGreen,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text('/ ${item.count}'),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
