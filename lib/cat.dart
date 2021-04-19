class Cats {
  String name;
  String icon;

  Cats({this.name, this.icon});

  Cats.fromMap(Map<String, dynamic> map) {
    name = map['name'];
    icon = map['icon'];
  }
}