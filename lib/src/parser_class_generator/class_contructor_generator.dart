part of peg.grammar_generator;

class ClassContructorGenerator extends TemplateGenerator {
  static const String _INPUT = ParserClassGenerator.VARIABLE_INPUT;

  static const String _INPUT_LEN = ParserClassGenerator.VARIABLE_INPUT_LEN;

  static const String _RESET = MethodResetGenerator.NAME;

  static const String _RUNES = ParserClassGenerator.VARIABLE_RUNES;

  static const String _TEMPLATE = "TEMPLATE";

  static final String _template = '''
{{CLASSNAME}}(String text) {
  if (text == null) {
    throw new ArgumentError('text: \$text');
  }
  $_INPUT = text;  
  $_INPUT_LEN = $_INPUT.length;
  $_RUNES = text.runes.toList(growable: false);
  if ($_INPUT_LEN >= 0x3fffffe8 / 32) {
    throw new StateError('File size to big: \$$_INPUT_LEN');
  }  
  $_RESET(0);    
}
''';

  String name;

  ClassContructorGenerator(this.name) {
    if (name == null || name.isEmpty) {
      throw new ArgumentError("name: $name");
    }

    addTemplate(_TEMPLATE, _template);
  }

  List<String> generate() {
    var block = getTemplateBlock(_TEMPLATE);
    block.assign('CLASSNAME', name);
    return block.process();
  }
}