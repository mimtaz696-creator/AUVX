
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuvxStore.init();
  runApp(const AuvxApp());
}

const navy = Color(0xFF070B24);
const cyan = Color(0xFF18C8F4);
const purple = Color(0xFF8657FF);

class AuvxStore {
  static late SharedPreferences prefs;
  static Map<String, dynamic> data = {
    'tasks': [],
    'habits': [],
    'notes': [],
    'expenses': [],
  };

  static Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('auvx_data');
    if (saved != null) {
      data = Map<String, dynamic>.from(jsonDecode(saved));
    }
  }

  static Future<void> save() async {
    await prefs.setString('auvx_data', jsonEncode(data));
  }
}

class AuvxApp extends StatelessWidget {
  const AuvxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AUVX',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: navy,
        colorScheme: ColorScheme.fromSeed(
          seedColor: cyan,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const AuvxHome(),
    );
  }
}

class AuvxHome extends StatefulWidget {
  const AuvxHome({super.key});

  @override
  State<AuvxHome> createState() => _AuvxHomeState();
}

class _AuvxHomeState extends State<AuvxHome> {
  int selected = 0;

  final titles = [
    'Home',
    'Tasks',
    'Habits',
    'Notes',
    'Money',
  ];

  @override
  Widget build(BuildContext context) {
    final pages = [
      const Dashboard(),
      const TasksPage(),
      const HabitsPage(),
      const NotesPage(),
      const MoneyPage(),
    ];

    return Scaffold(
      body: SafeArea(
        child: pages[selected],
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF111936),
        indicatorColor: cyan.withOpacity(.2),
        selectedIndex: selected,
        onDestinationSelected: (i) {
          setState(() => selected = i);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.checklist),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.track_changes),
            label: 'Habits',
          ),
          NavigationDestination(
            icon: Icon(Icons.notes),
            label: 'Notes',
          ),
          NavigationDestination(
            icon: Icon(Icons.wallet),
            label: 'Money',
          ),
        ],
      ),
    );
  }
}
class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final tasks = AuvxStore.data['tasks'] as List;
    final habits = AuvxStore.data['habits'] as List;
    final notes = AuvxStore.data['notes'] as List;
    final expenses = AuvxStore.data['expenses'] as List;

    final completed =
        tasks.where((t) => t['done'] == true).length;

    final totalMoney = expenses.fold<double>(
      0,
      (sum, e) => sum + (e['amount'] as num).toDouble(),
    );

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const SizedBox(height: 15),
        const Text(
          'AUVX',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
          ),
        ),
        const Text(
          'Elevate Your Everyday.',
          style: TextStyle(color: cyan),
        ),
        const SizedBox(height: 25),

        glassBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your day, your control.',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Make every day more productive.',
                style: TextStyle(color: Colors.white60),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: statBox(
                      'Tasks Done',
                      '$completed/${tasks.length}',
                      Icons.task_alt,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: statBox(
                      'Habits',
                      '${habits.length}',
                      Icons.bolt,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 25),
        const Text(
          'Your Overview',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: statBox(
                'Notes',
                '${notes.length}',
                Icons.notes,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: statBox(
                'Expenses',
                '৳${totalMoney.toStringAsFixed(0)}',
                Icons.wallet,
              ),
            ),
          ],
        ),

        const SizedBox(height: 25),
        const Text(
          'Designed for your everyday life.',
          style: TextStyle(
            color: Colors.white54,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

Widget glassBox({required Widget child}) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [
          Color(0xFF202D55),
          Color(0xFF111936),
        ],
      ),
      borderRadius: BorderRadius.circular(25),
      border: Border.all(
        color: cyan.withOpacity(.25),
      ),
      boxShadow: [
        BoxShadow(
          color: purple.withOpacity(.10),
          blurRadius: 20,
        ),
      ],
    ),
    child: child,
  );
}

