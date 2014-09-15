part of peg.parser_generator;

class GeneralParserGenerator extends TemplateGenerator {
  static const int LOOKAHEAD_CHAR_COUNT = 0;

  static const String _TEMPLATE = 'TEMPLATE';

  static final String _template = '''
// This code was generated by a tool.
// Processing tool available at https://github.com/mezoni/peg

{{#GLOBALS}}
{{#PARSER}}
''';

  final bool comment;

  final Grammar grammar;

  final bool lookahead;

  final bool memoize;

  final String name;

  final bool trace;

  GeneralParserClassGenerator _parserClassGenerator;

  GeneralParserGenerator(this.name, this.grammar, {this.comment: false, this.lookahead: false, this.memoize: false, this.trace: false}) {
    if (name == null || name.isEmpty) {
      throw new ArgumentError('name: $name');
    }

    if (grammar == null) {
      throw new ArgumentError('grammar: $grammar');
    }

    if (comment == null) {
      throw new ArgumentError('comments: $comment');
    }

    if (lookahead == null) {
      throw new ArgumentError('lookahead: $lookahead');
    }

    if (memoize == null) {
      throw new ArgumentError('memoize: $memoize');
    }

    addTemplate(_TEMPLATE, _template);
    _parserClassGenerator = new GeneralParserClassGenerator(name, grammar, this);
  }

  GeneralParserClassGenerator get parserClassGenerator {
    return _parserClassGenerator;
  }

  List<String> generate() {
    var block = getTemplateBlock(_TEMPLATE);
    block.assign('#GLOBALS', Utils.codeToStrings(grammar.globals));
    block.assign('#PARSER', _parserClassGenerator.generate());
    return block.process();
  }
}