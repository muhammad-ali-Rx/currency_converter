import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // ✅ ADD: For date formatting
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
    return Padding(
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
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadUsers,
          tooltip: 'Reload users',
        ),
      ],
    );
  }

  Widget _buildMobileFilters() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Search by name or email',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
          ),
        ),
        const SizedBox(width: 8),
        DropdownButton<String>(
          value: selectedFilter,
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
      ],
    );
  }

  Widget _buildDesktopFilters() {
    return Row(
      children: [
        SizedBox(
          width: 300,
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Search by name or email',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
          ),
        ),
        const SizedBox(width: 16),
        DropdownButton<String>(
          value: selectedFilter,
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
      ],
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
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Email')),
            DataColumn(label: Text('Role')),
            DataColumn(label: Text('Created')), // ✅ NEW: Added Created column
            DataColumn(label: Text('Active')),
            DataColumn(label: Text('Actions')),
          ],
          rows: filteredUsers.map((user) {
            final isAdmin = (user['role'] ?? 'user').toString().toLowerCase() == 'admin';
            return DataRow(
              cells: [
                DataCell(Row(
                  children: [
                    _buildUserAvatar(user, radius: 16),
                    const SizedBox(width: 8),
                    Text(user['name']?.toString() ?? 'Unknown User'),
                  ],
                )),
                DataCell(Text(user['email']?.toString() ?? 'No email')),
                DataCell(Text((user['role'] ?? 'user').toString())),
                // ✅ NEW: Show formatted creation date
                DataCell(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _formatTimestamp(user['createdAt']),
                        style: const TextStyle(fontSize: 12),
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
      );
    }
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
        content: Text(
          'Are you sure you want to delete ${user['name'] ?? 'this user'}? This action cannot be undone.',
          style: const TextStyle(color: ModernConstants.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        users.removeWhere((u) => u['id'] == user['id']);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${user['name'] ?? 'User'} deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}