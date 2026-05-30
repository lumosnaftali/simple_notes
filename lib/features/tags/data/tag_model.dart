class Tag {
  final String id;
  final String name;
  final String colorHex; // Store as hex string, e.g. '#FF3F51B5'

  const Tag({
    required this.id,
    required this.name,
    required this.colorHex,
  });

  Tag copyWith({
    String? id,
    String? name,
    String? colorHex,
  }) {
    return Tag(
      id: id ?? this.id,
      name: name ?? this.name,
      colorHex: colorHex ?? this.colorHex,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'colorHex': colorHex,
    };
  }

  factory Tag.fromJson(Map<dynamic, dynamic> json) {
    return Tag(
      id: json['id'] as String,
      name: json['name'] as String,
      colorHex: json['colorHex'] as String,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tag &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          colorHex == other.colorHex;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ colorHex.hashCode;

  @override
  String toString() => 'Tag(id: $id, name: $name, colorHex: $colorHex)';
}
