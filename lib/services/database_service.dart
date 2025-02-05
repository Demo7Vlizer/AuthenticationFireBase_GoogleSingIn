import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class DatabaseService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addUser(String userId, Map<String, dynamic> userData) async {
    try {
      print('Adding user to database: $userId'); // Debug print
      
      // First, check if user exists
      final userDoc = await _firestore.collection('users').doc(userId).get();
      
      if (!userDoc.exists) {
        print('New user - creating document'); // Debug print
        final userCount = await _getUserCount();
        userData.addAll({
          'createdAt': FieldValue.serverTimestamp(),
          'userNumber': userCount + 1,
          'loginCount': 1,
          'lastSignIn': FieldValue.serverTimestamp(),
        });
      } else {
        print('Existing user - updating document'); // Debug print
        userData['lastSignIn'] = FieldValue.serverTimestamp();
        userData['loginCount'] = FieldValue.increment(1);
      }

      // Save user data
      await _firestore.collection('users').doc(userId).set(
        userData,
        SetOptions(merge: true),
      );
      print('User data saved successfully'); // Debug print

      // Add to log
      await _firestore.collection('userLog').add({
        'userId': userId,
        'action': 'login',
        'timestamp': FieldValue.serverTimestamp(),
        'userDetails': {
          'email': userData['email'],
          'name': userData['name'],
          'provider': userData['provider'],
        },
      });
      print('Login log created'); // Debug print
    } catch (e) {
      print('Error in addUser: $e'); // Debug print
      throw e;
    }
  }

  Future<int> _getUserCount() async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection('users').get();
      return snapshot.size;
    } catch (e) {
      print('Error getting user count: $e');
      return 0;
    }
  }

  Future<void> updateUserLoginTime(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      
      if (userDoc.exists) {
        await _firestore.collection('users').doc(userId).update({
          'lastLogin': FieldValue.serverTimestamp(),
          'loginCount': FieldValue.increment(1),
        });
      }
    } catch (e) {
      print('Error updating user login time: $e');
    }
  }

  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.data();
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }
} 