import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomCalendar extends StatefulWidget {
  final String userId;

  const CustomCalendar({Key? key, required this.userId}) : super(key: key);

  @override
  _CustomCalendarState createState() => _CustomCalendarState();
}

class _CustomCalendarState extends State<CustomCalendar> {
  DateTime _selectedDate = DateTime.now();
  final Map<DateTime, List<int>> _checkedStates = {};
  final Map<DateTime, List<int>> _fetchedStates = {};
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;

  @override
  void initState() {
    super.initState();
    _initializeCheckedStates();
  }

  void _initializeCheckedStates() async {
    _checkedStates.clear();
    _generateCheckedStates();
    await _fetchSelectedDays();
  }

  void _generateCheckedStates() {
    int totalDays = DateTime(_selectedYear, _selectedMonth + 1, 0).day;
    for (int i = 1; i <= totalDays; i++) {
      _checkedStates[DateTime(_selectedYear, _selectedMonth, i)] = [0, 0];
    }
  }

  Future<void> _saveSelectedDays() async {
    final collectionRef = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('selectedDays');

    _checkedStates.forEach((date, isSelected) async {
      await collectionRef.doc(date.toIso8601String()).set({
        'date': date,
        'lunch': isSelected[0],
        'dinner': isSelected[1],
      });
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Selections saved!')));
  }

  Future<void> _saveSelectedDays2() async {
    final collectionRef = FirebaseFirestore.instance
        .collection('bonuriDeMasa')
        .doc(widget.userId)
        .collection('selectedDays');

    _checkedStates.forEach((date, isSelected) async {
      await collectionRef.doc(date.toIso8601String()).set({
        'date': date,
        'lunch': isSelected[0],
        'dinner': isSelected[1],
      });
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Selections saved!')));
  }

  Future<void> _fetchSelectedDays() async {
    final bonuriDeMasaCollectionRef = FirebaseFirestore.instance
        .collection('bonuriDeMasa')
        .doc(widget.userId)
        .collection('selectedDays')
        .where('date',
            isGreaterThanOrEqualTo: DateTime(_selectedYear, _selectedMonth))
        .where('date', isLessThan: DateTime(_selectedYear, _selectedMonth + 1));

    var bonuriDeMasaQuerySnapshot = await bonuriDeMasaCollectionRef.get();

    for (var doc in bonuriDeMasaQuerySnapshot.docs) {
      var data = doc.data();
      DateTime date = (data['date'] as Timestamp).toDate();
      int lunch = data['lunch'] ?? 0;
      int dinner = data['dinner'] ?? 0;
      setState(() {
        _checkedStates[date] = [lunch, dinner];
      });
    }

    final usersCollectionRef = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('selectedDays')
        .where('date',
            isGreaterThanOrEqualTo: DateTime(_selectedYear, _selectedMonth))
        .where('date', isLessThan: DateTime(_selectedYear, _selectedMonth + 1));

    var usersQuerySnapshot = await usersCollectionRef.get();

    for (var doc in usersQuerySnapshot.docs) {
      var data = doc.data();
      DateTime date = (data['date'] as Timestamp).toDate();
      int lunch = data['lunch'] ?? 0;
      int dinner = data['dinner'] ?? 0;
      setState(() {
        _fetchedStates[date] = [lunch, dinner];
      });
    }
  }

  void _updateCalendar(int year, int month) async {
    setState(() {
      _selectedYear = year;
      _selectedMonth = month;
      _selectedDate = DateTime(year, month);
    });
    _initializeCheckedStates();
  }

  Widget _buildMonthYearPicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        DropdownButton<int>(
          value: _selectedMonth,
          items: List.generate(12, (index) {
            return DropdownMenuItem(
              value: index + 1,
              child: Text('${index + 1}'),
            );
          }),
          onChanged: (value) =>
              value != null ? _updateCalendar(_selectedYear, value) : null,
        ),
        DropdownButton<int>(
          value: _selectedYear,
          items: List.generate(5, (index) {
            return DropdownMenuItem(
              value: DateTime.now().year - 2 + index,
              child: Text('${DateTime.now().year - 2 + index}'),
            );
          }),
          onChanged: (value) =>
              value != null ? _updateCalendar(value, _selectedMonth) : null,
        ),
      ],
    );
  }

  Widget _dayWidget(DateTime date) {
    List<int>? checks = _checkedStates[date];
    if (checks == null) return Container();

    bool isWeekday =
        date.weekday != DateTime.saturday && date.weekday != DateTime.sunday;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(4.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text(
              "${date.day}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isWeekday ? Colors.black : Colors.grey,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Checkbox(
                value: isWeekday && checks[0] == 1,
                onChanged: isWeekday
                    ? (value) => setState(() => _checkedStates[date]![0] = value! ? 1 : 0)
                    : null,
                checkColor: Colors.white,
                activeColor: Colors.green,
              ),
              Checkbox(
                value: isWeekday && checks[1] == 1,
                onChanged: isWeekday
                    ? (value) => setState(() => _checkedStates[date]![1] = value! ? 1 : 0)
                    : null,
                checkColor: Colors.white,
                activeColor: Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _daySummaryWidget(DateTime date) {
    List<int>? checks = _fetchedStates[date];
    if (checks == null) return Container();

    return Card(
      margin: const EdgeInsets.all(4.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              "${date.day}",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              "Lunch: ${checks[0]}",
              style: TextStyle(color: Colors.green),
            ),
            Text(
              "Dinner: ${checks[1]}",
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  Row _buildDaysOfWeekHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        for (var day in ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'])
          Text(day, style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  List<Widget> _buildCalendar({bool isSummary = false}) {
    List<Widget> widgets = [];
    widgets.add(_buildDaysOfWeekHeader());

    DateTime firstOfMonth =
        DateTime(_selectedDate.year, _selectedDate.month, 1);
    int dayOfWeek = firstOfMonth.weekday;
    int adjustForWeekStart = 1;
    int adjustedDayOfWeek = ((dayOfWeek - adjustForWeekStart) % 7);
    List<Widget> week =
        List.generate(adjustedDayOfWeek, (_) => Expanded(child: Container()));

    int totalDays =
        DateTime(_selectedDate.year, _selectedDate.month + 1, 0).day;
    for (int i = 1; i <= totalDays; i++) {
      DateTime date = DateTime(_selectedDate.year, _selectedDate.month, i);
      week.add(Expanded(
        child: isSummary ? _daySummaryWidget(date) : _dayWidget(date),
      ));
      if ((i + adjustedDayOfWeek) % 7 == 0 || i == totalDays) {
        while (week.length < 7) {
          week.add(Expanded(child: Container()));
        }
        widgets.add(Row(children: week));
        week = [];
      }
    }
    return widgets;
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                value: _checkedStates.values.any((value) => value[0] == 1),
                onChanged: (value) {
                  setState(() {
                    _checkedStates.forEach((date, isSelected) {
                      if (date.weekday != DateTime.saturday &&
                          date.weekday != DateTime.sunday) {
                        _checkedStates[date]![0] = value! ? 1 : 0;
                      }
                    });
                  });
                },
                checkColor: Colors.white,
                activeColor: Colors.green,
              ),
              const Text('Lunch'),
            ],
          ),
          const SizedBox(width: 24),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                value: _checkedStates.values.any((value) => value[1] == 1),
                onChanged: (value) {
                  setState(() {
                    _checkedStates.forEach((date, isSelected) {
                      if (date.weekday != DateTime.saturday &&
                          date.weekday != DateTime.sunday) {
                        _checkedStates[date]![1] = value! ? 1 : 0;
                      }
                    });
                  });
                },
                checkColor: Colors.white,
                activeColor: Colors.red,
              ),
              const Text('Dinner'),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Custom Calendar"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              _saveSelectedDays();
              _saveSelectedDays2();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildMonthYearPicker(),
              const SizedBox(height: 16),
              const Text(
                "Zilele în care studentul/ă a plătit masa:",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 16),
              ..._buildCalendar(),
              const SizedBox(height: 16),
              _buildLegend(),
              const Divider(
                color: Colors.black,
                thickness: 2,
              ),
              const SizedBox(height: 16),
              const Text(
                "Mese active:",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 16),
              ..._buildCalendar(isSummary: true),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}