import 'package:flutter/material.dart';
import 'package:baby_kit2/session_manager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DetailProfilPage extends StatefulWidget {
  const DetailProfilPage({super.key});

  @override
  State<DetailProfilPage> createState() => _DetailProfilPageState();
}

class _DetailProfilPageState extends State<DetailProfilPage> {
  final SessionManager _sessionManager = SessionManager();

  String userId = '';
  String userName = '';
  String userEmail = '';
  String phone = '';
  String address = '';

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final session = await _sessionManager.getUserSession();
    setState(() {
      userId = session['user_id'].toString();
      userName = session['name'] ?? '';
      userEmail = session['email'] ?? '';
      phone = session['phone'] ?? '';
      address = session['address'] ?? '';

      _nameController.text = userName;
      _phoneController.text = phone;
      _addressController.text = address;
    });
  }

  Future<void> _updateProfile() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nama tidak boleh kosong')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse(
        'http://192.168.1.9/baby_kit_project/baby_kit_api/update_user.php',
      );

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'address': _addressController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);

      if (data['status'] == 'success') {
        // Update session
        await _sessionManager.saveUserSession({
          'user_id': int.parse(userId),
          'name': _nameController.text.trim(),
          'email': userEmail,
          'phone': _phoneController.text.trim(),
          'address': _addressController.text.trim(),
        });

        setState(() {
          userName = _nameController.text.trim();
          phone = _phoneController.text.trim();
          address = _addressController.text.trim();
          _isEditing = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Profil berhasil diperbarui'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Gagal: ${data['message']}')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      _nameController.text = userName;
      _phoneController.text = phone;
      _addressController.text = address;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // App Bar dengan gradient
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: Colors.pink[400],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.pink[300]!, Colors.pink[500]!],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Hero(
                      tag: 'profile_avatar',
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.pink[400],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      userName.isNotEmpty ? userName : 'User',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              if (!_isEditing)
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _isEditing = true;
                    });
                  },
                ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Header
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.pink[50],
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.person_outline,
                                color: Colors.pink[400],
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Informasi Pribadi',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              if (_isEditing)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange[100],
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: const [
                                      Icon(
                                        Icons.edit,
                                        size: 14,
                                        color: Colors.orange,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Mode Edit',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.orange,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // Fields
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              // User ID & Nama 
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildModernField(
                                      icon: Icons.badge_outlined,
                                      label: 'User ID',
                                      value: userId,
                                      editable: false,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    flex: 2,
                                    child: _buildModernField(
                                      icon: Icons.person_outline,
                                      label: 'Nama Lengkap',
                                      value: userName,
                                      editable: true,
                                      controller: _nameController,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildModernField(
                                icon: Icons.email_outlined,
                                label: 'Email',
                                value: userEmail,
                                editable: false,
                              ),
                              const SizedBox(height: 16),
                              _buildModernField(
                                icon: Icons.phone_outlined,
                                label: 'Nomor Telepon',
                                value: phone,
                                editable: true,
                                controller: _phoneController,
                                hint: 'Masukkan nomor telepon',
                              ),
                              const SizedBox(height: 16),
                              _buildModernField(
                                icon: Icons.location_on_outlined,
                                label: 'Alamat',
                                value: address,
                                editable: true,
                                controller: _addressController,
                                maxLines: 2,
                                hint: 'Masukkan alamat lengkap',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Action Buttons
                  if (_isEditing) ...[
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isLoading ? null : _cancelEdit,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(color: Colors.grey[400]!),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Batal',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _updateProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pink[400],
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.save,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Simpan Perubahan',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernField({
    required IconData icon,
    required String label,
    required String value,
    bool editable = false,
    TextEditingController? controller,
    int maxLines = 1,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: Colors.pink[400]),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: _isEditing && editable ? Colors.white : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isEditing && editable
                  ? Colors.pink[200]!
                  : Colors.grey[200]!,
              width: _isEditing && editable ? 2 : 1,
            ),
          ),
          child: _isEditing && editable
              ? TextField(
                  controller: controller,
                  maxLines: maxLines,
                  style: const TextStyle(fontSize: 15),
                  decoration: InputDecoration(
                    hintText: hint ?? 'Masukkan $label',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    contentPadding: const EdgeInsets.all(14),
                    border: InputBorder.none,
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(14),
                  child: Text(
                    value.isNotEmpty ? value : '-',
                    style: TextStyle(
                      fontSize: 15,
                      color: value.isNotEmpty ? Colors.black87 : Colors.grey,
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
