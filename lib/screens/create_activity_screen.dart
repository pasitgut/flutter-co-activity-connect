import 'package:flutter/material.dart';

class CreateActivityScreen extends StatefulWidget {
  const CreateActivityScreen({super.key});

  @override
  State<CreateActivityScreen> createState() => _CreateActivityScreenState();
}

class _CreateActivityScreenState extends State<CreateActivityScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _maxMembersController = TextEditingController();
  final TextEditingController _joinConditionController =
      TextEditingController();

  // Variables
  String? _selectedActivityType;
  String? _selectedImage;
  final List<String> _tags = [];
  String _newTag = '';

  // Sample activity types
  final List<String> _activityTypes = [
    'Study Group',
    'Sports',
    'Project',
    'Social',
    'Volunteer',
    'Competition',
    'Workshop',
    'Other',
  ];

  // Sample tags
  final List<String> _sampleTags = [
    'Math',
    'Science',
    'Programming',
    'Design',
    'Music',
    'Sports',
    'Reading',
    'Travel',
    'Food',
    'Gaming',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _maxMembersController.dispose();
    _joinConditionController.dispose();
    super.dispose();
  }

  void _addTag() {
    if (_newTag.isNotEmpty && !_tags.contains(_newTag)) {
      setState(() {
        _tags.add(_newTag);
        _newTag = '';
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Validate required fields
      if (_selectedActivityType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select activity type')),
        );
        return;
      }

      if (_tags.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one tag')),
        );
        return;
      }

      // Process the form data
      final activityData = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'image': _selectedImage,
        'activityType': _selectedActivityType,
        'tags': _tags,
        'joinCondition': _joinConditionController.text,
        'maxMembers': int.tryParse(_maxMembersController.text) ?? 50,
      };

      // TODO: Send data to backend or navigate to next screen
      print('Activity Data: $activityData');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Activity created successfully!')),
      );

      // Navigate back or to next screen
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Create Activity"),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Activity Name
                const Text(
                  'Activity Name',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'Enter activity name',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter activity name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Description
                const Text(
                  'Description',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Describe your activity...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Activity Image
                const Text(
                  'Activity Image',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _selectedImage != null
                      ? Image.network(_selectedImage!, fit: BoxFit.cover)
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.photo_library,
                                size: 48,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () {
                                  // TODO: Implement image picker
                                  setState(() {
                                    _selectedImage =
                                        'https://via.placeholder.com/150';
                                  });
                                },
                                child: const Text('Upload Image'),
                              ),
                            ],
                          ),
                        ),
                ),
                const SizedBox(height: 16),

                // Activity Type
                const Text(
                  'Activity Type',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _selectedActivityType,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: _activityTypes.map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedActivityType = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select activity type';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Tags
                const Text(
                  'Tags',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                // Display selected tags
                if (_tags.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _tags.map((tag) {
                      return Chip(
                        label: Text(tag),
                        onDeleted: () => _removeTag(tag),
                        deleteIcon: const Icon(Icons.close, size: 18),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 8),
                // Add new tag
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Add a tag...',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) => _newTag = value,
                        onSubmitted: (_) => _addTag(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _addTag,
                      child: const Text('Add'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Sample tags
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _sampleTags.map((tag) {
                    return FilterChip(
                      label: Text(tag),
                      selected: _tags.contains(tag),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            if (!_tags.contains(tag)) _tags.add(tag);
                          } else {
                            _tags.remove(tag);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // // Join Condition
                // const Text(
                //   'Join Condition',
                //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                // ),
                // const SizedBox(height: 8),
                // TextFormField(
                //   controller: _joinConditionController,
                //   maxLines: 2,
                //   decoration: const InputDecoration(
                //     hintText: 'Enter join requirements (optional)...',
                //     border: OutlineInputBorder(),
                //     contentPadding: EdgeInsets.symmetric(
                //       horizontal: 12,
                //       vertical: 16,
                //     ),
                //   ),
                // ),
                // const SizedBox(height: 16),

                // Max Members
                const Text(
                  'Maximum Members',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _maxMembersController,
                  decoration: const InputDecoration(
                    hintText: 'Enter maximum number of members',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter maximum members';
                    }
                    if (int.tryParse(value) == null || int.parse(value) <= 0) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Create Activity',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
