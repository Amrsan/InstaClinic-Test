import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';


class ProfileController extends GetxController {

  final _supabase = Supabase.instance.client;
  final isLogin = false.obs;
  
  final firstName = ''.obs;
  final lastName = ''.obs;
  final email = ''.obs;
  final phoneNumber = ''.obs;
  final birthDate = ''.obs;
  final gender = ''.obs;
  final avatarUrl = ''.obs;
  final addresses = <Map<String, dynamic>>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    fetchUserProfile();

  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      
      // Clear all profile data
      firstName.value = '';
      lastName.value = '';
      email.value = '';
      phoneNumber.value = '';
      birthDate.value = '';
      gender.value = '';
      avatarUrl.value = '';
      addresses.clear();
      isLogin.value = false;
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  Future<void> fetchUserProfile() async {
    try {
      print('Fetching user profile...');
      // Get either Supabase or Firebase user
      final supabaseUser = _supabase.auth.currentUser;
      print('Current user: ${supabaseUser?.id}');

      if(supabaseUser!=null){isLogin.value=true;}
    //  final firebaseUser = _authController.firebaseAuth.currentUser;

      if (supabaseUser != null) {
        // Prepare the query based on which auth system is being used
        final query = _supabase.from('users').select();
        
        // If Supabase user exists, query by ID
        print('Querying user with ID: ${supabaseUser.id}');
        final response = await query
            .eq('id', supabaseUser.id)
            .single();
        print('User response: $response');

        print('Setting user data...');
        firstName.value = response['first_name'] ?? '';
        lastName.value = response['last_name'] ?? '';
        email.value = response['email'] ?? '';
        phoneNumber.value = response['phone_number'] ?? '';
        birthDate.value = _formatDate(response['birth_date'] ?? '');
        gender.value = response['gender'] ?? '';
        avatarUrl.value = response['avatar_url'] ?? '';
        
        print('User data set: ${firstName.value} ${lastName.value}');

        // Fetch user addresses using the Supabase record ID
        print('Fetching addresses...');
        final addressesResponse = await _supabase
            .from('addresses')
            .select()
              .eq('user_id', response['id'])
            .order('created_at', ascending: false);
            
        addresses.value = List<Map<String, dynamic>>.from(addressesResponse);
        print('Addresses fetched: ${addresses.length}');
      } else {
        print('No authenticated user found');
      }
    } catch (e) {
      print('Error fetching profile: $e');
    }
  }

  String _formatDate(String date) {
    if (date.isEmpty) return '';
    try {
      DateTime dateTime;
      // Try parsing as ISO format first
      try {
        dateTime = DateTime.parse(date);
      } catch (e) {
        // If ISO parsing fails, try dd-MM-yyyy format
        dateTime = DateFormat('dd-MM-yyyy').parse(date);
      }
      // Always return in dd-MM-yyyy format
      return DateFormat('dd-MM-yyyy').format(dateTime);
    } catch (e) {
      print('Error formatting date: $date');
      return date;
    }
  }

  Future<void> updateProfile({
    String? newFirstName,
    String? newLastName,
    String? newPhoneNumber,
    String? newBirthDate,
    String? newGender,
    String? newAvatarUrl,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        final updates = {
          if (newFirstName != null) 'first_name': newFirstName,
          if (newLastName != null) 'last_name': newLastName,
          if (newPhoneNumber != null) 'phone_number': newPhoneNumber,
          if (newBirthDate != null) 'birth_date': newBirthDate,
          if (newGender != null) 'gender': newGender,
          if (newAvatarUrl != null) 'avatar_url': newAvatarUrl,
          'updated_at': DateTime.now().toIso8601String(),
        };

        await _supabase
            .from('users')
            .update(updates)
            .eq('id', user.id);

        await fetchUserProfile();
      }
    } catch (e) {
      print('Error updating profile: $e');
    }
  }

  Future<void> addAddress(Map<String, dynamic> address) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        final newAddress = {
          ...address,
          'user_id': user.id,
          'created_at': DateTime.now().toIso8601String(),
        };

        await _supabase
            .from('addresses')
            .insert(newAddress);

        await fetchUserProfile();
      }
    } catch (e) {
      print('Error adding address: $e');
    }
  }

  Future<void> updateAddress(String addressId, Map<String, dynamic> updates) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        await _supabase
            .from('addresses')
            .update({
              ...updates,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', addressId)
            .eq('user_id', user.id);

        await fetchUserProfile();
      }
    } catch (e) {
      print('Error updating address: $e');
    }
  }

  Future<void> deleteAddress(String addressId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        await _supabase
            .from('addresses')
            .delete()
            .eq('id', addressId)
            .eq('user_id', user.id);

        await fetchUserProfile();
      }
    } catch (e) {
      print('Error deleting address: $e');
    }
  }

  String? getCurrentUserId() {
    return _supabase.auth.currentUser?.id;
  }

  bool get isLoggedIn => _supabase.auth.currentUser != null;
}