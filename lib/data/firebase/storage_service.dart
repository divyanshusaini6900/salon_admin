import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class AdminStorageService {
  AdminStorageService(this._storage);

  final FirebaseStorage _storage;

  Future<String> uploadServiceImage({required String serviceId, required File file}) async {
    final ref = _storage.ref('salon_assets/services/$serviceId.jpg');
    final task = await ref.putFile(file);
    return task.ref.getDownloadURL();
  }
}
