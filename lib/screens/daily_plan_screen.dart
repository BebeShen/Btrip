import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DailyPlanScreen extends StatefulWidget {
  const DailyPlanScreen({super.key});

  @override
  State<DailyPlanScreen> createState() => _DailyPlanScreenState();
}

class _DailyPlanScreenState extends State<DailyPlanScreen> {
  final List<PlanItem> _plans = [];
  final DateFormat formatter = DateFormat('yyyy/MM/dd HH:mm');

  void _addPlan(PlanItem plan) {
    setState(() {
      _plans.add(plan);
    });
  }

  void _updatePlan(int index, PlanItem newPlan) {
    setState(() {
      _plans[index] = newPlan;
    });
  }

  void _deletePlan(int index) {
    setState(() {
      _plans.removeAt(index);
    });
  }

  void _showPlanSheet({PlanItem? plan, int? index}) {
    String title = plan?.title ?? '';
    String description = plan?.description ?? '';
    String location = plan?.location ?? '';
    DateTime? selectedDateTime;

    if (plan != null && plan.time.isNotEmpty) {
      selectedDateTime = DateTime.tryParse(plan.time);
    }

    final titleController = TextEditingController(text: title);
    final descriptionController = TextEditingController(text: description);
    final locationController = TextEditingController(text: location);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setModalState) {
          Future<void> pickDateTime() async {
            final now = DateTime.now();
            final date = await showDatePicker(
              context: ctx,
              initialDate: selectedDateTime ?? now,
              firstDate: DateTime(now.year - 1),
              lastDate: DateTime(now.year + 2),
            );

            if (date != null) {
              final time = await showTimePicker(
                context: ctx,
                initialTime: selectedDateTime != null
                    ? TimeOfDay(hour: selectedDateTime!.hour, minute: selectedDateTime!.minute)
                    : TimeOfDay.now(),
              );

              if (time != null) {
                setModalState(() {
                  selectedDateTime =
                      DateTime(date.year, date.month, date.day, time.hour, time.minute);
                });
              }
            }
          }
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.6,
            minChildSize: 0.4,
            maxChildSize: 0.9,
            builder: (_, controller) {
              return Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: MediaQuery.of(ctx).viewInsets.bottom,
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        controller: controller,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextField(
                              decoration: const InputDecoration(labelText: '標題'),
                              controller: titleController,
                              onChanged: (value) => title = value,
                            ),
                            const SizedBox(height: 16),

                            TextField(
                              decoration: const InputDecoration(labelText: '描述'),
                              controller: descriptionController,
                              maxLines: null,
                              onChanged: (value) => description = value,
                            ),
                            const SizedBox(height: 16),

                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 50),
                              ),
                              onPressed: pickDateTime,
                              child: Text(
                                selectedDateTime == null
                                    ? '選擇日期時間'
                                    : DateFormat('yyyy/MM/dd HH:mm').format(selectedDateTime!),
                              ),
                            ),
                            const SizedBox(height: 16),

                            TextField(
                              decoration: const InputDecoration(labelText: '地點'),
                              controller: locationController,
                              onChanged: (value) => location = value,
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),

                    SafeArea(
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          onPressed: () {
                            if (title.isNotEmpty && selectedDateTime != null) {
                              final newPlan = PlanItem(
                                title: title,
                                description: description,
                                time: selectedDateTime!.toIso8601String(),
                                location: location,
                              );
                              if (plan == null) {
                                _addPlan(newPlan);
                              } else {
                                _updatePlan(index!, newPlan);
                              }
                              Navigator.of(ctx).pop();
                            }
                          },
                          child: Text(plan == null ? '新增行程' : '更新行程'),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );

        });
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
                final displayTime = DateTime.tryParse(plan.time);
                final formattedTime = displayTime != null ? formatter.format(displayTime) : '';
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    title: Text(plan.title),
                    subtitle: Text(
                        '${plan.description}\n時間: $formattedTime\n地點: ${plan.location}'),
                    isThreeLine: true,
                    onTap: () => _showPlanSheet(plan: plan, index: index),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deletePlan(index),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPlanSheet(),
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

  PlanItem({
    required this.title,
    required this.description,
    required this.time,
    required this.location,
  });
}
