import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting dates and times
import 'login.dart'; // Import the login page

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shared Schedule App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginPage(), // Start with the login page
    );
  }
}

class HomePage extends StatefulWidget {
  final String user;

  HomePage({required this.user}); // Accepting user parameter

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<DateTime, List<Map<String, dynamic>>> _appointments = {};
  DateTime _selectedDate = DateTime.now(); // Current selected date

  // Function to add an appointment with time
  void _addAppointment(DateTime date) {
    final TextEditingController _appointmentController = TextEditingController();
    TimeOfDay? selectedTime;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Appointment for ${DateFormat('EEEE, MMMM d').format(date)}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _appointmentController,
                decoration: InputDecoration(labelText: 'Appointment'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  selectedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                },
                child: Text('Pick Time'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_appointmentController.text.isNotEmpty && selectedTime != null) {
                  setState(() {
                    _appointments.putIfAbsent(date, () => []);
                    _appointments[date]!.add({
                      'event': _appointmentController.text,
                      'time': selectedTime!.format(context),
                    });
                  });
                  Navigator.of(context).pop();
                }
              },
              child: Text('Add'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Function to delete an appointment
  void _deleteAppointment(DateTime date, Map<String, dynamic> appointment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Appointment'),
          content: Text('Do you want to delete "${appointment['event']}" at ${appointment['time']}?'),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _appointments[date]!.remove(appointment);
                  if (_appointments[date]!.isEmpty) {
                    _appointments.remove(date); // Remove the date key if no appointments left
                  }
                });
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _nextWeek() {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: 7)); // Move to next week
    });
  }

  void _previousWeek() {
    setState(() {
      _selectedDate = _selectedDate.subtract(Duration(days: 7)); // Move to previous week
    });
  }

  // Function to pick a specific week using DatePicker
  void _pickWeek() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Select week', // Optional label to guide users
    );

    if (pickedDate != null) {
      // Adjust the picked date to the start of the week (Monday)
      setState(() {
        _selectedDate = pickedDate.subtract(Duration(days: pickedDate.weekday - 1));
      });
    }
  }

  // Function to add a weekly schedule
  void _addWeeklySchedule() {
    final TextEditingController _scheduleController = TextEditingController();
    TimeOfDay? selectedTime;
    List<bool> selectedDays = List.generate(7, (_) => false); // Track selected days

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Add Weekly Schedule'),
              content: SingleChildScrollView( // Make content scrollable to prevent overflow
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _scheduleController,
                      decoration: InputDecoration(labelText: 'Weekly Event'),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        selectedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        setDialogState(() {});
                      },
                      child: Text('Pick Time'),
                    ),
                    SizedBox(height: 10),
                    Text('Select Days:'),
                    Column(
                      children: List.generate(7, (index) {
                        return CheckboxListTile(
                          title: Text(DateFormat('EEEE').format(DateTime.now().add(Duration(days: index)))),
                          value: selectedDays[index],
                          onChanged: (value) {
                            setDialogState(() {
                              selectedDays[index] = value!;
                            });
                          },
                        );
                      }),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (_scheduleController.text.isNotEmpty && selectedTime != null) {
                      for (int i = 0; i < selectedDays.length; i++) {
                        if (selectedDays[i]) {
                          // Add the event for the current and future weeks on the selected days
                          for (int weekOffset = 0; weekOffset < 52; weekOffset++) { // Repeat for 52 weeks (one year)
                            DateTime scheduleDate = _selectedDate.add(Duration(days: i + weekOffset * 7));
                            setState(() {
                              // Add the event to the appointments for the selected days and weeks
                              _appointments.putIfAbsent(scheduleDate, () => []);
                              _appointments[scheduleDate]!.add({
                                'event': _scheduleController.text,
                                'time': selectedTime!.format(context),
                              });
                            });
                          }
                        }
                      }
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text('Add Weekly Schedule'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get the start date of the week
    DateTime startOfWeek = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${widget.user}!'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _addAppointment(startOfWeek), // Open dialog to add appointment for the first day of the week
          ),
          IconButton(
            icon: Icon(Icons.schedule),
            onPressed: _addWeeklySchedule, // Open dialog to add weekly schedule
          ),
        ],
      ),
      body: Column(
        children: [
          // Display the current week with option to pick a specific week
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: _previousWeek,
              ),
              Column(
                children: [
                  Text(
                    'Week of ${DateFormat('MMMM d, yyyy').format(startOfWeek)}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton(
                    onPressed: _pickWeek, // Option to pick a specific week
                    child: Text('Pick a Week'),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(Icons.arrow_forward),
                onPressed: _nextWeek,
              ),
            ],
          ),
          // Display appointments for each day of the week in a table
          Expanded(
            child: ListView.builder(
              itemCount: 7, // 7 days in a week
              itemBuilder: (context, index) {
                DateTime currentDay = startOfWeek.add(Duration(days: index));
                return Card(
                  child: ListTile(
                    title: Text(DateFormat('EEEE, MMMM d').format(currentDay)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _appointments[currentDay]?.map((appointment) {
                        return GestureDetector(
                          onTap: () => _deleteAppointment(currentDay, appointment), // Handle tap to delete appointment
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: Text(
                              '${appointment['event']} at ${appointment['time']}',
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        );
                      }).toList() ?? [],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () => _addAppointment(currentDay), // Add appointment for the specific day
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