Widget statBox(
  String title,
  String value,
  IconData icon,
) {
  return glassBox(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: cyan, size: 25),
        const SizedBox(height: 12),
        Text(
          value,
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 12,
          ),
        ),
      ],
    ),
    Future<void> addItem(
  BuildContext context,
  String type,
) async {
  final title = TextEditingController();
  final amount = TextEditingController();

  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF111936),
      title: Text('Add $type'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: title,
            decoration: const InputDecoration(
              hintText: 'Enter name or title',
            ),
          ),
          if (type == 'expense') ...[
            const SizedBox(height: 12),
            TextField(
              controller: amount,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Amount in Taka',
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Save'),
        ),
      ],
    ),
  );

  if (result == true && title.text.trim().isNotEmpty) {
    if (type == 'expense' &&
        (double.tryParse(amount.text) ?? 0) <= 0) {
      return;
    }

    final key = type == 'task'
        ? 'tasks'
        : type == 'habit'
            ? 'habits'
            : type == 'note'
                ? 'notes'
                : 'expenses';

    final item = <String, dynamic>{
      'title': title.text.trim(),
      'done': false,
    };

    if (type == 'expense') {
      item['amount'] = double.parse(amount.text);
    }

    if (type == 'note') {
      item['body'] = '';
    }

    (AuvxStore.data[key] as List).insert(0, item);
    await AuvxStore.save();
  }

  title.dispose();
  amount.dispose();
}

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  @override
  Widget build(BuildContext context) {
    final items = AuvxStore.data['tasks'] as List;

    return pageLayout(
      context,
      'My Tasks',
      'Manage your daily work.',
      'task',
      items,
      'tasks',
      setState,
    );
  }
}

class HabitsPage extends StatefulWidget {
  const HabitsPage({super.key});

  @override
  State<HabitsPage> createState() => _HabitsPageState();
}

class _HabitsPageState extends State<HabitsPage> {
  @override
  Widget build(BuildContext context) {
    final items = AuvxStore.data['habits'] as List;

    return pageLayout(
      context,
      'My Habits',
      'Build better daily habits.',
      'habit',
      items,
      'habits',
      setState,
    );
  }
}

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  @override
  Widget build(BuildContext context) {
    final items = AuvxStore.data['notes'] as List;

    return pageLayout(
      context,
      'My Notes',
      'Save your important thoughts.',
      'note',
      items,
      'notes',
      setState,
    );
  }
}

class MoneyPage extends StatefulWidget {
  const MoneyPage({super.key});

  @override
  State<MoneyPage> createState() => _MoneyPageState();
}

class _MoneyPageState extends State<MoneyPage> {
  @override
  Widget build(BuildContext context) {
    final items = AuvxStore.data['expenses'] as List;

    return pageLayout(
      context,
      'Money Manager',
      'Track your expenses.',
      'expense',
      items,
      'expenses',
      setState,
    );
  }
}

Widget pageLayout(
  BuildContext context,
  String title,
  String subtitle,
  String type,
  List items,
  String key,
  StateSetter refresh,
) {
  return StatefulBuilder(
    builder: (context, localSetState) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 25, 20, 15),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.white60,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton.filled(
                  onPressed: () async {
                    await addItem(context, type);
                    localSetState(() {});
                    refresh(() {});
                  },
                  icon: const Icon(Icons.add),
                  style: IconButton.styleFrom(
                    backgroundColor: cyan,
                    foregroundColor: navy,
                  ),
                ),
              ],
            ),
          ),

          if (type == 'expense')
            Padding(
              padding: const EdgeInsets.all(15),
              child: Builder(
                builder: (context) {
                  final total = items.fold<double>(
                    0,
                    (sum, item) =>
                        sum +
                        ((item['amount'] as num?)?.toDouble() ?? 0),
                  );

                  return glassBox(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Expenses',
                          style: TextStyle(color: Colors.white60),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '৳${total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 27,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

          Expanded(
            child: items.isEmpty
                ? const Center(
                    child: Text(
                      'Nothing here yet.\nTap + to add something.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white54),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: glassBox(
                          child: Row(
                            children: [
                              if (type == 'task' ||
                                  type == 'habit')
                                Checkbox(
                                  value: item['done'] == true,
                                  activeColor: cyan,
                                  onChanged: (value) async {
                                    item['done'] = value == true;
                                    await AuvxStore.save();
                                    localSetState(() {});
                                    refresh(() {});
                                  },
                                ),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${item['title']}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        decoration:
                                            item['done'] == true
                                                ? TextDecoration.lineThrough
                                                : null,
                                      ),
                                    ),

                                    if (type == 'expense')
                                      Text(
                                        '৳${item['amount']}',
                                        style: const TextStyle(
                                          color: cyan,
                                        ),
                                      ),

                                    if (type == 'note' &&
                                        '${item['body']}'.isNotEmpty)
                                      Text('${item['body']}'),
                                  ],
                                ),
                              ),

                              IconButton(
                                onPressed: () async {
                                  items.removeAt(index);
                                  await AuvxStore.save();
                                  localSetState(() {});
                                  refresh(() {});
                                },
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.white54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      );
    },
  );
}
  );
}
Future<void> addItem(BuildContext context, String type) async {
  final controller = TextEditingController();
  final amountController = TextEditingController();

  String title = '';
  String amount = '';

  await showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: const Color(0xFF17213B),
      title: Text(
        'Add ${type[0].toUpperCase()}${type.substring(1)}',
        style: const TextStyle(color: Colors.white),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Enter name or title',
            ),
          ),
          if (type == 'expenses')
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Enter amount',
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            title = controller.text.trim();
            amount = amountController.text.trim();

            if (title.isEmpty) return;

            await AuvxStore.addRecord(type, {
              'title': title,
              'amount': amount,
              'done': false,
              'createdAt': DateTime.now().toIso8601String(),
            });

            if (dialogContext.mounted) {
              Navigator.pop(dialogContext);
            }
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  @override
  Widget build(BuildContext context) {
    return pageLayout(
      context,
      'My Tasks',
      'Manage your daily tasks',
      'tasks',
      Icons.task_alt,
      () => setState(() {}),
    );
  }
}

