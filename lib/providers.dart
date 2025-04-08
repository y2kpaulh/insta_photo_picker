// providers.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';

final selectedImagesProvider = StateProvider<List<AssetEntity>>((ref) => []);

void initializeSelectedImages(WidgetRef ref, List<AssetEntity> images) {
  ref.read(selectedImagesProvider.notifier).state = images;
}