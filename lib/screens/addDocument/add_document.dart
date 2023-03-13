import 'dart:io';

import 'package:document_saver_app/utils/helpers/snack_bar.dart';
import 'package:document_saver_app/widgets/custom_floating_action_button.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class AddDocument extends StatefulWidget {
  const AddDocument({super.key});

  @override
  State<AddDocument> createState() => _AddDocumentState();
}

class _AddDocumentState extends State<AddDocument> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final FirebaseDatabase _firebaseDatabase = FirebaseDatabase.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  PlatformFile? _selectedFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.all(65.0),
          child: Text("Add Document"),
        ),
      ),
      floatingActionButton: CustomFloatingActionButton(
        onTap: () async {
          if (_formKey.currentState!.validate()) {
            try {
              TaskSnapshot snapshot = await _firebaseStorage
                  .ref()
                  .child(FirebaseAuth.instance.currentUser!.uid)
                  .child("files")
                  .child(_selectedFile!.name)
                  .putFile(File(_selectedFile!.path!));
              String fileUrl = await snapshot.ref.getDownloadURL();
              await _firebaseDatabase
                  .ref()
                  .child(FirebaseAuth.instance.currentUser!.uid)
                  .child("files_info")
                  .push()
                  .set(
                    ({
                      "title": titleController.text,
                      "description": descriptionController.text,
                      "fileUrl": fileUrl,
                      "dateAdded": DateTime.now().toString(),
                      "fileName": _selectedFile!.name,
                      "fileType": _selectedFile!.name.split(".")[1],
                    }),
                  )
                  .then((value) {
                SnackBarHelper.showSuccessMessage(
                    context: context, message: "File uploaded successfully");
                Navigator.pop(context);
              });
            } on FirebaseException catch (e) {
              SnackBarHelper.showErrorMessage(
                  context: context, message: e.message);
            }
          }
        },
        icon: Icons.check,
        label: 'Upload File',
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                validator: (String? value) {
                  if (value!.isEmpty) {
                    return "Please enter your file name";
                  }
                  return null;
                },
                controller: titleController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter the file name",
                  label: Text("File name"),
                  prefixIcon: Icon(Icons.title),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter the file description",
                  label: Text("File description"),
                  prefixIcon: Icon(Icons.title),
                ),
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: () async {
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles();
                  if (result != null) {
                    setState(
                      () {
                        _selectedFile = result.files.first;
                      },
                    );
                  }
                },
                child: DottedBorder(
                  dashPattern: const [6, 4],
                  strokeWidth: 2,
                  radius: const Radius.circular(100),
                  padding: const EdgeInsets.all(30),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      children: [
                        Image.asset(
                          "lib/assets/upload.png",
                          height: 100,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Browse files",
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w500),
                        ),
                        if (_selectedFile != null) ...[
                          Text(_selectedFile!.name)
                        ]
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
