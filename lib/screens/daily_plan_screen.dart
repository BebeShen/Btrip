import 'package:flutter/material.dart';

class DailyPlanScreen extends StatefulWidget {
  const DailyPlanScreen({super.key});

  @override
  State<DailyPlanScreen> createState() => _DailyPlanScreenState();
}

class _DailyPlanScreenState extends State<DailyPlanScreen> {
  final List<PlanItem> _plans = [];

  void _addPlan(String title, String description, String time, String location) {
    setState(() {
      _plans.add(PlanItem(
        title: title,
        description: description,
        time: time,
        location: location,
      ));
    });
  }

  void _deletePlan(int index) {
    setState(() {
      _plans.removeAt(index);
    });
  }

  void _showAddPlanSheet() {
    String title = '';
    String description = '';
    String time = '';
    String location = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 當輸入鍵盤出現時可滾動
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20),
          child: Wrap(
            children: [
              TextField(
                decoration: const InputDecoration(labelText: '標題'),
                onChanged: (value) => title = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: '描述'),
                onChanged: (value) => description = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: '時間'),
                onChanged: (value) => time = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: '地點'),
                onChanged: (value) => location = value,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (title.isNotEmpty) {
                    _addPlan(title, description, time, location);
                    Navigator.of(ctx).pop();
                  }
                },
                child: const Text('新增行程'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('每日行程')),
      body: _plans.isEmpty
          ? const Center(child: Text('尚無行程，請點右下新增'))
          : ListView.builder(
              itemCount: _plans.length,
              itemBuilder: (ctx, index) {
                final plan = _plans[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    title: Text(plan.title),
                    subtitle: Text(
                        '${plan.description}\n時間: ${plan.time}\n地點: ${plan.location}'),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deletePlan(index),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPlanSheet,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class PlanItem {
  final String title;
  final String description;
  final String time;
  final String location;
  final String? comment; // 先預留 comment
  final int? rating;     // 先預留 rating

  PlanItem({
    required this.title,
    required this.description,
    required this.time,
    required this.location,
    this.comment,
    this.rating,
  });
}
