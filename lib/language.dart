class Languages {
  String displayText;
  String lang;

  Languages({this.displayText, this.lang});

  Languages.fromMap(Map<String, dynamic> map) {
    displayText = map['displayText'];
    lang = map['lang'];
  }
}