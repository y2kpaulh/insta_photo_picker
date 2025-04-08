import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:insta_photo_picker/providers.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

import 'custom_picker_screen.dart';

void main() {
  runApp(const ProviderScope(
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {


  Future<List<Uint8List>> pickImagesWithOrder(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CustomImagePickerScreen(),
      ),
    );

    if (result is List<Uint8List>) {
      debugPrint('Selected images: ${result.length}');
      return result;
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final galleryImages = ref.watch(selectedImagesProvider);

    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
      centerTitle: true,
      title: const Text("갤러리 이미지"),
      actions: [
        TextButton(
          onPressed: () async {
            if(context.mounted){
              // Clear the selected images before picking new ones
              // ref.read(selectedImagesProvider.notifier).state = [];

              await pickImagesWithOrder(context).then((images) {
                if (images.isNotEmpty) {
                  // Do something with the selected images

                  print('Selected images: $images');
                }
              });
            }
          },
          child: const Text("갤러리", style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
      body: Column(
        children: [
          if(galleryImages.isNotEmpty)
          Expanded(
            child: GridView.builder(
              itemCount: galleryImages.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              itemBuilder: (_, index) {
                final image = galleryImages[index];
                final selectedIndex = galleryImages.indexOf(image);
                return GestureDetector(

                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: AssetEntityImage(
                          image,
                          fit: BoxFit.cover,
                          isOriginal: false,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      )
    );
  }
}