class HabitsPage extends StatefulWidget {
  const HabitsPage({super.key});

  @override
  State<HabitsPage> createState() => _HabitsPageState();
}

class _HabitsPageState extends State<HabitsPage> {
  @override
  Widget build(BuildContext context) {
    return pageLayout(
      context,
      'My Habits',
      'Build better everyday habits',
      'habits',
      Icons.repeat,
      () => setState(() {}),
    );
  }
}

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  @override
  Widget build(BuildContext context) {
    return pageLayout(
      context,
      'My Notes',
      'Keep your important ideas',
      'notes',
      Icons.edit_note,
      () => setState(() {}),
    );
  }
}

class MoneyPage extends StatefulWidget {
  const MoneyPage({super.key});

  @override
  State<MoneyPage> createState() => _MoneyPageState();
}

class _MoneyPageState extends State<MoneyPage> {
  @override
  Widget build(BuildContext context) {
    return pageLayout(
      context,
      'Money Manager',
      'Track your expenses',
      'expenses',
      Icons.account_balance_wallet,
      () => setState(() {}),
    );
  }
}

Widget pageLayout(
  BuildContext context,
  String title,
  String subtitle,
  String type,
  IconData pageIcon,
  VoidCallback refresh,
) {
  return StatefulBuilder(
    builder: (context, updatePage) {
      final items = List<Map<String, dynamic>>.from(
        AuvxStore.data[type] ?? [],
      );

      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(pageIcon, color: const Color(0xFF55E6FF), size: 30),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: const TextStyle(color: Colors.white60),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      await addItem(context, type);
                      updatePage(() {});
                    },
                    icon: const Icon(
                      Icons.add_circle,
                      color: Color(0xFF55E6FF),
                      size: 32,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              pageIcon,
                              size: 55,
                              color: Colors.white24,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Nothing here yet',
                              style: TextStyle(color: Colors.white54),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Tap + to add something',
                              style: TextStyle(color: Colors.white38),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final isDone = item['done'] == true;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: glassBox(
                              child: Row(
                                children: [
                                  if (type == 'tasks' || type == 'habits')
                                    Checkbox(
                                      value: isDone,
                                      activeColor: const Color(0xFF55E6FF),
                                      onChanged: (value) async {
                                        await AuvxStore.updateRecord(
                                          type,
                                          index,
                                          {'done': value ?? false},
                                        );
                                        updatePage(() {});
                                      },
                                    ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['title'] ?? '',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            decoration: isDone
                                                ? TextDecoration.lineThrough
                                                : null,
                                          ),
                                        ),
                                        if (type == 'expenses')
                                          Text(
                                            '৳${item['amount'] ?? '0'}',
                                            style: const TextStyle(
                                              color: Color(0xFF55E6FF),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () async {
                                      await AuvxStore.removeRecord(
                                        type,
                                        index,
                                      );
                                      updatePage(() {});
                                    },
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
