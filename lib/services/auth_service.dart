import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Centralized authentication and database service for SmartEye.
class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  // ─────────────────────────────────────────────────────────────
  // BLIND USER SIGN UP
  // Registers a blind user, inserts profile, generates a unique
  // Blind ID, and emails it to the caretaker's email address.
  // ─────────────────────────────────────────────────────────────
  Future<String> signUpBlindUser({
    required String email,
    required String password,
    required String fullName,
    required int age,
    required String bloodGroup,
    required String caretakerEmail,
  }) async {
    // 1. Register user with Supabase Auth
    final authResponse = await _client.auth.signUp(
      email: email,
      password: password,
    );

    final user = authResponse.user;
    if (user == null) {
      throw Exception('Sign-up failed. Please try again.');
    }

    // 2. Generate a unique Blind ID (8-char alphanumeric)
    final blindId = _generateUniqueId(user.id);

    // 3. Insert into profiles table (for role-based routing)
    await _client.from('profiles').insert({
      'id': user.id,
      'role': 'blind',
      'email': email,
    });

    // 4. Insert into blind_users table
    await _client.from('blind_users').insert({
      'id': user.id,
      'full_name': fullName,
      'age': age,
      'blood_group': bloodGroup,
      'caretaker_email': caretakerEmail,
      'blind_unique_id': blindId,
    });

    // 5. Insert into blind_unique_ids table (for caretaker verification)
    await _client.from('blind_unique_ids').insert({
      'blind_user_id': user.id,
      'unique_id': blindId,
      'caretaker_email': caretakerEmail,
      'is_claimed': false,
    });

    // 6. Send the Blind ID to the caretaker's email via Edge Function
    try {
      await _client.functions.invoke(
        'send-blind-id-email',
        body: {
          'caretaker_email': caretakerEmail,
          'blind_id': blindId,
          'blind_user_name': fullName,
        },
      );
    } catch (e) {
      // Edge Function may not be deployed yet — fail gracefully.
      // The ID is still stored in the DB and shown in-app.
      debugPrint('[AuthService] Edge Function not available: $e');
    }

    // 7. Log activity
    await _logActivity(
      userId: user.id,
      action: 'blind_signup',
      details: 'Blind ID generated and emailed to $caretakerEmail',
    );

    return blindId;
  }

  // ─────────────────────────────────────────────────────────────
  // CARETAKER SIGN UP
  // Verifies the Blind ID exists, then registers the caretaker
  // and links them to the blind user.
  // ─────────────────────────────────────────────────────────────
  Future<void> signUpCaretakerUser({
    required String email,
    required String password,
    required String blindUniqueId,
  }) async {
    // 1. Verify Blind ID exists and is unclaimed
    final idCheck = await _client
        .from('blind_unique_ids')
        .select('blind_user_id, is_claimed')
        .eq('unique_id', blindUniqueId)
        .maybeSingle();

    if (idCheck == null) {
      throw Exception(
          'Invalid Blind ID. Please check the ID sent to your caretaker email.');
    }

    if (idCheck['is_claimed'] == true) {
      throw Exception(
          'This Blind ID has already been claimed by another caretaker.');
    }

    final linkedBlindUserId = idCheck['blind_user_id'] as String;

    // 2. Register caretaker with Supabase Auth
    final authResponse = await _client.auth.signUp(
      email: email,
      password: password,
    );

    final user = authResponse.user;
    if (user == null) {
      throw Exception('Sign-up failed. Please try again.');
    }

    // 3. Insert into profiles table
    await _client.from('profiles').insert({
      'id': user.id,
      'role': 'caretaker',
      'email': email,
    });

    // 4. Insert into caretaker_users table
    await _client.from('caretaker_users').insert({
      'id': user.id,
      'linked_blind_user_id': linkedBlindUserId,
      'blind_unique_id': blindUniqueId,
      'email': email,
    });

    // 5. Mark Blind ID as claimed
    await _client
        .from('blind_unique_ids')
        .update({'is_claimed': true})
        .eq('unique_id', blindUniqueId);

    // 6. Log activity
    await _logActivity(
      userId: user.id,
      action: 'caretaker_signup',
      details: 'Linked to blind user: $linkedBlindUserId',
    );
  }

  // ─────────────────────────────────────────────────────────────
  // SIGN IN (both roles)
  // ─────────────────────────────────────────────────────────────
  Future<Session> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.session == null) {
      throw Exception('Sign-in failed. Check your email and password.');
    }

    await _logActivity(
      userId: response.user!.id,
      action: 'sign_in',
      details: 'User signed in successfully',
    );

    return response.session!;
  }

  // ─────────────────────────────────────────────────────────────
  // GET USER ROLE
  // Fetches the role of the currently logged-in user.
  // ─────────────────────────────────────────────────────────────
  Future<String?> getUserRole(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select('role')
          .eq('id', userId)
          .single();
      return response['role'] as String?;
    } catch (e) {
      debugPrint('[AuthService] getUserRole error: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // SIGN OUT
  // ─────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    final user = _client.auth.currentUser;
    if (user != null) {
      await _logActivity(
        userId: user.id,
        action: 'sign_out',
        details: 'User signed out',
      );
    }
    await _client.auth.signOut();
  }

  // ─────────────────────────────────────────────────────────────
  // PRIVATE: Generate Local Unique ID
  // Creates an 8-character alphanumeric ID derived from the
  // user's UUID as a fallback / primary ID.
  // ─────────────────────────────────────────────────────────────
  String _generateUniqueId(String userId) {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final seed = userId.replaceAll('-', '');
    final buffer = StringBuffer('SE-');
    for (int i = 0; i < 6; i++) {
      final index = seed.codeUnitAt(i % seed.length) % chars.length;
      buffer.write(chars[index]);
    }
    return buffer.toString();
  }

  // ─────────────────────────────────────────────────────────────
  // PRIVATE: Log Activity
  // Writes an audit entry to the activity_logs table.
  // ─────────────────────────────────────────────────────────────
  Future<void> _logActivity({
    required String userId,
    required String action,
    required String details,
  }) async {
    try {
      await _client.from('activity_logs').insert({
        'user_id': userId,
        'action': action,
        'details': details,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Non-critical — don't throw, just log
      debugPrint('[AuthService] _logActivity error: $e');
    }
  }
}

/// Global instance for use across the app
final authService = AuthService();
