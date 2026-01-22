import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class UserData {
  final String id;
  final String name;

  const UserData({
    required this.id,
    required this.name,
  });

  UserData copyWith({String? id, String? name}) {
    return UserData(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }
}

class UserNotifier extends Notifier<UserData?> {
  static const _keyUserId = 'user_id';
  static const _keyUserName = 'user_name';

  @override
  UserData? build() {
    return null;
  }

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_keyUserId);
    final userName = prefs.getString(_keyUserName);

    if (userId != null && userName != null) {
      state = UserData(id: userId, name: userName);
    }
  }

  Future<void> saveUser(String name) async {
    final prefs = await SharedPreferences.getInstance();

    String? userId = prefs.getString(_keyUserId);
    if (userId == null) {
      userId = const Uuid().v4();
      await prefs.setString(_keyUserId, userId);
    }

    await prefs.setString(_keyUserName, name);
    state = UserData(id: userId, name: name);
  }

  Future<void> updateUserName(String name) async {
    if (state == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserName, name);
    state = state!.copyWith(name: name);
  }

  bool get isLoggedIn => state != null;
}

final userProvider = NotifierProvider<UserNotifier, UserData?>(() {
  return UserNotifier();
});

final isUserLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(userProvider) != null;
});
