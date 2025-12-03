class CustomItem {
  final String name;
  final String imagePath;

  CustomItem({
    required this.name,
    required this.imagePath,
  });

  Map<String, dynamic> toJson() => {
    "name": name,
    "imagePath": imagePath,
  };

  factory CustomItem.fromJson(Map<String, dynamic> json) => CustomItem(
    name: json["name"],
    imagePath: json["imagePath"],
  );
}