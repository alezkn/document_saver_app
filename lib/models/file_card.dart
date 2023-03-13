class FileCardModel {
  final String id;
  final String title;
  final String description;
  final String dateAdded;
  final String fileName;
  final String fileType;
  final String fileUrl;

  FileCardModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dateAdded,
    required this.fileName,
    required this.fileType,
    required this.fileUrl,
  });

  factory FileCardModel.fromJson(Map<dynamic, dynamic> json, String id) {
    return FileCardModel(
      id: id,
      title: json["title"].toString(),
      description: json["description"].toString(),
      dateAdded: json["dateAdded"].toString(),
      fileName: json["fileName"].toString(),
      fileType: json["fileType"].toString(),
      fileUrl: json["fileUrl"].toString(),
    );
  }
}
