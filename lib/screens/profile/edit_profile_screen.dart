import 'package:flutter/material.dart';
import 'package:flutter_co_activity_connect/components/dropdown_button.dart';
import 'package:flutter_co_activity_connect/components/input_field.dart';
import 'package:flutter_co_activity_connect/services/user_service.dart'; // ✅ import service
import 'package:flutter_co_activity_connect/storage/secure_storage.dart';
import 'package:flutter_co_activity_connect/utils/app_colors.dart';
import 'package:flutter_co_activity_connect/utils/app_constants.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _majorController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  String? _userId;
  String? _selectedYear;
  String? _selectedFaculty;

  final List<String> _avatars = [
    "https://i.pravatar.cc/150?img=1",
    "https://i.pravatar.cc/150?img=2",
    "https://i.pravatar.cc/150?img=3",
    "https://i.pravatar.cc/150?img=4",
    "https://i.pravatar.cc/150?img=5",
  ];

  String _selectedAvatar = "https://i.pravatar.cc/150?img=1";
  bool _showAvatarOptions = false;
  bool _isLoading = false;

  final UserService _userService = UserService(); // ✅ instance service

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() async {
    final token = await SecureStorage.readToken();
    final decoded = JwtDecoder.decode(token!);
    debugPrint("Decoded: $decoded");
    setState(() {
      _userId = decoded['id'];
      _usernameController.text = decoded['username'];
      _majorController.text = decoded['major'];
      _selectedYear = decoded['year'];
      _selectedFaculty = decoded['faculty'];
      _bioController.text = decoded['bio'] ?? "";
    });
  }

  Future<void> _saveProfile() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      final response = await _userService.updateProfile(
        _userId!,
        _usernameController.text.trim(),
        _selectedYear ?? "",
        _selectedFaculty ?? "",
        _majorController.text.trim(),
        _bioController.text.trim(),
        false, // isPrivate (ยังไม่ได้ใช้)
      );

      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully ✅")),
        );
        Navigator.pop(context, true); // ส่งค่า true กลับไปบอกว่ามีการอัพเดต
      } else {
        debugPrint("Error: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update: ${response.statusCode}")),
        );
      }
    } catch (e) {
      debugPrint("Exception: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _majorController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Edit Profile"),
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  // Avatar
                  Center(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 64,
                          backgroundImage: NetworkImage(_selectedAvatar),
                        ),
                        // IconButton(
                        //   onPressed: () {
                        //     setState(() {
                        //       _showAvatarOptions = !_showAvatarOptions;
                        //     });
                        //   },
                        //   style: IconButton.styleFrom(
                        //     backgroundColor: Colors.grey.shade400,
                        //     foregroundColor: Colors.white,
                        //   ),
                        //   icon: const Icon(Icons.edit, size: 20),
                        // ),
                      ],
                    ),
                  ),

                  // Avatar options
                  if (_showAvatarOptions) ...[
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemCount: _avatars.length,
                      itemBuilder: (context, index) {
                        final avatar = _avatars[index];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedAvatar = avatar;
                              _showAvatarOptions = false;
                            });
                          },
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(avatar),
                            radius: 40,
                            child: _selectedAvatar == avatar
                                ? Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.black45,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                    ),
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
                  ],

                  const SizedBox(height: 24),
                  InputField(
                    text: "Username",
                    hintText: "Enter your username",
                    controller: _usernameController,
                    textInputAction: TextInputAction.done,
                    textInputType: TextInputType.name,
                  ),
                  const SizedBox(height: 12),
                  DropDownButton(
                    text: "Faculty",
                    hintText: "Select your faculty",
                    items: AppConstants.faculties,
                    onChanged: (val) => setState(() => _selectedFaculty = val!),
                    value: _selectedFaculty,
                  ),
                  const SizedBox(height: 12),
                  InputField(
                    text: "Major",
                    hintText: "Enter your major",
                    controller: _majorController,
                    textInputAction: TextInputAction.done,
                    textInputType: TextInputType.name,
                  ),
                  const SizedBox(height: 12),
                  DropDownButton(
                    text: "Year",
                    hintText: "Select your year",
                    items: AppConstants.years,
                    onChanged: (val) => setState(() => _selectedYear = val!),
                    value: _selectedYear,
                  ),
                  const SizedBox(height: 12),
                  InputField(
                    text: "Bio",
                    hintText: "Bio",
                    controller: _bioController,
                    textInputAction: TextInputAction.done,
                    textInputType: TextInputType.name,
                  ),

                  const SizedBox(height: 24),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Save"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
