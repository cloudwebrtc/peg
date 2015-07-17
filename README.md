#peg
==========

PEG (Parsing expression grammar) parsers generator.

Version: 0.0.53

**Instalation and Usage:**

To install this program you could do it by mean of:

    pub global activate peg

To run the program you only need to do:

    pub global run peg general <file>.peg

or you can also add the `.pub-cache/bin` directory to your path and run it directly

    peg general <file>.peg

**Main advantages:**

- The generated parsers has no dependencies
- The generated parsers has high performance

The generated parsers intended for embedding into programs with the time-critical execution.

A short ["How to write a good PEG grammar"](https://github.com/mezoni/peg/tree/master/bin/how_to_write_a_good_peg_grammar.md) available.

**Features:**

- Elimination of direct left recursion (via `pegfmt` tool)
- Generation of detailed comments
- Grammar analytics
- Grammar reporting
- Grammar statistics
- High quality generated source code
- Lazy memoization (individually for each rule)
- Lookahead mapping tables
- Memoization
- Possibility to trace parsing 
- Powerful error and mistakes detection
- Printing grammar
- Symbols transitions (upcomming)
- Terminal and nonterminal symbol recognition

**Analysis of internal characteristic of grammar**

Autodetection of the following production rule kinds:

- Sentences (nonterminals)
- Lexemes (tokens)
- Morhemes

In-depth analysis of the most important characteristics of the grammar allows generate the high quality, high performance PEG parsers.  
List of expression analyzers:

- Resolver of expected lexemes
- Resolver of expressions that are able not consume input
- Resolver of expression callers
- Resolver of expression hierarchy
- Resolver of expression length
- Resolver of expression level
- Resolver of expression that are matches eof
- Resolver of expression ownership
- Resolver of expression with actions
- Resolver of invocations
- Resolver of left expressions
- Resolver of optional expressions
- Resolver of production rule kinds
- Resolver of repetition expressions
- Resolver of right expressions
- Resolver of rule expressions
- Resolver of starting rules
- Resolver of start characters

Generators used such collected data very intensively for generating the highly optimized, high performance parsers.

Also for providing statistical information used the following grammar analyzers.

- Finder of choices with optional expression
- Finder of duplicate rules
- Finder of empty expression in predicates
- Finder of infinite loops
- Finder of left recursions
- Finder of nonterminals with lexemes
- Finder of optional expression in predicates
- Finder of starting rules
- Finder of unresolved rules

**Elimination of direct left recursion (experimental)**

Grammar with direct left recursion can be rewritten with `pegfmt` tool.  
Suppored expressions:

```
# Original
A <- A a

# Rewritten
A <- a+

# Original
A <- A a / b

# Rewritten
A <- b A1
A1 <- a A1 / ''

# Original
A <- b / A a

# Rewritten
A <- b A1
A1 <- a A1 / ''
```

Limitation:

Expressions that starts with recursion should not contains actions in grammar before rewriting them.  
They (actions) should be added after rewriting grammar.

Eg.

```
# Semantic variable `$1` does not reffers to `A` after the rewriting.
# Before 
A <-
  A a { $$ = $1; # UNSAFE }
  / b { $$ = $1; # SAFE }

# After 
A <- b { $$ = $1; # SAFE } A1
A1 <- a A1 / ''
```

**Error detection**

- Infinite loops
- Left recursive rules
- Optional expression in choices

**Trace**

Trace information are useful for diagnose the problems.

Trace displayed in the following format:

column, line:state rule padding code position

Eg:

```
94, 8: F* OPEN    '-' Char { $$ = [$1, $3]; (2343)
94, 8:  > Literal '-' Char { $$ = [$1, $3]; (2343)

```

State:

Cache : Match : Direction

Cache:
 
- 'C' - Cache
- ' ' - Not cache

Match:
 
- 'F' - Failed
- ' ' - Succeed

Direction:

- '>' - Enter
- '<' - Leave
- 'S' - Skip (lookahead)

Examples:

- '  >' Enter
- '  <' Leave, success
- ' F<' Leave, failed
- 'C <' Leave, succeed, uses cached result 
- 'CF<' Leave, failed, uses cached result
- '  S' Skip (lookahead), succeed
- ' FS' Skip (lookahead), failed

**Grammar**

```
Grammar <- LEADING_SPACES? GLOBALS? MEMBERS? Definition+ EOF

Definition <- IDENTIFIER LEFTARROW Expression

Expression <- Sequence (SLASH Sequence)*

Sequence <- Prefix+

Prefix <- (AND / NOT)? Suffix ACTION?

Suffix <- Primary (QUESTION / STAR / PLUS)?

Primary <- IDENTIFIER !LEFTARROW / OPEN Expression CLOSE / LITERAL / CLASS / DOT

ACTION <- '{' ACTION_BODY* '}' SPACING

AND <- '&' SPACING

CLASS <- '[' (!']' RANGE)* ']' SPACING

CLOSE <- ')' SPACING

DOT <- '.' SPACING

EOF <- !.

GLOBALS <- '%{' GLOBALS_BODY* '}%' SPACING

IDENTIFIER <- IDENT_START IDENT_CONT* SPACING

LEADING_SPACES <- SPACING

LEFTARROW <- '<-' SPACING

LITERAL <- '\'' (!'\'' CHAR)* '\'' SPACING / '"' (!'"' CHAR)* '"' SPACING

MEMBERS <- '{' ACTION_BODY* '}' SPACING

NOT <- '!' SPACING

OPEN <- '(' SPACING

PLUS <- '+' SPACING

QUESTION <- '?' SPACING

SLASH <- '/' SPACING

STAR <- '*' SPACING

ACTION_BODY <- '{' ACTION_BODY* '}' / !'}' .

CHAR <- '\\' ["'\-\[-\]nrt] / HEX_NUMBER / !'\\' !EOL .

COMMENT <- '#' (!EOL .)* EOL?

EOL <- '\r\n' / [\n\r]

GLOBALS_BODY <- !'}%' .

HEX_NUMBER <- [\\] 'u' [0-9A-Fa-f]+

IDENT_CONT <- IDENT_START / [0-9]

IDENT_START <- [A-Z_a-z]

RANGE <- CHAR '-' CHAR / CHAR

SPACE <- [\t ] / EOL

SPACING <- (SPACE / COMMENT)*

```

**Example**

Arithmetic grammar

```
%{
part of peg.example.arithmetic;

num _binop(num left, num right, String op) {
  switch(op) {
    case "+":
      return left + right;
    case "-":
      return left - right;
    case "*":
      return left * right;
    case "/":
      return left / right;
    default:
      throw "Unsupported operation $op";  
  }
}

}%

### Sentences (nonterminals) ###

Expr <-
  LEADING_SPACES? Sentence EOF { $$ = $2; }

Sentence <-
  Term (PLUS / MINUS) Sentence { $$ = _binop($1, $3, $2); }
  / Term

Term <-
  Atom (MUL / DIV) Term { $$ = _binop($1, $3, $2); }
  / Atom

Atom <-
  NUMBER
  / OPEN Sentence CLOSE { $$ = $2; }

### Lexemes (tokens) ###

CLOSE <-
  ')' WS

DIV <-
  '/' WS { $$ = $1; }

EOF <-
  !.

LEADING_SPACES <-
  WS

MINUS <-
  '-' WS { $$ = $1; }

MUL <-
  '*' WS { $$ = $1; }

NUMBER <-
  [0-9]+ WS { $$ = int.parse($1.join()); }

OPEN <-
  '(' WS

PLUS <-
  '+' WS { $$ = $1; }

### Morphemes ###

WS <-
  ([\t-\n\r ] / '\r\n')*


```

Source code of the generated parser for `arithmetic grammar` 

`peg general --comment arithmetic.peg` 

```dart
// This code was generated by a tool.
// Processing tool available at https://github.com/mezoni/peg

part of peg.example.arithmetic;

num _binop(num left, num right, String op) {
  switch(op) {
    case "+":
      return left + right;
    case "-":
      return left - right;
    case "*":
      return left * right;
    case "/":
      return left / right;
    default:
      throw "Unsupported operation $op";  
  }
}

class ArithmeticParser {
  static final List<String> _ascii = new List<String>.generate(128, (c) => new String.fromCharCode(c));
  
  static final List<String> _expect0 = <String>["\'(\'", "NUMBER"];
  
  static final List<String> _expect1 = <String>["\'+\'", "\'-\'"];
  
  static final List<String> _expect10 = <String>["\'(\'"];
  
  static final List<String> _expect11 = <String>["\'+\'"];
  
  static final List<String> _expect12 = <String>[];
  
  static final List<String> _expect2 = <String>["\'*\'", "\'/\'"];
  
  static final List<String> _expect3 = <String>["\')\'"];
  
  static final List<String> _expect4 = <String>["\'/\'"];
  
  static final List<String> _expect5 = <String>["EOF"];
  
  static final List<String> _expect6 = <String>["LEADING_SPACES"];
  
  static final List<String> _expect7 = <String>["\'-\'"];
  
  static final List<String> _expect8 = <String>["\'*\'"];
  
  static final List<String> _expect9 = <String>["NUMBER"];
  
  static final List<bool> _lookahead = _unmap([0x3ff01]);
  
  // '\t', '\n', '\r', ' '
  static final List<bool> _mapping0 = _unmap([0x800013]);
  
  // '\r\n'
  static final List<int> _strings0 = <int>[13, 10];
  
  final List<String> _tokenAliases = ["\')\'", "\'/\'", "EOF", "LEADING_SPACES", "\'-\'", "\'*\'", "NUMBER", "\'(\'", "\'+\'"];
  
  final List<int> _tokenFlags = [1, 1, 0, 1, 1, 1, 1, 1, 1];
  
  final List<String> _tokenNames = ["CLOSE", "DIV", "EOF", "LEADING_SPACES", "MINUS", "MUL", "NUMBER", "OPEN", "PLUS"];
  
  static final List<List<int>> _transitions0 = [[40, 40, 48, 57]];
  
  static final List<List<int>> _transitions1 = [[43, 43], [45, 45]];
  
  static final List<List<int>> _transitions2 = [[42, 42], [47, 47]];
  
  static final List<List<int>> _transitions3 = [[40, 40], [48, 57]];
  
  static final List<List<int>> _transitions4 = [[9, 10, 32, 32], [13, 13]];
  
  List<Map<int, List>> _cache;
  
  List<int> _cachePos;
  
  List<bool> _cacheable;
  
  int _ch;
  
  int _cursor;
  
  List<ArithmeticParserError> _errors;
  
  List<String> _expected;
  
  int _failurePos;
  
  List<int> _input;
  
  int _inputLen;
  
  int _startPos;
  
  int _testing;
  
  int _token;
  
  int _tokenStart;
  
  bool success;
  
  final String text;
  
  ArithmeticParser(this.text) {
    if (text == null) {
      throw new ArgumentError('text: $text');
    }    
    _input = _toCodePoints(text);
    _inputLen = _input.length;    
    reset(0);    
  }
  
  void _addToCache(dynamic result, int start, int id) {   
    var map = _cache[id];
    if (map == null) {
      map = <int, List>{};
      _cache[id] = map;
    }
    map[start] = [result, _cursor, success];      
  }
  
  void _failure([List<String> expected]) {  
    if (_failurePos > _cursor) {
      return;
    }
    if (_failurePos < _cursor) {    
      _expected = [];
     _failurePos = _cursor;
    }
    if (_token != null) {
      var alias = _tokenAliases[_token];
      var flag = _tokenFlags[_token];
      var name = _tokenNames[_token];
      if (_failurePos > _tokenStart && _failurePos == _inputLen && (flag & 1) != 0) {             
        var message = "Unterminated '$name'";
        _errors.add(new ArithmeticParserError(ArithmeticParserError.UNTERMINATED, _failurePos, _tokenStart, message));
        _expected.addAll(expected);            
      } else if (_failurePos > _tokenStart && (flag & 1) != 0) {             
        var message = "Malformed '$name'";
        _errors.add(new ArithmeticParserError(ArithmeticParserError.MALFORMED, _failurePos, _tokenStart, message));
        _expected.addAll(expected);            
      } else {
        _expected.add(alias);
      }            
    } else if (expected == null) {
      _expected.add(null);
    } else {
      _expected.addAll(expected);
    }   
  }
  
  List _flatten(dynamic value) {
    if (value is List) {
      var result = [];
      var length = value.length;
      for (var i = 0; i < length; i++) {
        var element = value[i];
        if (element is Iterable) {
          result.addAll(_flatten(element));
        } else {
          result.add(element);
        }
      }
      return result;
    } else if (value is Iterable) {
      var result = [];
      for (var element in value) {
        if (element is! List) {
          result.add(element);
        } else {
          result.addAll(_flatten(element));
        }
      }
    }
    return [value];
  }
  
  dynamic _getFromCache(int id) {  
    if (!_cacheable[id]) {  
      _cacheable[id] = true;  
      return null;
    }
    var map = _cache[id];
    if (map == null) {
      return null;
    }
    var data = map[_cursor];
    if (data == null) {
      return null;
    }
    _cursor = data[1];
    success = data[2];
    if (_cursor < _inputLen) {
      _ch = _input[_cursor];
    } else {
      _ch = -1;
    }
    return data;  
  }
  
  int _getState(List<List<int>> transitions) {
    var count = transitions.length;
    var state = 0;
    for ( ; state < count; state++) {
      var found = false;
      var ranges = transitions[state];    
      while (true) {
        var right = ranges.length ~/ 2;
        if (right == 0) {
          break;
        }
        var left = 0;
        if (right == 1) {
          if (_ch <= ranges[1] && _ch >= ranges[0]) {
            found = true;          
          }
          break;
        }
        int middle;
        while (left < right) {
          middle = (left + right) >> 1;
          var index = middle << 1;
          if (ranges[index + 1] < _ch) {
            left = middle + 1;
          } else {
            if (_ch >= ranges[index]) {
              found = true;
              break;
            }
            right = middle;
          }
        }
        break;
      }
      if (found) {
        return state; 
      }   
    }
    if (_ch != -1) {
      return state;
    }
    return state + 1;  
  }
  
  List _list(Object first, List next) {
    var length = next.length;
    var list = new List(length + 1);
    list[0] = first;
    for (var i = 0; i < length; i++) {
      list[i + 1] = next[i][1];
    }
    return list;
  }
  
  String _matchAny() {
    success = _cursor < _inputLen;
    if (success) {
      String result;
      if (_ch < 128) {
        result = _ascii[_ch];  
      } else {
        result = new String.fromCharCode(_ch);
      }    
      if (++_cursor < _inputLen) {
        _ch = _input[_cursor];
      } else {
        _ch = -1;
      }    
      return result;
    }    
    return null;  
  }
  
  String _matchChar(int ch, String string) {
    success = _ch == ch;
    if (success) {
      var result = string;  
      if (++_cursor < _inputLen) {
        _ch = _input[_cursor];
      } else {
        _ch = -1;
      }    
      return result;
    }  
    return null;  
  }
  
  String _matchMapping(int start, int end, List<bool> mapping) {
    success = _ch >= start && _ch <= end;
    if (success) {    
      if(mapping[_ch - start]) {
        String result;
        if (_ch < 128) {
          result = _ascii[_ch];  
        } else {
          result = new String.fromCharCode(_ch);
        }     
        if (++_cursor < _inputLen) {
          _ch = _input[_cursor];
        } else {
          _ch = -1;
        }      
        return result;
      }
      success = false;
    }  
    return null;  
  }
  
  String _matchRange(int start, int end) {
    success = _ch >= start && _ch <= end;
    if (success) {
      String result;
      if (_ch < 128) {
        result = _ascii[_ch];  
      } else {
        result = new String.fromCharCode(_ch);
      }        
      if (++_cursor < _inputLen) {
        _ch = _input[_cursor];
      } else {
        _ch = -1;
      }  
      return result;
    }  
    return null;  
  }
  
  String _matchRanges(List<int> ranges) {
    var length = ranges.length;
    for (var i = 0; i < length; i += 2) {    
      if (_ch >= ranges[i]) {
        if (_ch <= ranges[i + 1]) {
          String result;
          if (_ch < 128) {
            result = _ascii[_ch];  
          } else {
            result = new String.fromCharCode(_ch);
          }          
          if (++_cursor < _inputLen) {
            _ch = _input[_cursor];
          } else {
             _ch = -1;
          }
          success = true;    
          return result;
        }      
      } else break;  
    }
    success = false;  
    return null;  
  }
  
  String _matchString(List<int> codePoints, String string) {
    var length = codePoints.length;  
    success = _cursor + length <= _inputLen;
    if (success) {
      for (var i = 0; i < length; i++) {
        if (codePoints[i] != _input[_cursor + i]) {
          success = false;
          break;
        }
      }
    } else {
      success = false;
    }  
    if (success) {
      _cursor += length;      
      if (_cursor < _inputLen) {
        _ch = _input[_cursor];
      } else {
        _ch = -1;
      }    
      return string;      
    }  
    return null; 
  }
  
  void _nextChar() {
    if (++_cursor < _inputLen) {
      _ch = _input[_cursor];
    } else {
      _ch = -1;
    }  
  }
  
  dynamic _parse_Atom() {
    // SENTENCE (NONTERMINAL)
    // Atom <- NUMBER / OPEN Sentence CLOSE
    var $$;          
    var pos = _cursor;             
    if(_cachePos[3] >= pos) {
      $$ = _getFromCache(3);
      if($$ != null) {
        return $$[0];       
      }
    } else {
      _cachePos[3] = pos;
    }  
    // => NUMBER / OPEN Sentence CLOSE # Choice
    switch (_getState(_transitions3)) {
      // [(]
      case 0:
        // => OPEN Sentence CLOSE # Sequence
        var ch0 = _ch, pos0 = _cursor, startPos0 = _startPos;
        _startPos = _cursor;
        while (true) {  
          // => OPEN
          $$ = _parse_OPEN();
          // <= OPEN
          if (!success) break;
          var seq = new List(3)..[0] = $$;
          // => Sentence
          $$ = _parse_Sentence();
          // <= Sentence
          if (!success) break;
          seq[1] = $$;
          // => CLOSE
          $$ = _parse_CLOSE();
          // <= CLOSE
          if (!success) break;
          seq[2] = $$;
          $$ = seq;
          if (success) {    
            // OPEN
            final $1 = seq[0];
            // Sentence
            final $2 = seq[1];
            // CLOSE
            final $3 = seq[2];
            final $start = startPos0;
            $$ = $2;
          }
          break;
        }
        if (!success) {
          _ch = ch0;
          _cursor = pos0;
        }
        _startPos = startPos0;
        // <= OPEN Sentence CLOSE # Sequence
        break;
      // [0-9]
      case 1:
        var startPos1 = _startPos;
        _startPos = _cursor;
        // => NUMBER
        $$ = _parse_NUMBER();
        // <= NUMBER
        _startPos = startPos1;
        break;
      // No matches
      case 2:
        $$ = null;
        success = false;
        break;
      // EOF
      case 3:
        while (true) {
          var startPos2 = _startPos;
          _startPos = _cursor;
          // => NUMBER
          $$ = _parse_NUMBER();
          // <= NUMBER
          _startPos = startPos2;
          if (success) break;
          // => OPEN Sentence CLOSE # Sequence
          var ch1 = _ch, pos1 = _cursor, startPos3 = _startPos;
          _startPos = _cursor;
          while (true) {  
            // => OPEN
            $$ = _parse_OPEN();
            // <= OPEN
            if (!success) break;
            var seq = new List(3)..[0] = $$;
            // => Sentence
            $$ = _parse_Sentence();
            // <= Sentence
            if (!success) break;
            seq[1] = $$;
            // => CLOSE
            $$ = _parse_CLOSE();
            // <= CLOSE
            if (!success) break;
            seq[2] = $$;
            $$ = seq;
            if (success) {    
              // OPEN
              final $1 = seq[0];
              // Sentence
              final $2 = seq[1];
              // CLOSE
              final $3 = seq[2];
              final $start = startPos3;
              $$ = $2;
            }
            break;
          }
          if (!success) {
            _ch = ch1;
            _cursor = pos1;
          }
          _startPos = startPos3;
          // <= OPEN Sentence CLOSE # Sequence
          break;
        }
        break;
    }
    if (!success && _cursor > _testing) {
      // Expected: NUMBER, '('
      _failure(_expect0);
    }
    // <= NUMBER / OPEN Sentence CLOSE # Choice
    if (_cacheable[3]) {
      _addToCache($$, pos, 3);
    }    
    return $$;
  }
  
  dynamic _parse_CLOSE() {
    // LEXEME (TOKEN)
    // CLOSE <- ')' WS
    var $$;
    _token = 0;  
    _tokenStart = _cursor;  
    // => ')' WS # Choice
    switch (_ch == 41 ? 0 : _ch == -1 ? 2 : 1) {
      // [)]
      // EOF
      case 0:
      case 2:
        // => ')' WS # Sequence
        var ch0 = _ch, pos0 = _cursor, startPos0 = _startPos;
        _startPos = _cursor;
        while (true) {  
          // => ')'
          $$ = ')';
          success = true;
          if (++_cursor < _inputLen) {
            _ch = _input[_cursor];
          } else {
            _ch = -1;
          }
          // <= ')'
          if (!success) break;
          var seq = new List(2)..[0] = $$;
          // => WS
          $$ = _parse_WS();
          // <= WS
          if (!success) break;
          seq[1] = $$;
          $$ = seq;
          break;
        }
        if (!success) {
          _ch = ch0;
          _cursor = pos0;
        }
        _startPos = startPos0;
        // <= ')' WS # Sequence
        break;
      // No matches
      case 1:
        $$ = null;
        success = false;
        break;
    }
    if (!success && _cursor > _testing) {
      // Expected: ')'
      _failure(_expect3);
    }
    // <= ')' WS # Choice
    _token = null;
    _tokenStart = null;
    return $$;
  }
  
  dynamic _parse_DIV() {
    // LEXEME (TOKEN)
    // DIV <- '/' WS
    var $$;
    _token = 1;  
    _tokenStart = _cursor;  
    // => '/' WS # Choice
    switch (_ch == 47 ? 0 : _ch == -1 ? 2 : 1) {
      // [/]
      // EOF
      case 0:
      case 2:
        // => '/' WS # Sequence
        var ch0 = _ch, pos0 = _cursor, startPos0 = _startPos;
        _startPos = _cursor;
        while (true) {  
          // => '/'
          $$ = '/';
          success = true;
          if (++_cursor < _inputLen) {
            _ch = _input[_cursor];
          } else {
            _ch = -1;
          }
          // <= '/'
          if (!success) break;
          var seq = new List(2)..[0] = $$;
          // => WS
          $$ = _parse_WS();
          // <= WS
          if (!success) break;
          seq[1] = $$;
          $$ = seq;
          if (success) {    
            // '/'
            final $1 = seq[0];
            // WS
            final $2 = seq[1];
            final $start = startPos0;
            $$ = $1;
          }
          break;
        }
        if (!success) {
          _ch = ch0;
          _cursor = pos0;
        }
        _startPos = startPos0;
        // <= '/' WS # Sequence
        break;
      // No matches
      case 1:
        $$ = null;
        success = false;
        break;
    }
    if (!success && _cursor > _testing) {
      // Expected: '/'
      _failure(_expect4);
    }
    // <= '/' WS # Choice
    _token = null;
    _tokenStart = null;
    return $$;
  }
  
  dynamic _parse_EOF() {
    // LEXEME (TOKEN)
    // EOF <- !.
    var $$;
    _token = 2;  
    _tokenStart = _cursor;  
    // => !. # Choice
    switch (_ch >= 0 && _ch <= 1114111 ? 0 : _ch == -1 ? 2 : 1) {
      // [\u0000-\u0010ffff]
      // EOF
      case 0:
      case 2:
        var startPos0 = _startPos;
        _startPos = _cursor;
        // => !.
        var ch0 = _ch, pos0 = _cursor, testing0 = _testing; 
        _testing = _inputLen + 1;
        // => .
        $$ = _matchAny();
        // <= .
        _ch = ch0;
        _cursor = pos0; 
        _testing = testing0;
        $$ = null;
        success = !success;
        // <= !.
        _startPos = startPos0;
        break;
      // No matches
      case 1:
        $$ = null;
        success = false;
        break;
    }
    if (!success && _cursor > _testing) {
      // Expected: EOF
      _failure(_expect5);
    }
    // <= !. # Choice
    _token = null;
    _tokenStart = null;
    return $$;
  }
  
  dynamic _parse_LEADING_SPACES() {
    // LEXEME (TOKEN)
    // LEADING_SPACES <- WS
    var $$;
    _token = 3;  
    _tokenStart = _cursor;  
    // => WS # Choice
    switch (_ch >= 0 && _ch <= 1114111 ? 0 : _ch == -1 ? 2 : 1) {
      // [\u0000-\u0010ffff]
      // EOF
      case 0:
      case 2:
        var startPos0 = _startPos;
        _startPos = _cursor;
        // => WS
        $$ = _parse_WS();
        // <= WS
        _startPos = startPos0;
        break;
      // No matches
      case 1:
        $$ = null;
        success = true;
        break;
    }
    if (!success && _cursor > _testing) {
      // Expected: LEADING_SPACES
      _failure(_expect6);
    }
    // <= WS # Choice
    _token = null;
    _tokenStart = null;
    return $$;
  }
  
  dynamic _parse_MINUS() {
    // LEXEME (TOKEN)
    // MINUS <- '-' WS
    var $$;
    _token = 4;  
    _tokenStart = _cursor;  
    // => '-' WS # Choice
    switch (_ch == 45 ? 0 : _ch == -1 ? 2 : 1) {
      // [-]
      // EOF
      case 0:
      case 2:
        // => '-' WS # Sequence
        var ch0 = _ch, pos0 = _cursor, startPos0 = _startPos;
        _startPos = _cursor;
        while (true) {  
          // => '-'
          $$ = '-';
          success = true;
          if (++_cursor < _inputLen) {
            _ch = _input[_cursor];
          } else {
            _ch = -1;
          }
          // <= '-'
          if (!success) break;
          var seq = new List(2)..[0] = $$;
          // => WS
          $$ = _parse_WS();
          // <= WS
          if (!success) break;
          seq[1] = $$;
          $$ = seq;
          if (success) {    
            // '-'
            final $1 = seq[0];
            // WS
            final $2 = seq[1];
            final $start = startPos0;
            $$ = $1;
          }
          break;
        }
        if (!success) {
          _ch = ch0;
          _cursor = pos0;
        }
        _startPos = startPos0;
        // <= '-' WS # Sequence
        break;
      // No matches
      case 1:
        $$ = null;
        success = false;
        break;
    }
    if (!success && _cursor > _testing) {
      // Expected: '-'
      _failure(_expect7);
    }
    // <= '-' WS # Choice
    _token = null;
    _tokenStart = null;
    return $$;
  }
  
  dynamic _parse_MUL() {
    // LEXEME (TOKEN)
    // MUL <- '*' WS
    var $$;
    _token = 5;  
    _tokenStart = _cursor;  
    // => '*' WS # Choice
    switch (_ch == 42 ? 0 : _ch == -1 ? 2 : 1) {
      // [*]
      // EOF
      case 0:
      case 2:
        // => '*' WS # Sequence
        var ch0 = _ch, pos0 = _cursor, startPos0 = _startPos;
        _startPos = _cursor;
        while (true) {  
          // => '*'
          $$ = '*';
          success = true;
          if (++_cursor < _inputLen) {
            _ch = _input[_cursor];
          } else {
            _ch = -1;
          }
          // <= '*'
          if (!success) break;
          var seq = new List(2)..[0] = $$;
          // => WS
          $$ = _parse_WS();
          // <= WS
          if (!success) break;
          seq[1] = $$;
          $$ = seq;
          if (success) {    
            // '*'
            final $1 = seq[0];
            // WS
            final $2 = seq[1];
            final $start = startPos0;
            $$ = $1;
          }
          break;
        }
        if (!success) {
          _ch = ch0;
          _cursor = pos0;
        }
        _startPos = startPos0;
        // <= '*' WS # Sequence
        break;
      // No matches
      case 1:
        $$ = null;
        success = false;
        break;
    }
    if (!success && _cursor > _testing) {
      // Expected: '*'
      _failure(_expect8);
    }
    // <= '*' WS # Choice
    _token = null;
    _tokenStart = null;
    return $$;
  }
  
  dynamic _parse_NUMBER() {
    // LEXEME (TOKEN)
    // NUMBER <- [0-9]+ WS
    var $$;
    _token = 6;  
    _tokenStart = _cursor;  
    // => [0-9]+ WS # Choice
    switch (_ch >= 48 && _ch <= 57 ? 0 : _ch == -1 ? 2 : 1) {
      // [0-9]
      // EOF
      case 0:
      case 2:
        // => [0-9]+ WS # Sequence
        var ch0 = _ch, pos0 = _cursor, startPos0 = _startPos;
        _startPos = _cursor;
        while (true) {  
          // => [0-9]+
          var testing0;
          for (var first = true, reps; ;) {  
            // => [0-9]  
            $$ = _matchRange(48, 57);  
            // <= [0-9]  
            if (success) {
             if (first) {      
                first = false;
                reps = [$$];
                testing0 = _testing;                  
              } else {
                reps.add($$);
              }
              _testing = _cursor;   
            } else {
              success = !first;
              if (success) {      
                _testing = testing0;
                $$ = reps;      
              } else $$ = null;
              break;
            }  
          }
          // <= [0-9]+
          if (!success) break;
          var seq = new List(2)..[0] = $$;
          // => WS
          $$ = _parse_WS();
          // <= WS
          if (!success) break;
          seq[1] = $$;
          $$ = seq;
          if (success) {    
            // [0-9]+
            final $1 = seq[0];
            // WS
            final $2 = seq[1];
            final $start = startPos0;
            $$ = int.parse($1.join());
          }
          break;
        }
        if (!success) {
          _ch = ch0;
          _cursor = pos0;
        }
        _startPos = startPos0;
        // <= [0-9]+ WS # Sequence
        break;
      // No matches
      case 1:
        $$ = null;
        success = false;
        break;
    }
    if (!success && _cursor > _testing) {
      // Expected: NUMBER
      _failure(_expect9);
    }
    // <= [0-9]+ WS # Choice
    _token = null;
    _tokenStart = null;
    return $$;
  }
  
  dynamic _parse_OPEN() {
    // LEXEME (TOKEN)
    // OPEN <- '(' WS
    var $$;
    _token = 7;  
    _tokenStart = _cursor;  
    // => '(' WS # Choice
    switch (_ch == 40 ? 0 : _ch == -1 ? 2 : 1) {
      // [(]
      // EOF
      case 0:
      case 2:
        // => '(' WS # Sequence
        var ch0 = _ch, pos0 = _cursor, startPos0 = _startPos;
        _startPos = _cursor;
        while (true) {  
          // => '('
          $$ = '(';
          success = true;
          if (++_cursor < _inputLen) {
            _ch = _input[_cursor];
          } else {
            _ch = -1;
          }
          // <= '('
          if (!success) break;
          var seq = new List(2)..[0] = $$;
          // => WS
          $$ = _parse_WS();
          // <= WS
          if (!success) break;
          seq[1] = $$;
          $$ = seq;
          break;
        }
        if (!success) {
          _ch = ch0;
          _cursor = pos0;
        }
        _startPos = startPos0;
        // <= '(' WS # Sequence
        break;
      // No matches
      case 1:
        $$ = null;
        success = false;
        break;
    }
    if (!success && _cursor > _testing) {
      // Expected: '('
      _failure(_expect10);
    }
    // <= '(' WS # Choice
    _token = null;
    _tokenStart = null;
    return $$;
  }
  
  dynamic _parse_PLUS() {
    // LEXEME (TOKEN)
    // PLUS <- '+' WS
    var $$;
    _token = 8;  
    _tokenStart = _cursor;  
    // => '+' WS # Choice
    switch (_ch == 43 ? 0 : _ch == -1 ? 2 : 1) {
      // [+]
      // EOF
      case 0:
      case 2:
        // => '+' WS # Sequence
        var ch0 = _ch, pos0 = _cursor, startPos0 = _startPos;
        _startPos = _cursor;
        while (true) {  
          // => '+'
          $$ = '+';
          success = true;
          if (++_cursor < _inputLen) {
            _ch = _input[_cursor];
          } else {
            _ch = -1;
          }
          // <= '+'
          if (!success) break;
          var seq = new List(2)..[0] = $$;
          // => WS
          $$ = _parse_WS();
          // <= WS
          if (!success) break;
          seq[1] = $$;
          $$ = seq;
          if (success) {    
            // '+'
            final $1 = seq[0];
            // WS
            final $2 = seq[1];
            final $start = startPos0;
            $$ = $1;
          }
          break;
        }
        if (!success) {
          _ch = ch0;
          _cursor = pos0;
        }
        _startPos = startPos0;
        // <= '+' WS # Sequence
        break;
      // No matches
      case 1:
        $$ = null;
        success = false;
        break;
    }
    if (!success && _cursor > _testing) {
      // Expected: '+'
      _failure(_expect11);
    }
    // <= '+' WS # Choice
    _token = null;
    _tokenStart = null;
    return $$;
  }
  
  dynamic _parse_Sentence() {
    // SENTENCE (NONTERMINAL)
    // Sentence <- Term (PLUS / MINUS) Sentence / Term
    var $$;          
    var pos = _cursor;             
    if(_cachePos[1] >= pos) {
      $$ = _getFromCache(1);
      if($$ != null) {
        return $$[0];       
      }
    } else {
      _cachePos[1] = pos;
    }  
    // => Term (PLUS / MINUS) Sentence / Term # Choice
    switch (_getState(_transitions0)) {
      // [(] [0-9]
      // EOF
      case 0:
      case 2:
        while (true) {
          // => Term (PLUS / MINUS) Sentence # Sequence
          var ch0 = _ch, pos0 = _cursor, startPos0 = _startPos;
          _startPos = _cursor;
          while (true) {  
            // => Term
            $$ = _parse_Term();
            // <= Term
            if (!success) break;
            var seq = new List(3)..[0] = $$;
            // => (PLUS / MINUS) # Choice
            switch (_getState(_transitions1)) {
              // [+]
              case 0:
                var startPos1 = _startPos;
                _startPos = _cursor;
                // => PLUS
                $$ = _parse_PLUS();
                // <= PLUS
                _startPos = startPos1;
                break;
              // [-]
              case 1:
                var startPos2 = _startPos;
                _startPos = _cursor;
                // => MINUS
                $$ = _parse_MINUS();
                // <= MINUS
                _startPos = startPos2;
                break;
              // No matches
              case 2:
                $$ = null;
                success = false;
                break;
              // EOF
              case 3:
                while (true) {
                  var startPos3 = _startPos;
                  _startPos = _cursor;
                  // => PLUS
                  $$ = _parse_PLUS();
                  // <= PLUS
                  _startPos = startPos3;
                  if (success) break;
                  var startPos4 = _startPos;
                  _startPos = _cursor;
                  // => MINUS
                  $$ = _parse_MINUS();
                  // <= MINUS
                  _startPos = startPos4;
                  break;
                }
                break;
            }
            if (!success && _cursor > _testing) {
              // Expected: '+', '-'
              _failure(_expect1);
            }
            // <= (PLUS / MINUS) # Choice
            if (!success) break;
            seq[1] = $$;
            // => Sentence
            $$ = _parse_Sentence();
            // <= Sentence
            if (!success) break;
            seq[2] = $$;
            $$ = seq;
            if (success) {    
              // Term
              final $1 = seq[0];
              // (PLUS / MINUS)
              final $2 = seq[1];
              // Sentence
              final $3 = seq[2];
              final $start = startPos0;
              $$ = _binop($1, $3, $2);
            }
            break;
          }
          if (!success) {
            _ch = ch0;
            _cursor = pos0;
          }
          _startPos = startPos0;
          // <= Term (PLUS / MINUS) Sentence # Sequence
          if (success) break;
          var startPos5 = _startPos;
          _startPos = _cursor;
          // => Term
          $$ = _parse_Term();
          // <= Term
          _startPos = startPos5;
          break;
        }
        break;
      // No matches
      case 1:
        $$ = null;
        success = false;
        break;
    }
    if (!success && _cursor > _testing) {
      // Expected: NUMBER, '('
      _failure(_expect0);
    }
    // <= Term (PLUS / MINUS) Sentence / Term # Choice
    if (_cacheable[1]) {
      _addToCache($$, pos, 1);
    }    
    return $$;
  }
  
  dynamic _parse_Term() {
    // SENTENCE (NONTERMINAL)
    // Term <- Atom (MUL / DIV) Term / Atom
    var $$;          
    var pos = _cursor;             
    if(_cachePos[2] >= pos) {
      $$ = _getFromCache(2);
      if($$ != null) {
        return $$[0];       
      }
    } else {
      _cachePos[2] = pos;
    }  
    // => Atom (MUL / DIV) Term / Atom # Choice
    switch (_getState(_transitions0)) {
      // [(] [0-9]
      // EOF
      case 0:
      case 2:
        while (true) {
          // => Atom (MUL / DIV) Term # Sequence
          var ch0 = _ch, pos0 = _cursor, startPos0 = _startPos;
          _startPos = _cursor;
          while (true) {  
            // => Atom
            $$ = _parse_Atom();
            // <= Atom
            if (!success) break;
            var seq = new List(3)..[0] = $$;
            // => (MUL / DIV) # Choice
            switch (_getState(_transitions2)) {
              // [*]
              case 0:
                var startPos1 = _startPos;
                _startPos = _cursor;
                // => MUL
                $$ = _parse_MUL();
                // <= MUL
                _startPos = startPos1;
                break;
              // [/]
              case 1:
                var startPos2 = _startPos;
                _startPos = _cursor;
                // => DIV
                $$ = _parse_DIV();
                // <= DIV
                _startPos = startPos2;
                break;
              // No matches
              case 2:
                $$ = null;
                success = false;
                break;
              // EOF
              case 3:
                while (true) {
                  var startPos3 = _startPos;
                  _startPos = _cursor;
                  // => MUL
                  $$ = _parse_MUL();
                  // <= MUL
                  _startPos = startPos3;
                  if (success) break;
                  var startPos4 = _startPos;
                  _startPos = _cursor;
                  // => DIV
                  $$ = _parse_DIV();
                  // <= DIV
                  _startPos = startPos4;
                  break;
                }
                break;
            }
            if (!success && _cursor > _testing) {
              // Expected: '*', '/'
              _failure(_expect2);
            }
            // <= (MUL / DIV) # Choice
            if (!success) break;
            seq[1] = $$;
            // => Term
            $$ = _parse_Term();
            // <= Term
            if (!success) break;
            seq[2] = $$;
            $$ = seq;
            if (success) {    
              // Atom
              final $1 = seq[0];
              // (MUL / DIV)
              final $2 = seq[1];
              // Term
              final $3 = seq[2];
              final $start = startPos0;
              $$ = _binop($1, $3, $2);
            }
            break;
          }
          if (!success) {
            _ch = ch0;
            _cursor = pos0;
          }
          _startPos = startPos0;
          // <= Atom (MUL / DIV) Term # Sequence
          if (success) break;
          var startPos5 = _startPos;
          _startPos = _cursor;
          // => Atom
          $$ = _parse_Atom();
          // <= Atom
          _startPos = startPos5;
          break;
        }
        break;
      // No matches
      case 1:
        $$ = null;
        success = false;
        break;
    }
    if (!success && _cursor > _testing) {
      // Expected: NUMBER, '('
      _failure(_expect0);
    }
    // <= Atom (MUL / DIV) Term / Atom # Choice
    if (_cacheable[2]) {
      _addToCache($$, pos, 2);
    }    
    return $$;
  }
  
  dynamic _parse_WS() {
    // MORHEME
    // WS <- ([\t-\n\r ] / '\r\n')*
    var $$;
    // => ([\t-\n\r ] / '\r\n')* # Choice
    switch (_ch >= 0 && _ch <= 1114111 ? 0 : _ch == -1 ? 2 : 1) {
      // [\u0000-\u0010ffff]
      // EOF
      case 0:
      case 2:
        var startPos0 = _startPos;
        _startPos = _cursor;
        // => ([\t-\n\r ] / '\r\n')*
        var testing0 = _testing; 
        for (var reps = []; ; ) {
          _testing = _cursor;
          // => ([\t-\n\r ] / '\r\n') # Choice
          switch (_getState(_transitions4)) {
            // [\t-\n] [ ]
            case 0:
              var startPos1 = _startPos;
              _startPos = _cursor;
              // => [\t-\n\r ]
              $$ = _matchMapping(9, 32, _mapping0);
              // <= [\t-\n\r ]
              _startPos = startPos1;
              break;
            // [\r]
            case 1:
              while (true) {
                var startPos2 = _startPos;
                _startPos = _cursor;
                // => [\t-\n\r ]
                $$ = _matchMapping(9, 32, _mapping0);
                // <= [\t-\n\r ]
                _startPos = startPos2;
                if (success) break;
                var startPos3 = _startPos;
                _startPos = _cursor;
                // => '\r\n'
                $$ = _matchString(_strings0, '\r\n');
                // <= '\r\n'
                _startPos = startPos3;
                break;
              }
              break;
            // No matches
            // EOF
            case 2:
            case 3:
              $$ = null;
              success = false;
              break;
          }
          if (!success && _cursor > _testing) {
            // Expected: 
            _failure(const [null]);
          }
          // <= ([\t-\n\r ] / '\r\n') # Choice
          if (success) {  
            reps.add($$);
          } else {
            success = true;
            _testing = testing0;
            $$ = reps;
            break; 
          }
        }
        // <= ([\t-\n\r ] / '\r\n')*
        _startPos = startPos0;
        break;
      // No matches
      case 1:
        $$ = null;
        success = true;
        break;
    }
    if (!success && _cursor > _testing) {
      // Expected: 
      _failure(_expect12);
    }
    // <= ([\t-\n\r ] / '\r\n')* # Choice
    return $$;
  }
  
  String _text([int offset = 0]) {
    return new String.fromCharCodes(_input.sublist(_startPos + offset, _cursor));
  }
  
  int _toCodePoint(String string) {
    if (string == null) {
      throw new ArgumentError("string: $string");
    }
  
    var length = string.length;
    if (length == 0) {
      throw new StateError("An empty string contains no elements.");
    }
  
    var start = string.codeUnitAt(0);
    if (length == 1) {
      return start;
    }
  
    if ((start & 0xFC00) == 0xD800) {
      var end = string.codeUnitAt(1);
      if ((end & 0xFC00) == 0xDC00) {
        return (0x10000 + ((start & 0x3FF) << 10) + (end & 0x3FF));
      }
    }
  
    return start;
  }
  
  List<int> _toCodePoints(String string) {
    if (string == null) {
      throw new ArgumentError("string: $string");
    }
  
    var length = string.length;
    if (length == 0) {
      return const <int>[];
    }
  
    var codePoints = <int>[];
    codePoints.length = length;
    var i = 0;
    var pos = 0;
    for ( ; i < length; pos++) {
      var start = string.codeUnitAt(i);
      i++;
      if ((start & 0xFC00) == 0xD800 && i < length) {
        var end = string.codeUnitAt(i);
        if ((end & 0xFC00) == 0xDC00) {
          codePoints[pos] = (0x10000 + ((start & 0x3FF) << 10) + (end & 0x3FF));
          i++;
        } else {
          codePoints[pos] = start;
        }
      } else {
        codePoints[pos] = start;
      }
    }
  
    codePoints.length = pos;
    return codePoints;
  }
  
  static List<bool> _unmap(List<int> mapping) {
    var length = mapping.length;
    var result = new List<bool>(length * 31);
    var offset = 0;
    for (var i = 0; i < length; i++) {
      var v = mapping[i];
      for (var j = 0; j < 31; j++) {
        result[offset++] = v & (1 << j) == 0 ? false : true;
      }
    }
    return result;
  }
  
  List<ArithmeticParserError> errors() {
    if (success) {
      return <ArithmeticParserError>[];
    }
  
    String escape(int c) {
      switch (c) {
        case 10:
          return r"\n";
        case 13:
          return r"\r";
        case 09:
          return r"\t";
        case -1:
          return "";
      }
      return new String.fromCharCode(c);
    } 
    
    String getc(int position) {  
      if (position < _inputLen) {
        return "'${escape(_input[position])}'";      
      }       
      return "end of file";
    }
  
    var errors = <ArithmeticParserError>[];
    if (_failurePos >= _cursor) {
      var set = new Set<ArithmeticParserError>();
      set.addAll(_errors);
      for (var error in set) {
        if (error.position >= _failurePos) {
          errors.add(error);
        }
      }
      var names = new Set<String>();  
      names.addAll(_expected);
      if (names.contains(null)) {
        var string = getc(_failurePos);
        var message = "Unexpected $string";
        var error = new ArithmeticParserError(ArithmeticParserError.UNEXPECTED, _failurePos, _failurePos, message);
        errors.add(error);
      } else {      
        var found = getc(_failurePos);      
        var list = names.toList();
        list.sort();
        var message = "Expected ${list.join(", ")} but found $found";
        var error = new ArithmeticParserError(ArithmeticParserError.EXPECTED, _failurePos, _failurePos, message);
        errors.add(error);
      }        
    }
    errors.sort((a, b) => a.position.compareTo(b.position));
    return errors;  
  }
  
  dynamic parse_Expr() {
    // SENTENCE (NONTERMINAL)
    // Expr <- LEADING_SPACES? Sentence EOF
    var $$;
    // => LEADING_SPACES? Sentence EOF # Choice
    switch (_ch >= 0 && _ch <= 1114111 ? 0 : _ch == -1 ? 2 : 1) {
      // [\u0000-\u0010ffff]
      // EOF
      case 0:
      case 2:
        // => LEADING_SPACES? Sentence EOF # Sequence
        var ch0 = _ch, pos0 = _cursor, startPos0 = _startPos;
        _startPos = _cursor;
        while (true) {  
          // => LEADING_SPACES?
          var testing0 = _testing;
          _testing = _cursor;
          // => LEADING_SPACES
          $$ = _parse_LEADING_SPACES();
          // <= LEADING_SPACES
          success = true; 
          _testing = testing0;
          // <= LEADING_SPACES?
          if (!success) break;
          var seq = new List(3)..[0] = $$;
          // => Sentence
          $$ = _parse_Sentence();
          // <= Sentence
          if (!success) break;
          seq[1] = $$;
          // => EOF
          $$ = _parse_EOF();
          // <= EOF
          if (!success) break;
          seq[2] = $$;
          $$ = seq;
          if (success) {    
            // LEADING_SPACES?
            final $1 = seq[0];
            // Sentence
            final $2 = seq[1];
            // EOF
            final $3 = seq[2];
            final $start = startPos0;
            $$ = $2;
          }
          break;
        }
        if (!success) {
          _ch = ch0;
          _cursor = pos0;
        }
        _startPos = startPos0;
        // <= LEADING_SPACES? Sentence EOF # Sequence
        break;
      // No matches
      case 1:
        $$ = null;
        success = false;
        break;
    }
    if (!success && _cursor > _testing) {
      // Expected: NUMBER, '('
      _failure(_expect0);
    }
    // <= LEADING_SPACES? Sentence EOF # Choice
    return $$;
  }
  
  void reset(int pos) {
    if (pos == null) {
      throw new ArgumentError('pos: $pos');
    }
    if (pos < 0 || pos > _inputLen) {
      throw new RangeError('pos');
    }      
    _cursor = pos;
    _cache = new List<Map<int, List>>(15);
    _cachePos = new List<int>.filled(15, -1);  
    _cacheable = new List<bool>.filled(15, false);
    _ch = -1;
    _errors = <ArithmeticParserError>[];   
    _expected = <String>[];
    _failurePos = -1;
    _startPos = pos;        
    _testing = -1;
    _token = null;
    _tokenStart = null;  
    if (_cursor < _inputLen) {
      _ch = _input[_cursor];
    }
    success = true;    
  }
  
}

class ArithmeticParserError {
  static const int EXPECTED = 1;    
      
  static const int MALFORMED = 2;    
      
  static const int MISSING = 3;    
      
  static const int UNEXPECTED = 4;    
      
  static const int UNTERMINATED = 5;    
      
  final int hashCode = 0;
  
  final String message;
  
  final int position;
  
  final int start;
  
  final int type;
  
  ArithmeticParserError(this.type, this.position, this.start, this.message);
  
  bool operator ==(other) {
    if (identical(this, other)) return true;
    if (other is ArithmeticParserError) {
      return type == other.type && position == other.position &&
      start == other.start && message == other.message;  
    }
    return false;
  }
  
}


```
Arithmetic grammar statistics

```dart
--------------------------------
Log entries:
Expr           SENTENCE <= MORHEME : callerAll == 0
Sentence       LEXEME   <= MORHEME : callerSentence > 0 (Expr)
Term           LEXEME   <= MORHEME : isRecursive && MORPHEME (Atom)
Atom           SENTENCE <= MORHEME : calleeLexeme > 0 (Sentence)
CLOSE          LEXEME   <= MORHEME : callerSentence > 0 (Atom)
EOF            LEXEME   <= MORHEME : callerSentence > 0 (Expr)
LEADING_SPACES LEXEME   <= MORHEME : callerSentence > 0 (Expr)
NUMBER         LEXEME   <= MORHEME : callerSentence > 0 (Atom)
OPEN           LEXEME   <= MORHEME : callerSentence > 0 (Atom)
Sentence       SENTENCE <= LEXEME  : calleeLexeme > 0 (Term, Sentence)
Term           SENTENCE <= LEXEME  : calleeSentence > 0 (Atom)
DIV            LEXEME   <= MORHEME : callerSentence > 0 (Term)
MINUS          LEXEME   <= MORHEME : callerSentence > 0 (Sentence)
MUL            LEXEME   <= MORHEME : callerSentence > 0 (Term)
PLUS           LEXEME   <= MORHEME : callerSentence > 0 (Sentence)
--------------------------------
Starting rules:
Expr
--------------------------------
Rules:
--------------------------------
Atom:
 Type: Sentence (nonterminal)
 Direct callees:
  (L) CLOSE
  (L) NUMBER
  (L) OPEN
  (S) Sentence
 All callees:
  (S) Atom
  (L) CLOSE
  (L) DIV
  (L) MINUS
  (L) MUL
  (L) NUMBER
  (L) OPEN
  (L) PLUS
  (S) Sentence
  (S) Term
  (M) WS
 Direct callers:
  (S) Term
 All callers:
  (S) Atom
  (S) Expr
  (S) Sentence
  (S) Term
 Start characters:
  [(][0-9]
 Expected lexemes (tokens):
  NUMBER '('
--------------------------------
CLOSE:
 Type: Lexeme (token)
 Direct callees:
  (M) WS
 All callees:
  (M) WS
 Direct callers:
  (S) Atom
 All callers:
  (S) Atom
  (S) Expr
  (S) Sentence
  (S) Term
 Start characters:
  [)]
 Expected lexemes (tokens):
  ')'
--------------------------------
DIV:
 Type: Lexeme (token)
 Direct callees:
  (M) WS
 All callees:
  (M) WS
 Direct callers:
  (S) Term
 All callers:
  (S) Atom
  (S) Expr
  (S) Sentence
  (S) Term
 Start characters:
  [/]
 Expected lexemes (tokens):
  '/'
--------------------------------
EOF:
 Type: Lexeme (token)
 Direct callees:
 All callees:
 Direct callers:
  (S) Expr
 All callers:
  (S) Expr
 Start characters:
  [\u0000-\u10ffff]
 Expected lexemes (tokens):
  EOF
--------------------------------
Expr:
 Type: Sentence (nonterminal)
 Direct callees:
  (L) EOF
  (L) LEADING_SPACES
  (S) Sentence
 All callees:
  (S) Atom
  (L) CLOSE
  (L) DIV
  (L) EOF
  (L) LEADING_SPACES
  (L) MINUS
  (L) MUL
  (L) NUMBER
  (L) OPEN
  (L) PLUS
  (S) Sentence
  (S) Term
  (M) WS
 Direct callers:
 All callers:
 Start characters:
  [\u0000-\u10ffff]
 Expected lexemes (tokens):
  NUMBER '('
--------------------------------
LEADING_SPACES:
 Type: Lexeme (token)
 Direct callees:
  (M) WS
 All callees:
  (M) WS
 Direct callers:
  (S) Expr
 All callers:
  (S) Expr
 Start characters:
  [\u0000-\u10ffff]
 Expected lexemes (tokens):
  LEADING_SPACES
--------------------------------
MINUS:
 Type: Lexeme (token)
 Direct callees:
  (M) WS
 All callees:
  (M) WS
 Direct callers:
  (S) Sentence
 All callers:
  (S) Atom
  (S) Expr
  (S) Sentence
  (S) Term
 Start characters:
  [-]
 Expected lexemes (tokens):
  '-'
--------------------------------
MUL:
 Type: Lexeme (token)
 Direct callees:
  (M) WS
 All callees:
  (M) WS
 Direct callers:
  (S) Term
 All callers:
  (S) Atom
  (S) Expr
  (S) Sentence
  (S) Term
 Start characters:
  [*]
 Expected lexemes (tokens):
  '*'
--------------------------------
NUMBER:
 Type: Lexeme (token)
 Direct callees:
  (M) WS
 All callees:
  (M) WS
 Direct callers:
  (S) Atom
 All callers:
  (S) Atom
  (S) Expr
  (S) Sentence
  (S) Term
 Start characters:
  [0-9]
 Expected lexemes (tokens):
  NUMBER
--------------------------------
OPEN:
 Type: Lexeme (token)
 Direct callees:
  (M) WS
 All callees:
  (M) WS
 Direct callers:
  (S) Atom
 All callers:
  (S) Atom
  (S) Expr
  (S) Sentence
  (S) Term
 Start characters:
  [(]
 Expected lexemes (tokens):
  '('
--------------------------------
PLUS:
 Type: Lexeme (token)
 Direct callees:
  (M) WS
 All callees:
  (M) WS
 Direct callers:
  (S) Sentence
 All callers:
  (S) Atom
  (S) Expr
  (S) Sentence
  (S) Term
 Start characters:
  [+]
 Expected lexemes (tokens):
  '+'
--------------------------------
Sentence:
 Type: Sentence (nonterminal)
 Direct callees:
  (L) MINUS
  (L) PLUS
  (S) Sentence
  (S) Term
 All callees:
  (S) Atom
  (L) CLOSE
  (L) DIV
  (L) MINUS
  (L) MUL
  (L) NUMBER
  (L) OPEN
  (L) PLUS
  (S) Sentence
  (S) Term
  (M) WS
 Direct callers:
  (S) Atom
  (S) Expr
  (S) Sentence
 All callers:
  (S) Atom
  (S) Expr
  (S) Sentence
  (S) Term
 Start characters:
  [(][0-9]
 Expected lexemes (tokens):
  NUMBER '('
--------------------------------
Term:
 Type: Sentence (nonterminal)
 Direct callees:
  (S) Atom
  (L) DIV
  (L) MUL
  (S) Term
 All callees:
  (S) Atom
  (L) CLOSE
  (L) DIV
  (L) MINUS
  (L) MUL
  (L) NUMBER
  (L) OPEN
  (L) PLUS
  (S) Sentence
  (S) Term
  (M) WS
 Direct callers:
  (S) Sentence
  (S) Term
 All callers:
  (S) Atom
  (S) Expr
  (S) Sentence
  (S) Term
 Start characters:
  [(][0-9]
 Expected lexemes (tokens):
  NUMBER '('
--------------------------------
WS:
 Type: Morheme
 Direct callees:
 All callees:
 Direct callers:
  (L) CLOSE
  (L) DIV
  (L) LEADING_SPACES
  (L) MINUS
  (L) MUL
  (L) NUMBER
  (L) OPEN
  (L) PLUS
 All callers:
  (S) Atom
  (L) CLOSE
  (L) DIV
  (S) Expr
  (L) LEADING_SPACES
  (L) MINUS
  (L) MUL
  (L) NUMBER
  (L) OPEN
  (L) PLUS
  (S) Sentence
  (S) Term
 Start characters:
  [\u0000-\u10ffff]
 Expected lexemes (tokens):
--------------------------------
Sentences (nonterminals):
  Atom
  Expr
  Sentence
  Term
--------------------------------
Lexemes (tokens):
  CLOSE
  DIV
  EOF
  LEADING_SPACES
  MINUS
  MUL
  NUMBER
  OPEN
  PLUS
--------------------------------
Morphemes:
  WS
--------------------------------
Lexeme (token) names:
  CLOSE : ')'
  DIV : '/'
  EOF : EOF
  LEADING_SPACES : LEADING_SPACES
  MINUS : '-'
  MUL : '*'
  NUMBER : NUMBER
  OPEN : '('
  PLUS : '+'
--------------------------------
Recursives:
  Atom
  Sentence
  Term

```
