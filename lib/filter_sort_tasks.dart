import 'package:flutter/material.dart';
import 'datamodel.dart';

class FilterSortTasks extends StatefulWidget {
  @override
  _FilterSortTasksState createState() => _FilterSortTasksState();
}

class _FilterSortTasksState extends State<FilterSortTasks> {
  String _filter = 'All';
  String _sortBy = 'Due Date';
  List<Task> _tasks = [];

  void _applyFilter() {
    // Implement filtering logic based on _filter
  }

  void _applySorting() {
    // Implement sorting logic based on _sortBy
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButton<String>(
          value: _filter,
          items: ['All', 'Incomplete', 'Complete'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _filter = value!;
              _applyFilter();
            });
          },
        ),
        DropdownButton<String>(
          value: _sortBy,
          items: ['Due Date', 'Status'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _sortBy = value!;
              _applySorting();
            });
          },
        ),
        // Display filtered and sorted tasks
      ],
    );
  }
}
