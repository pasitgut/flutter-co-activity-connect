import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_co_activity_connect/components/input_field.dart';
import 'package:flutter_co_activity_connect/storage/secure_storage.dart';
import 'package:flutter_co_activity_connect/utils/app_colors.dart';
import 'package:flutter_co_activity_connect/screens/activity/activity_feed_screen.dart';
import 'package:flutter_co_activity_connect/services/activity_service.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class CreateActivityScreen extends StatefulWidget {
  const CreateActivityScreen({super.key});

  @override
  State<CreateActivityScreen> createState() => _CreateActivityScreenState();
}

class _CreateActivityScreenState extends State<CreateActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  final ActivityService _activityService = ActivityService();
  // Controllers
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();
  final TextEditingController _maxMemberCtrl = TextEditingController();
  final TextEditingController _tagInputCtrl = TextEditingController();

  bool _isPublic = true;
  final List<String> _tags = [];
  bool _isLoading = false;
  String _errorMessage = '';
  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _maxMemberCtrl.dispose();
    _tagInputCtrl.dispose();
    super.dispose();
  }

  void _addTag(String tag) {
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
      });
    }
    _tagInputCtrl.clear();
  }

  void _onSubmit() async {
    final token = await SecureStorage.readToken();
    final jwtDecode = JwtDecoder.decode(token!);

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      if (_formKey.currentState!.validate()) {
        final data = {
          'user_id': jwtDecode['id'], // TODO: auth
          'title': _titleCtrl.text,
          'description': _descCtrl.text,
          'max_member': int.tryParse(_maxMemberCtrl.text) ?? 0,
          'is_public': _isPublic,
          'tags': _tags,
        };

        debugPrint("Activity data: $data");
        // TODO: call API

        final response = await _activityService.createActivity(
          jwtDecode['id'],
          _titleCtrl.text,
          _descCtrl.text,
          int.tryParse(_maxMemberCtrl.text) ?? 0,
          _isPublic,
          _tags,
        );
        debugPrint("Response: ${jsonDecode(response.body)}");
        if (response.statusCode == 201) {
          // push to list on state
          Navigator.pop(context);
        } else {
          final error = jsonDecode(response.body)['error'];
          setState(() {
            _errorMessage = error['message'] ?? "Login failed";
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_errorMessage),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("1")));
      }
    } catch (e) {
      debugPrint("Error: $e");
      setState(() {
        _errorMessage = 'Could not connect to the server';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorMessage),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Create Activity"),
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black,
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  InputField(
                    text: "Activity title",
                    hintText: "Enter your activity title",
                    controller: _titleCtrl,
                    textInputAction: TextInputAction.next,
                    textInputType: TextInputType.text,
                    validator: (v) =>
                        v!.isEmpty ? "activity title is required." : null,
                  ),

                  InputField(
                    text: "Description",
                    hintText: "Enter activity description",
                    controller: _descCtrl,
                    textInputAction: TextInputAction.next,
                    textInputType: TextInputType.text,
                  ),

                  /// Row -> Max members (left) + isPublic (right)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 8.0,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: InputField(
                            text: "Max members",
                            hintText: "Enter max members",
                            controller: _maxMemberCtrl,
                            textInputAction: TextInputAction.next,
                            textInputType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Text("Public"),
                              Switch(
                                value: _isPublic,
                                activeThumbColor: AppColors.primaryColor,
                                onChanged: (val) {
                                  setState(() => _isPublic = val);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// Tags with chips
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 8.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InputField(
                          text: "Tags",
                          hintText: "Type a tag and press Enter",
                          controller: _tagInputCtrl,
                          textInputAction: TextInputAction.done,
                          textInputType: TextInputType.name,
                          onSubmitted: _addTag,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: _tags
                              .map(
                                (tag) => ChoiceChip(
                                  label: Text(tag),
                                  selected: true,
                                  onSelected: (_) {
                                    setState(() => _tags.remove(tag));
                                  },
                                  selectedColor: AppColors.primaryColor,
                                  labelStyle: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: ElevatedButton(
            onPressed: _onSubmit,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              shadowColor: AppColors.primaryColor,
              elevation: 8,
            ),
            child: _isLoading
                ? CircularProgressIndicator.adaptive()
                : Text("Create Activity"),
          ),
        ),
      ),
    );
  }
}
