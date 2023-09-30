import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evalution/ui/firestore/add_firestore_data.dart';
import 'package:evalution/ui/upload_image.dart';
import 'package:flutter/material.dart';
import 'package:evalution/ui/auth/login_screen.dart';
import 'package:evalution/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';

class FireStoreScreen extends StatefulWidget {
  const FireStoreScreen({Key? key}) : super(key: key);

  @override
  State<FireStoreScreen> createState() => _FireStoreScreenState();
}

class _FireStoreScreenState extends State<FireStoreScreen> {
  final auth = FirebaseAuth.instance;
  final editController = TextEditingController();
  final CollectionReference ref =
      FirebaseFirestore.instance.collection('users');
  File? _image;
  final picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text('FireStore'),
        actions: [
          IconButton(
            onPressed: () {
              auth.signOut().then((value) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                );
              }).catchError((error) {
                Utils().toastMessage(error.toString());
              });
            },
            icon: const Icon(Icons.logout),
          ),
          const SizedBox(
            width: 10,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddFireStoreDataScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          StreamBuilder<QuerySnapshot>(
            stream: ref.snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(child: Text('Some Error'));
              }
              return Expanded(
                child: ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var docData = snapshot.data!.docs[index].data()
                        as Map<String, dynamic>;
                    return ListTile(
                      leading: InkWell(
                        onTap: () async {
                          final selectedImage = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UploadImageScreen(
                                onImageSelected: (image) {
                                  setState(() {
                                    _image = image;
                                  });
                                },
                              ),
                            ),
                          );

                          if (selectedImage != null) {
                            setState(() {
                              _image = selectedImage;
                            });
                          }
                        },
                        child: CircleAvatar(
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
                                  child: Icon(Icons.add_a_photo_outlined),
                                ),
                        ),
                      ),
                      title: Text(docData['title'].toString()),
                      subtitle: Text(docData['id'].toString()),
                      trailing: PopupMenuButton(
                        icon: const Icon(Icons.more_vert),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 1,
                            child: ListTile(
                              onTap: () {
                                Navigator.pop(context);
                                showMyDialog(
                                    docData['title'], docData['id'].toString());
                              },
                              title: const Text('Edit'),
                              leading: const Icon(Icons.edit),
                            ),
                          ),
                          PopupMenuItem(
                            value: 2,
                            child: ListTile(
                              onTap: () {
                                Navigator.pop(context);
                                showMyDialogForDelete(docData['id'].toString());
                              },
                              title: const Text('Delete'),
                              leading: const Icon(Icons.delete),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> showMyDialog(String title, String id) async {
    editController.text = title;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update'),
          content: Container(
            child: TextField(
              controller: editController,
              decoration: const InputDecoration(hintText: 'Edit here'),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Update logic here
                ref
                    .doc(id)
                    .update({'title': editController.text}).then((value) {
                  Utils().toastMessage('Updated');
                  Navigator.pop(context);
                }).catchError((error) {
                  Utils().toastMessage(error.toString());
                });
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Future<void> showMyDialogForDelete(String id) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete'),
          content: const Text('Do you really want to delete this post?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Delete logic here
                ref.doc(id).delete().then((value) {
                  Utils().toastMessage('Deleted');
                  Navigator.pop(context);
                }).catchError((error) {
                  Utils().toastMessage(error.toString());
                });
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
