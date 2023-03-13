import 'package:document_saver_app/models/file_card.dart';
import 'package:document_saver_app/routes/routes.dart';
import 'package:document_saver_app/screens/home/widgets/file_card.dart';
import 'package:document_saver_app/screens/home/widgets/home_app_bar.dart';
import 'package:document_saver_app/widgets/custom_floating_action_button.dart';
import 'package:document_saver_app/widgets/gradient_background.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? searchValue;

  getStream() {
    return FirebaseDatabase.instance
        .ref()
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child("files_info")
        .orderByChild("title")
        .startAt(searchValue)
        .endAt("$searchValue\uf8ff")
        .onValue;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: HomeAppBar(
          onSearch: (value) {
            setState(() {
              searchValue = value;
            });
          },
        ),
        floatingActionButton: CustomFloatingActionButton(
          onTap: () {
            Navigator.pushNamed(context, addDocumentPageRoute);
          },
          icon: Icons.add,
          label: 'Add File',
        ),
        body: GradientBackground(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: StreamBuilder<DatabaseEvent>(
              stream: getStream(),
              builder: (context, snapshot) {
                List<FileCardModel> list = [];
                if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                  (snapshot.data!.snapshot.value as Map<dynamic, dynamic>)
                      .forEach(
                    (key, e) => list.add(
                      FileCardModel.fromJson(e, key),
                    ),
                  );
                  return ListView(
                      children: list
                          .map(
                            (e) => FileCard(
                              fileCard: FileCardModel(
                                id: e.id,
                                title: e.title,
                                description: e.description,
                                dateAdded: e.dateAdded,
                                fileName: e.fileName,
                                fileType: e.fileType,
                                fileUrl: e.fileUrl,
                              ),
                            ),
                          )
                          .toList());
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        "lib/assets/empty.png",
                        height: 100,
                      ),
                      const Text("No Files found",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w600)),
                      const SizedBox(
                        height: 100,
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
