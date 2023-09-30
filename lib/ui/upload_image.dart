import 'dart:io';

import 'package:evalution/utils/utils.dart';
import 'package:evalution/widgets/round_button.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class UploadImageScreen extends StatefulWidget {
  final Function(File?) onImageSelected;
  final File? initialImage;

  const UploadImageScreen(
      {Key? key, required this.onImageSelected, this.initialImage})
      : super(key: key);

  @override
  State<UploadImageScreen> createState() => _UploadImageScreenState();
}

class _UploadImageScreenState extends State<UploadImageScreen> {
  bool loading = false;
  File? _image;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _image = widget.initialImage;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Image to Firebase Storage'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: InkWell(
                onTap: () {
                  getGalleryImage();
                },
                child: Container(
                  height: 200,
                  width: 200,
                  decoration:
                      BoxDecoration(border: Border.all(color: Colors.black)),
                  child: _image != null
                      ? ClipOval(
                          child: Image.file(
                            _image!,
                            fit: BoxFit.cover,
                            width: 200,
                            height: 200,
                          ),
                        )
                      : const Center(
                          child: Icon(Icons.image),
                        ),
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            RoundButton(
              title: 'Upload',
              loading: loading,
              onTap: () async {
                setState(() {
                  loading = true;
                });
                String id = DateTime.now().microsecondsSinceEpoch.toString();
                firebase_storage.Reference ref = firebase_storage
                    .FirebaseStorage.instance
                    .ref('/azixkhan/$id');
                firebase_storage.UploadTask uploadTask = ref.putFile(_image!);

                try {
                  await uploadTask.whenComplete(() async {
                    // var newUrl = await ref.getDownloadURL();
                    Utils().toastMessage('Image Uploaded');

                    // Pass the selected image back to FireStoreScreen
                    Navigator.pop(context, _image);
                  });
                } catch (error) {
                  print(error.toString());
                  Utils().toastMessage(error.toString());
                } finally {
                  setState(() {
                    loading = false;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getGalleryImage() async {
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No Image Picked');
      }
    });
  }
}
