import 'dart:convert';
import 'dart:developer';

import 'package:anonaddy/global_providers.dart';
import 'package:anonaddy/models/recipient/recipient.dart';
import 'package:anonaddy/shared_components/constants/url_strings.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final recipientService = Provider<RecipientService>((ref) {
  return RecipientService(dio: ref.read(dioProvider));
});

class RecipientService {
  const RecipientService({required this.dio});
  final Dio dio;

  Future<List<Recipient>> getRecipients() async {
    try {
      const path = '$kUnEncodedBaseURL/$kRecipientsURL';
      final response = await dio.get(path);
      log('getRecipients: ${response.statusCode}');
      final recipients = response.data['data'] as List;
      return recipients
          .map((recipient) => Recipient.fromJson(recipient))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Recipient> getSpecificRecipient(String recipientId) async {
    try {
      final path = '$kUnEncodedBaseURL/$kRecipientsURL/$recipientId';
      final response = await dio.get(path);
      log('getSpecificRecipient: ${response.statusCode}');
      final recipient = response.data['data'];
      return Recipient.fromJson(recipient);
    } catch (e) {
      rethrow;
    }
  }

  Future<Recipient> enableEncryption(String recipientID) async {
    try {
      const path = '$kUnEncodedBaseURL/$kEncryptedRecipient';
      final data = json.encode({"id": recipientID});
      final response = await dio.post(path, data: data);
      log('enableEncryption: ${response.statusCode}');
      final recipient = response.data['data'];
      return Recipient.fromJson(recipient);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> disableEncryption(String recipientID) async {
    try {
      final path = '$kUnEncodedBaseURL/$kEncryptedRecipient/$recipientID';
      final response = await dio.delete(path);
      log('disableEncryption: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  Future<Recipient> addPublicGPGKey(String recipientID, String keyData) async {
    try {
      final path = '$kUnEncodedBaseURL/$kRecipientKeys/$recipientID';
      final data = jsonEncode({"key_data": keyData});
      final response = await dio.patch(path, data: data);
      log('addPublicGPGKey: ${response.statusCode}');
      final recipient = response.data['data'];
      return Recipient.fromJson(recipient);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removePublicGPGKey(String recipientID) async {
    try {
      final path = '$kUnEncodedBaseURL/$kRecipientKeys/$recipientID';
      final response = await dio.delete(path);
      log('removePublicGPGKey: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  Future<Recipient> addRecipient(String email) async {
    try {
      const path = '$kUnEncodedBaseURL/$kRecipientsURL';
      final data = jsonEncode({"email": email});
      final response = await dio.post(path, data: data);
      log('addRecipient: ${response.statusCode}');
      final recipient = response.data['data'];
      return Recipient.fromJson(recipient);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeRecipient(String recipientID) async {
    try {
      final path = '$kUnEncodedBaseURL/$kRecipientsURL/$recipientID';
      final response = await dio.delete(path);
      log('removeRecipient: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resendVerificationEmail(String recipientID) async {
    try {
      const path = '$kUnEncodedBaseURL/$kRecipientsURL/email/resend';
      final data = json.encode({"recipient_id": recipientID});
      final response = await dio.post(path, data: data);
      log('resendVerificationEmail: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }
}
