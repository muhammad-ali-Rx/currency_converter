import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../auth/auth_provider.dart';
import '../../../utils/modern_constants.dart';
import '../../../utils/responsive_helper.dart';
import '../../../widgets/common/loading_widget.dart';
import '../../../widgets/common/empty_state_widget.dart';

class UsersManagement extends StatefulWidget {
  const UsersManagement({super.key});

  @override
  State<UsersManagement> createState() => _FixedUsersManagementState();
}

class _FixedUsersManagementState extends State<UsersManagement> {
  List<Map<String, dynamic>> users = [];
  bool isLoading = true;
  String searchQuery = '';
  String selectedFilter = 'All';
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  // ✅ HELPER: Convert timestamp to readable date
  String _formatTimestamp(dynamic timestamp) {
    try {
      DateTime dateTime;
      
      if (timestamp == null) {
        return 'Not available';
      }
      
      // Handle Firestore Timestamp
      if (timestamp.runtimeType.toString().contains('Timestamp')) {
        dateTime = timestamp.toDate();
      }
      // Handle string timestamp
      else if (timestamp is String) {
        dateTime = DateTime.parse(timestamp);
      }
      // Handle milliseconds since epoch
      else if (timestamp is int) {
        dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      }
      // Handle DateTime object
      else if (timestamp is DateTime) {
        dateTime = timestamp;
      }
      // Handle Map with seconds (Firestore format)
      else if (timestamp is Map && timestamp.containsKey('seconds')) {
        final seconds = timestamp['seconds'] as int;
        dateTime = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
      }
      else {
        return 'Invalid date format';
      }
      
      // Format: "Dec 28, 2024 • 10:30 AM"
      return DateFormat('MMM dd, yyyy • hh:mm a').format(dateTime);
    } catch (e) {
      print('Error formatting timestamp: $e');
      return 'Date format error';
    }
  }

