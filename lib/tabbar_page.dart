import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Import the intl package
import 'get_api_data.dart';

class TabbarPage extends StatefulWidget {
  const TabbarPage({super.key});

  @override
  State<TabbarPage> createState() => _TabbarPageState();
}

class _TabbarPageState extends State<TabbarPage> {
  late Welcome _dataFromAPI;
  bool isLoading = true;
  bool hasMoreData = true;
  int currentPage = 1;
  late ScrollController _scrollController;
  final int limit = 10;
  late Status selectedStatus;

  bool _isShowBackToTopButton = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);

    selectedStatus = Status.TODO;
    getList();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ฟังก์ชันดึงข้อมูลจาก API
  Future<void> getList() async {
    var url = Uri.parse(
      'https://todo-list-api-mfchjooefq-as.a.run.app/todo-list?status=${selectedStatus.toString().split('.').last}&offset=${(currentPage - 1)}&limit=$limit&sortBy=createdAt&isAsc=true',
    );
    var response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        _buildLoadingIndicator();
        Welcome data = welcomeFromJson(response.body);
        if (data.tasks != null && data.tasks!.isNotEmpty) {
          if (currentPage == 1) {
            _dataFromAPI = data;
          } else {
            _dataFromAPI.tasks?.addAll(data.tasks!);
          }
          // Reset the "has more data" flag if tasks are returned
          hasMoreData = true;
        } else {
          // No tasks were returned
          hasMoreData = false; // No more data
          if (currentPage == 1) {
            // Only show dialog if this is the first page of data
            _showDialog(context); // Show the "Out of Task" dialog
          }
        }
        isLoading = false;

        // Increment the page for pagination
        if (hasMoreData) {
          currentPage++;
        }
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Out of Task',
            style: TextStyle(fontFamily: 'neon'),
          ),
          actions: <Widget>[
            const SizedBox(width: 80),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Just close the dialog
              },
              child: const Text(
                'Close',
                style: TextStyle(fontFamily: 'neon'),
              ),
            ),
          ],
        );
      },
    );
  }

  // Scroll Listener to detect when to load more data
  void _scrollListener() {
    // ตรวจสอบว่าเลื่อนไปถึงล่างสุดของ ListView
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!isLoading && hasMoreData) {
        setState(() {
          isLoading = false;
          currentPage++; // เปลี่ยนหน้าต่อไป
        });
        getList(); // เรียกข้อมูลชุดถัดไป
      } else if (!hasMoreData) {
        // ไม่มีข้อมูลเพิ่มแล้ว ให้แสดง dialog
        setState(() {
          _showDialog(context); // Show "Out of task" dialog
          isLoading = false;
        });
      }
    }

    // Show "Back to Top" button if scrolled more than halfway
    if (_scrollController.position.pixels >
        (_scrollController.position.maxScrollExtent / 2)) {
      if (!_isShowBackToTopButton) {
        setState(() {
          _isShowBackToTopButton = true;
        });
      }
    } else {
      if (_isShowBackToTopButton) {
        setState(() {
          _isShowBackToTopButton = false;
        });
      }
    }
  }

  // Method to scroll back to the top
  void _scrollToTop() {
    _scrollController.animateTo(
      0, // Scroll to the top
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color.fromARGB(230, 134, 64, 145),
          centerTitle: false,
          title: const Row(
            children: [
              Text(
                'TODO LIST',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 30,
                    fontFamily: 'neon'),
              ),
            ],
          ),
          bottom: TabBar(
            labelColor: Colors.white,
            labelStyle: const TextStyle(
              fontFamily: 'neon',
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            indicatorColor: Colors.pink.shade50.withOpacity(1),
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorWeight: 5,
            unselectedLabelColor: Colors.white60,
            tabs: const [
              Tab(text: 'TODO'),
              Tab(text: 'DOING'),
              Tab(text: 'DONE'),
            ],
            onTap: (index) {
              setState(() {
                // เปลี่ยนสถานะตามแท็บที่เลือก
                if (index == 0) {
                  selectedStatus = Status.TODO;
                } else if (index == 1) {
                  selectedStatus = Status.DOING;
                } else {
                  selectedStatus = Status.DONE;
                }
                // รีเซ็ตข้อมูลเมื่อเปลี่ยนแท็บ
                currentPage = 1;
                hasMoreData = true;
                isLoading = true;
                getList();
              });
            },
          ),
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator()) // Show loading indicator
            : TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildTaskList(Status.TODO),
                  _buildTaskList(Status.DOING),
                  _buildTaskList(Status.DONE),
                ],
              ),
        // Show "Back to Top" button if scrolled past half
        floatingActionButton: _isShowBackToTopButton
            ? FloatingActionButton(
                onPressed: _scrollToTop,
                backgroundColor: Colors.purple.shade50.withOpacity(0.2),
                child: const Icon(Icons.arrow_upward),
              )
            : null,
      ),
    );
  }

  // Method to build the ListView for each status
  Widget _buildTaskList(Status status) {
    final filteredTasks =
        _dataFromAPI.tasks?.where((task) => task.status == status).toList() ??
            [];

    // Group tasks by date
    Map<String, List<Task>> groupedTasks = {};

    for (var task in filteredTasks) {
      if (task.createdAt != null) {
        // Format the task creation date to 'yyyy-MM-dd' (to group by date)
        String dateKey = _formatDateForGrouping(task.createdAt!);
        if (groupedTasks[dateKey] == null) {
          groupedTasks[dateKey] = [];
        }
        groupedTasks[dateKey]!.add(task);
      }
    }

    // If no tasks are available, show a message
    if (groupedTasks.isEmpty && !isLoading) {
      String noTaskMessage = '';
      switch (status) {
        case Status.TODO:
          noTaskMessage = 'UI not found';
          break;
        case Status.DOING:
          noTaskMessage = 'UI not found';
          break;
        case Status.DONE:
          noTaskMessage = 'UI not found';
          break;
      }

      return Center(
        child: Text(
          noTaskMessage,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.grey,
          ),
        ),
      );
    }

    // Create a list of widgets for each group
    List<Widget> taskWidgets = [];
    groupedTasks.forEach((date, tasks) {
      taskWidgets.add(
        Padding(
          padding: const EdgeInsets.only(left: 20.0, top: 8),
          child: Text(
            date, // Display date header
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'neon',
                color: Color.fromARGB(233, 85, 19, 93)),
          ),
        ),
      );

      // Add task cards for this date group
      for (var task in tasks) {
        taskWidgets.add(
          Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 25,
                        child: Text(
                          task.title ?? 'No Title Available',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              fontFamily: 'neon'),
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          _showDeleteConfirmationDialog(context, task);
                        },
                        child: const Text(
                          'Delete',
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'neon',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    task.description ?? 'No Description Available',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Icon(Icons.alarm),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        task.createdAt != null
                            ? _formatDate(task.createdAt!)
                            : 'No Date Available',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }
    });

    // Return a ListView.builder of task widgets grouped by date
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          colors: [
            Color.fromARGB(233, 249, 191, 255), // First shade (center)
            Color.fromARGB(233, 252, 248, 173), // Second shade (middle)
            Color.fromARGB(255, 195, 236, 233),
            Color.fromARGB(255, 234, 155, 213),
            // Second shade (middle)
            // Third shade (outer)
          ],
          center: Alignment.topLeft,
          radius: 1.5,
          stops: [0.0, 0.5, 1.0, 1.5],
        ),
      ), // Set background color for the ListView
      child: ListView.builder(
        controller: _scrollController, // Attach the scroll controller
        itemCount: taskWidgets.length +
            (hasMoreData
                ? 1
                : 0), // Add 1 for loading indicator if there is more data
        itemBuilder: (context, index) {
          if (index == taskWidgets.length) {
            // If the index is at the end of the list, show the loading indicator
            return _buildLoadingIndicator();
          }
          return taskWidgets[index];
        },
      ),
    );
  }

  // Format date for task
  String _formatDate(DateTime date) {
    return DateFormat('HH : mm').format(date);
  }

  // Group date
  String _formatDateForGrouping(DateTime date) {
    return DateFormat('d MMM yyyy').format(date);
  }

  void _deleteTask(Task task) {
    setState(() {
      // Remove the task from the list
      _dataFromAPI.tasks?.remove(task);

      // If there are no more tasks, show the "No Task" message
      if (_dataFromAPI.tasks?.isEmpty ?? true) {
        _showDialog(context); // Show a dialog when there are no tasks left
      }
    });
  }

  // Loading indicator
  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(child: CircularProgressIndicator()),
    );
  }

  // Show delete confirmation dialog
  void _showDeleteConfirmationDialog(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: const Text('Are you sure you want to delete this task?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Handle task deletion here
                setState(() {
                  _deleteTask(task);
                });
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
