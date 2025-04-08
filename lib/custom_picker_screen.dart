// custom_picker_screen.dart

import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'providers.dart';

class CustomImagePickerScreen extends ConsumerStatefulWidget {
  const CustomImagePickerScreen({super.key});

  @override
  ConsumerState<CustomImagePickerScreen> createState() =>
      _CustomImagePickerScreenState();
}

class _CustomImagePickerScreenState
    extends ConsumerState<CustomImagePickerScreen> {
  List<AssetEntity> galleryImages = [];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadGallery();
  }

  Future<void> _loadGallery() async {
    final permission = await PhotoManager.requestPermissionExtend();

    if (!permission.hasAccess) {
      PhotoManager.openSetting(); // 설정 화면으로 유도
      return;
    }

    final albums = await PhotoManager.getAssetPathList(type: RequestType.image);
    final recentAlbum = albums.first;

    final assets = await recentAlbum.getAssetListPaged(page: 0, size: 100);
    setState(() {
      galleryImages = assets;
    });
  }

  void _onImageTap(AssetEntity image) {
    final selected = ref.read(selectedImagesProvider);
    final newList = [...selected];

    if (newList.contains(image)) {
      newList.remove(image);
    } else {
      newList.add(image);
    }

    ref.read(selectedImagesProvider.notifier).state = newList;
  }

  @override
  Widget build(BuildContext context) {
    final selectedImages = ref.watch(selectedImagesProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("이미지 선택"),
        actions: [
          TextButton(
            onPressed: () async {
              setState(() => isLoading = true);
              Future.delayed(const Duration(milliseconds: 500));
              final selectedAssets = ref.read(selectedImagesProvider);

              final List<Uint8List> result = [];

              for (final entity in selectedAssets) {
                final bytes = await entity.originBytes;
                if (bytes != null) {
                  result.add(bytes);
                }
              }

              if (context.mounted) {
                Navigator.of(context).pop(result);
              }

              setState(() => isLoading = false);
            },
            child: const Text("확인", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
      body: Stack(
        children: [
          GridView.builder(
            itemCount: galleryImages.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
            ),
            itemBuilder: (_, index) {
              final image = galleryImages[index];
              final selectedIndex = selectedImages.indexOf(image);
              return GestureDetector(
                onTap: () => _onImageTap(image),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: AssetEntityImage(
                        image,
                        fit: BoxFit.cover,
                        isOriginal: false,
                      ),
                    ),
                    if (selectedIndex != -1)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.black87,
                          child: Text(
                            "${selectedIndex + 1}",
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),

          if (isLoading)
            LayoutBuilder(builder: (context, constraints) {
              return Container(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                color: Colors.black54,
                child: const Center(
                  child: Text('사진 불러오는 중...',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              );
            }),
        ],
      ),
    );
  }
}