  // ✅ HELPER: Get relative time (e.g., "2 days ago")
  String _getRelativeTime(dynamic timestamp) {
    try {
      DateTime dateTime;
      
      if (timestamp == null) return 'Unknown';
      
      // Convert timestamp to DateTime (same logic as above)
      if (timestamp.runtimeType.toString().contains('Timestamp')) {
        dateTime = timestamp.toDate();
      } else if (timestamp is String) {
        dateTime = DateTime.parse(timestamp);
      } else if (timestamp is int) {
        dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      } else if (timestamp is DateTime) {
        dateTime = timestamp;
      } else if (timestamp is Map && timestamp.containsKey('seconds')) {
        final seconds = timestamp['seconds'] as int;
        dateTime = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
      } else {
        return 'Unknown';
      }
      
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      
      if (difference.inDays > 365) {
        final years = (difference.inDays / 365).floor();
        return '$years year${years > 1 ? 's' : ''} ago';
      } else if (difference.inDays > 30) {
        final months = (difference.inDays / 30).floor();
        return '$months month${months > 1 ? 's' : ''} ago';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  Future<void> _loadUsers() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final usersList = await authProvider.getAllUsers();
      
      setState(() {
        users = (usersList ?? []).map((user) {
          if (user == null) return <String, dynamic>{};
          
          // ✅ Fix name extraction from different possible fields
          String userName = '';
          if (user['name'] != null && user['name'].toString().isNotEmpty) {
            userName = user['name'].toString();
          } else if (user['displayName'] != null && user['displayName'].toString().isNotEmpty) {
            userName = user['displayName'].toString();
          } else if (user['firstName'] != null || user['lastName'] != null) {
            final firstName = user['firstName']?.toString() ?? '';
            final lastName = user['lastName']?.toString() ?? '';
            userName = '$firstName $lastName'.trim();
          } else if (user['email'] != null) {
            userName = user['email'].toString().split('@')[0];
          } else {
            userName = 'Unknown User';
          }
          
          return {
            'id': user['id'] ?? user['uid'] ?? '',
            'name': userName,
            'email': user['email']?.toString() ?? 'No email',
            'role': user['role']?.toString() ?? 'user',
            'authProvider': user['authProvider']?.toString() ?? 'email',
            'platform': user['platform']?.toString() ?? 'mobile',
            'createdAt': user['createdAt'] ?? user['created_at'] ?? user['creationTime'],
            'lastLogin': user['lastLogin'] ?? user['last_login'] ?? user['lastSignInTime'],
            'isActive': user['isActive'] ?? user['is_active'] ?? true,
            'profileImage': user['profileImage'] ?? user['profile_image'] ?? user['photoURL'],
          };
        }).where((user) => user['id'].toString().isNotEmpty).toList();
        
        isLoading = false;
        
        print('✅ Loaded ${users.length} users successfully');
        users.forEach((user) {
          print('User: ${user['name']} (${user['email']}) - Created: ${_formatTimestamp(user['createdAt'])}');
        });
      });
    } catch (e) {
      print('❌ Error loading users: $e');
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load users: ${e.toString()}';
        users = [];
      });
    }
  }

  List<Map<String, dynamic>> get filteredUsers {
    if (users.isEmpty) return [];
    try {
      var filtered = List<Map<String, dynamic>>.from(users);
      if (searchQuery.isNotEmpty) {
        filtered = filtered.where((user) {
          final name = (user['name'] ?? '').toString().toLowerCase();
          final email = (user['email'] ?? '').toString().toLowerCase();
          final query = searchQuery.toLowerCase();
          return name.contains(query) || email.contains(query);
        }).toList();
      }
      if (selectedFilter != 'All') {
        filtered = filtered.where((user) {
          final userRole = (user['role'] ?? 'user').toString().toLowerCase();
          return userRole == selectedFilter.toLowerCase();
        }).toList();
      }
      return filtered;
    } catch (e) {
      print('Error filtering users: $e');
      return [];
    }
  }

  Widget _buildUserAvatar(Map<String, dynamic> user, {double radius = 24}) {
    final isAdmin = (user['role'] ?? 'user').toString().toLowerCase() == 'admin';
    final userName = user['name']?.toString() ?? 'U';
    final userInitial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';
    final profileImage = user['profileImage']?.toString();

    return Stack(
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: isAdmin ? ModernConstants.primaryPurple : ModernConstants.primaryBlue,
          backgroundImage: profileImage != null && profileImage.isNotEmpty 
            ? NetworkImage(profileImage)
            : null,
          child: profileImage == null || profileImage.isEmpty
            ? Text(
                userInitial,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: radius * 0.6,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
        ),
        if (isAdmin)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                gradient: ModernConstants.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.star_rounded,
                color: Colors.white,
                size: radius * 0.4,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    return Scaffold(
      // ✅ FIX: Add proper background color to prevent white background
      backgroundColor: ModernConstants.backgroundColor ?? const Color(0xFF0F0F23),
      body: Container(
        // ✅ FIX: Add container with gradient background for better visual appeal
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ModernConstants.backgroundColor ?? const Color(0xFF0F0F23),
              (ModernConstants.backgroundColor ?? const Color(0xFF0F0F23)).withOpacity(0.8),
            ],
          ),
        ),
        child: Padding(
          padding: ResponsiveHelper.getScreenPadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: isMobile ? 16 : 20),
              if (isMobile) _buildMobileFilters() else _buildDesktopFilters(),
              SizedBox(height: isMobile ? 16 : 20),
              Expanded(child: _buildUsersList()),
            ],
          ),
        ),
      ),
      // ✅ NEW: Add User Floating Action Button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddUserDialog,
        backgroundColor: ModernConstants.primaryBlue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_rounded),
        label: Text(ResponsiveHelper.isMobile(context) ? 'Add' : 'Add User'),
      ),
    );
  }

  Widget _buildMobileUserCard(Map<String, dynamic> user) {
    final isAdmin = (user['role'] ?? 'user').toString().toLowerCase() == 'admin';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: ModernConstants.cardGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: ModernConstants.cardShadow,
        border: Border.all(
          color: isAdmin
              ? ModernConstants.primaryPurple.withOpacity(0.3)
              : ModernConstants.textTertiary.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          _buildUserAvatar(user, radius: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['name']?.toString() ?? 'Unknown User',
                  style: const TextStyle(
                    color: ModernConstants.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user['email']?.toString() ?? 'No email',
                  style: TextStyle(
                    color: ModernConstants.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                // ✅ NEW: Show creation date
                Text(
                  'Joined ${_getRelativeTime(user['createdAt'])}',
                  style: TextStyle(
                    color: ModernConstants.textTertiary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isAdmin
                            ? ModernConstants.primaryPurple.withOpacity(0.2)
                            : ModernConstants.primaryBlue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        (user['role'] ?? 'user').toString().toUpperCase(),
                        style: TextStyle(
                          color: isAdmin ? ModernConstants.primaryPurple : ModernConstants.primaryBlue,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (user['isActive'] == true)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                onPressed: () => _showUserDetails(user),
                icon: const Icon(
                  Icons.visibility_rounded,
                  color: ModernConstants.primaryBlue,
                  size: 20,
                ),
              ),
              // ✅ NEW: Role change button
              IconButton(
                onPressed: () => _showRoleChangeDialog(user),
                icon: Icon(
                  Icons.admin_panel_settings_rounded,
                  color: isAdmin ? ModernConstants.primaryPurple : ModernConstants.primaryBlue,
                  size: 20,
                ),
              ),
              IconButton(
                onPressed: () => _deleteUser(user),
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.red,
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Users Management',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: ModernConstants.textPrimary,
          ),
        ),
        Row(
          children: [
            // ✅ NEW: Add User Button for Desktop
            if (!ResponsiveHelper.isMobile(context))
              ElevatedButton.icon(
                onPressed: _showAddUserDialog,
                icon: const Icon(Icons.person_add_rounded),
                label: const Text('Add User'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ModernConstants.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadUsers,
              tooltip: 'Reload users',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernConstants.cardBackground?.withOpacity(0.5) ?? Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ModernConstants.textTertiary.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name or email',
                hintStyle: TextStyle(color: ModernConstants.textSecondary),
                prefixIcon: Icon(Icons.search, color: ModernConstants.textSecondary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: ModernConstants.textTertiary.withOpacity(0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: ModernConstants.textTertiary.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: ModernConstants.primaryBlue),
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                filled: true,
                fillColor: ModernConstants.textTertiary.withOpacity(0.1),
              ),
              style: const TextStyle(color: ModernConstants.textPrimary),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: ModernConstants.textTertiary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: ModernConstants.textTertiary.withOpacity(0.3)),
            ),
            child: DropdownButton<String>(
              value: selectedFilter,
              underline: const SizedBox(),
              dropdownColor: ModernConstants.cardBackground,
              style: const TextStyle(color: ModernConstants.textPrimary),
              items: const [
                DropdownMenuItem(value: 'All', child: Text('All')),
                DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                DropdownMenuItem(value: 'User', child: Text('User')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedFilter = value;
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernConstants.cardBackground?.withOpacity(0.5) ?? Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ModernConstants.textTertiary.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 300,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name or email',
                hintStyle: TextStyle(color: ModernConstants.textSecondary),
                prefixIcon: Icon(Icons.search, color: ModernConstants.textSecondary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: ModernConstants.textTertiary.withOpacity(0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: ModernConstants.textTertiary.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: ModernConstants.primaryBlue),
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                filled: true,
                fillColor: ModernConstants.textTertiary.withOpacity(0.1),
              ),
              style: const TextStyle(color: ModernConstants.textPrimary),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: ModernConstants.textTertiary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: ModernConstants.textTertiary.withOpacity(0.3)),
            ),
            child: DropdownButton<String>(
              value: selectedFilter,
              underline: const SizedBox(),
              dropdownColor: ModernConstants.cardBackground,
              style: const TextStyle(color: ModernConstants.textPrimary),
              items: const [
                DropdownMenuItem(value: 'All', child: Text('All')),
                DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                DropdownMenuItem(value: 'User', child: Text('User')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedFilter = value;
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList() {
    if (isLoading) {
      return const LoadingWidget();
    }

    if (errorMessage != null) {
      return Center(child: Text(errorMessage!, style: const TextStyle(color: Colors.red)));
    }

    if (filteredUsers.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.people_outline,
        title: 'No users found',
        message: 'Try adjusting your search or filters.',
      );
    }

    final isMobile = ResponsiveHelper.isMobile(context);
    if (isMobile) {
      return ListView.builder(
        itemCount: filteredUsers.length,
        itemBuilder: (context, index) {
          return _buildMobileUserCard(filteredUsers[index]);
        },
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          color: ModernConstants.cardBackground?.withOpacity(0.5) ?? Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: ModernConstants.textTertiary.withOpacity(0.2),
          ),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(
              ModernConstants.textTertiary.withOpacity(0.1),
            ),
            columns: const [
              DataColumn(label: Text('Name', style: TextStyle(color: ModernConstants.textPrimary, fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Email', style: TextStyle(color: ModernConstants.textPrimary, fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Role', style: TextStyle(color: ModernConstants.textPrimary, fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Created', style: TextStyle(color: ModernConstants.textPrimary, fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Active', style: TextStyle(color: ModernConstants.textPrimary, fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Actions', style: TextStyle(color: ModernConstants.textPrimary, fontWeight: FontWeight.bold))),
            ],
            rows: filteredUsers.map((user) {
              final isAdmin = (user['role'] ?? 'user').toString().toLowerCase() == 'admin';
              return DataRow(
                cells: [
                  DataCell(Row(
                    children: [
                      _buildUserAvatar(user, radius: 16),
                      const SizedBox(width: 8),
                      Text(user['name']?.toString() ?? 'Unknown User', style: const TextStyle(color: ModernConstants.textPrimary)),
                    ],
                  )),
                  DataCell(Text(user['email']?.toString() ?? 'No email', style: const TextStyle(color: ModernConstants.textPrimary))),
                  DataCell(Text((user['role'] ?? 'user').toString(), style: const TextStyle(color: ModernConstants.textPrimary))),
                  DataCell(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _formatTimestamp(user['createdAt']),
                          style: const TextStyle(fontSize: 12, color: ModernConstants.textPrimary),
                        ),
                        Text(
                          _getRelativeTime(user['createdAt']),
                          style: TextStyle(
                            fontSize: 10,
                            color: ModernConstants.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  DataCell(
                    user['isActive'] == true
                        ? const Icon(Icons.check_circle, color: Colors.green, size: 18)
                        : const Icon(Icons.cancel, color: Colors.red, size: 18),
                  ),
                  DataCell(Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility_rounded, color: ModernConstants.primaryBlue),
                        onPressed: () => _showUserDetails(user),
                      ),
                      // ✅ NEW: Role change button for desktop
                      IconButton(
                        icon: Icon(
                          Icons.admin_panel_settings_rounded, 
                          color: isAdmin ? ModernConstants.primaryPurple : ModernConstants.primaryBlue
                        ),
                        onPressed: () => _showRoleChangeDialog(user),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                        onPressed: () => _deleteUser(user),
                      ),
                    ],
                  )),
                ],
              );
            }).toList(),
          ),
        ),
      );
    }
  }

  // ✅ NEW: Role Change Dialog
  void _showRoleChangeDialog(Map<String, dynamic> user) {
    final currentRole = (user['role'] ?? 'user').toString().toLowerCase();
    final isCurrentlyAdmin = currentRole == 'admin';
    final newRole = isCurrentlyAdmin ? 'user' : 'admin';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ModernConstants.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.admin_panel_settings_rounded,
              color: isCurrentlyAdmin ? ModernConstants.primaryPurple : ModernConstants.primaryBlue,
            ),
            const SizedBox(width: 12),
            Text(
              isCurrentlyAdmin ? 'Remove Admin Role' : 'Make Admin',
              style: TextStyle(
                color: isCurrentlyAdmin ? Colors.orange : ModernConstants.primaryPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildUserAvatar(user, radius: 30),
            const SizedBox(height: 16),
            Text(
              user['name']?.toString() ?? 'Unknown User',
              style: const TextStyle(
                color: ModernConstants.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              user['email']?.toString() ?? 'No email',
              style: TextStyle(
                color: ModernConstants.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (isCurrentlyAdmin ? Colors.orange : ModernConstants.primaryPurple).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: (isCurrentlyAdmin ? Colors.orange : ModernConstants.primaryPurple).withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    isCurrentlyAdmin ? Icons.remove_moderator_rounded : Icons.security_rounded,
                    color: isCurrentlyAdmin ? Colors.orange : ModernConstants.primaryPurple,
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isCurrentlyAdmin 
                        ? 'This will remove admin privileges from this user. They will become a regular user.'
                        : 'This will give admin privileges to this user. They will be able to manage other users.',
                    style: const TextStyle(
                      color: ModernConstants.textPrimary,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: ModernConstants.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _changeUserRole(user, newRole);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isCurrentlyAdmin ? Colors.orange : ModernConstants.primaryPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(isCurrentlyAdmin ? 'Remove Admin' : 'Make Admin'),
          ),
        ],
      ),
    );
  }

  // ✅ NEW: Change User Role Function
  Future<void> _changeUserRole(Map<String, dynamic> user, String newRole) async {
    try {
      final userId = user['id']?.toString();
      if (userId == null || userId.isEmpty) {
        throw Exception('User ID not found');
      }

      // Update role in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({
        'role': newRole,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update local state
      setState(() {
        final userIndex = users.indexWhere((u) => u['id'] == userId);
        if (userIndex != -1) {
          users[userIndex]['role'] = newRole;
        }
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${user['name'] ?? 'User'} is now ${newRole == 'admin' ? 'an Admin' : 'a User'}! 🎉'
          ),
          backgroundColor: newRole == 'admin' ? ModernConstants.primaryPurple : ModernConstants.primaryBlue,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      print('✅ User role updated: ${user['name']} -> $newRole');
    } catch (e) {
      print('❌ Error changing user role: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to change user role: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  // ✅ NEW: Add User Dialog
  void _showAddUserDialog() {
    showDialog(
      context: context,
      builder: (context) => AddUserDialog(
        onUserAdded: (newUser) {
          setState(() {
            users.add(newUser);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('User ${newUser['name']} added successfully!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  // ✅ IMPROVED: Better user details dialog with formatted dates
  void _showUserDetails(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ModernConstants.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            _buildUserAvatar(user, radius: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                user['name']?.toString() ?? 'User Details',
                style: const TextStyle(
                  color: ModernConstants.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailCard('Email', user['email'] ?? 'No email', Icons.email_rounded),
              _buildDetailCard('Role', (user['role'] ?? 'user').toString().toUpperCase(), Icons.admin_panel_settings_rounded),
              _buildDetailCard('Status', user['isActive'] == true ? 'Active' : 'Inactive', Icons.circle,
                 color: user['isActive'] == true ? Colors.green : Colors.red),
              _buildDetailCard('Platform', (user['platform'] ?? 'mobile').toString(), Icons.devices_rounded),
              _buildDetailCard('Auth Provider', (user['authProvider'] ?? 'email').toString(), Icons.security_rounded),
              
              // ✅ IMPROVED: Formatted creation date
              _buildDetailCard(
                'Account Created',
                 _formatTimestamp(user['createdAt']),
                 Icons.calendar_today_rounded,
                subtitle: _getRelativeTime(user['createdAt']),
              ),
              
              // ✅ IMPROVED: Formatted last login
              if (user['lastLogin'] != null)
                _buildDetailCard(
                  'Last Login',
                   _formatTimestamp(user['lastLogin']),
                   Icons.login_rounded,
                  subtitle: _getRelativeTime(user['lastLogin']),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Close',
              style: TextStyle(color: ModernConstants.primaryBlue),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ NEW: Helper widget for detail cards
  Widget _buildDetailCard(String label, String value, IconData icon, {String? subtitle, Color? color}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ModernConstants.textTertiary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: ModernConstants.textTertiary.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (color ?? ModernConstants.primaryBlue).withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              color: color ?? ModernConstants.primaryBlue,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: ModernConstants.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: ModernConstants.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: ModernConstants.textTertiary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ FIXED: Delete user from database
  Future<void> _deleteUser(Map<String, dynamic> user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ModernConstants.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Delete User',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildUserAvatar(user, radius: 30),
            const SizedBox(height: 16),
            Text(
              'Are you sure you want to delete ${user['name'] ?? 'this user'}?',
              style: const TextStyle(
                color: ModernConstants.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_rounded, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This action cannot be undone!',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final userId = user['id']?.toString();
        if (userId == null || userId.isEmpty) {
          throw Exception('User ID not found');
        }

        // ✅ FIX: Delete from Firestore database
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .delete();

        // Remove from local state
        setState(() {
          users.removeWhere((u) => u['id'] == userId);
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${user['name'] ?? 'User'} deleted successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        print('✅ User deleted successfully: ${user['name']}');
      } catch (e) {
        print('❌ Error deleting user: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete user: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }
}

// ✅ NEW: Add User Dialog Widget
class AddUserDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onUserAdded;

  const AddUserDialog({
    super.key,
    required this.onUserAdded,
  });

  @override
  State<AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  String _selectedRole = 'user';
  String _selectedPlatform = 'mobile';
  String _selectedAuthProvider = 'email';
  bool _isActive = true;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _addUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // ✅ FIX: Actually add user to Firestore
      final newUserData = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'role': _selectedRole,
        'platform': _selectedPlatform,
        'authProvider': _selectedAuthProvider,
        'isActive': _isActive,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': null,
        'profileImage': null,
        'profileCompleted': false,
      };

      // Add to Firestore
      final docRef = await FirebaseFirestore.instance
          .collection('users')
          .add(newUserData);

      // Create user object for local state
      final newUser = {
        'id': docRef.id,
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'role': _selectedRole,
        'platform': _selectedPlatform,
        'authProvider': _selectedAuthProvider,
        'isActive': _isActive,
        'createdAt': DateTime.now(),
        'lastLogin': null,
        'profileImage': null,
      };

      widget.onUserAdded(newUser);
      Navigator.of(context).pop();

      print('✅ User added successfully: ${newUser['name']}');
    } catch (e) {
      print('❌ Error adding user: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add user: ${e.toString()}'),
          backgroundColor: Colors.red,
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
    final isMobile = ResponsiveHelper.isMobile(context);
    
    return AlertDialog(
      backgroundColor: ModernConstants.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: ModernConstants.primaryGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.person_add_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Add New User',
            style: TextStyle(
              color: ModernConstants.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Container(
        width: isMobile ? double.maxFinite : 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Name Field
                _buildFormField(
                  controller: _nameController,
                  label: 'Full Name',
                  icon: Icons.person_rounded,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a name';
                    }
                    if (value.trim().length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Email Field
                _buildFormField(
                  controller: _emailController,
                  label: 'Email Address',
                  icon: Icons.email_rounded,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter an email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Password Field
                _buildFormField(
                  controller: _passwordController,
                  label: 'Password',
                  icon: Icons.lock_rounded,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                      color: ModernConstants.textSecondary,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Role Dropdown
                _buildDropdownField(
                  label: 'Role',
                  icon: Icons.admin_panel_settings_rounded,
                  value: _selectedRole,
                  items: const [
                    DropdownMenuItem(value: 'user', child: Text('User')),
                    DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value!;
                    });
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Platform Dropdown
                _buildDropdownField(
                  label: 'Platform',
                  icon: Icons.devices_rounded,
                  value: _selectedPlatform,
                  items: const [
                    DropdownMenuItem(value: 'mobile', child: Text('Mobile')),
                    DropdownMenuItem(value: 'web', child: Text('Web')),
                    DropdownMenuItem(value: 'desktop', child: Text('Desktop')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedPlatform = value!;
                    });
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Auth Provider Dropdown
                _buildDropdownField(
                  label: 'Auth Provider',
                  icon: Icons.security_rounded,
                  value: _selectedAuthProvider,
                  items: const [
                    DropdownMenuItem(value: 'email', child: Text('Email')),
                    DropdownMenuItem(value: 'google', child: Text('Google')),
                    DropdownMenuItem(value: 'facebook', child: Text('Facebook')),
                    DropdownMenuItem(value: 'apple', child: Text('Apple')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedAuthProvider = value!;
                    });
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Active Status Switch
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ModernConstants.textTertiary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: ModernConstants.textTertiary.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (_isActive ? Colors.green : Colors.grey).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.toggle_on_rounded,
                          color: _isActive ? Colors.green : Colors.grey,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Account Status',
                              style: TextStyle(
                                color: ModernConstants.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _isActive ? 'Active' : 'Inactive',
                              style: const TextStyle(
                                color: ModernConstants.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _isActive,
                        onChanged: (value) {
                          setState(() {
                            _isActive = value;
                          });
                        },
                        activeColor: Colors.green,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text(
            'Cancel',
            style: TextStyle(color: ModernConstants.textSecondary),
          ),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _addUser,
          style: ElevatedButton.styleFrom(
            backgroundColor: ModernConstants.primaryBlue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Add User'),
        ),
      ],
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: ModernConstants.textTertiary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: ModernConstants.textTertiary.withOpacity(0.2),
        ),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: ModernConstants.primaryBlue),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          labelStyle: TextStyle(color: ModernConstants.textSecondary),
        ),
        style: const TextStyle(color: ModernConstants.textPrimary),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ModernConstants.textTertiary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: ModernConstants.textTertiary.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ModernConstants.primaryBlue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              color: ModernConstants.primaryBlue,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: ModernConstants.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                DropdownButton<String>(
                  value: value,
                  items: items,
                  onChanged: onChanged,
                  isExpanded: true,
                  underline: const SizedBox(),
                  dropdownColor: ModernConstants.cardBackground,
                  style: const TextStyle(
                    color: ModernConstants.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
