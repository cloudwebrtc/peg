library peg.utils.utils;

part 'src/utils/utils.dart';

Map<dynamic, TextSaver> textlists = {};

class TextSaver {
  TextSaver(this.text, this.ignoreCase);
  String text;

  void setText(String t) {
    text = t;
  }

  bool ignoreCase;

  void setIgnoreCase(bool i) {
    ignoreCase = i;
  }
}
