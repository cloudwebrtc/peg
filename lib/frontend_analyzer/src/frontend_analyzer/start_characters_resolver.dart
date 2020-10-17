part of peg.frontend_analyzer.frontend_analyzer;

class StartCharactersResolver extends ExpressionResolver {
  Object visitAndPredicate(AndPredicateExpression expression) {
    _visitChild(expression);
    return null;
  }

  Object visitAnyCharacter(AnyCharacterExpression expression) {
    if (expression.level == 0) {
      expression.startCharacters.addGroup(Expression.unicodeGroup);
    }

    return null;
  }

  Object visitCharacterClass(CharacterClassExpression expression) {
    if (expression.level == 0) {
      var startCharacters = expression.startCharacters;
      for (var group in expression.ranges.groups) {
        startCharacters.addGroup(group);
      }
    }

    return null;
  }

  Object visitLiteral(LiteralExpression expression) {
    if (expression.level == 0) {
      var text = expression.text;
      var ignoreCase = expression.ignoreCase;
      if (text.isEmpty) {
        expression.startCharacters.addGroup(Expression.unicodeGroup);
      } else {
        var codePoint = toRune(text);
        var group = new GroupedRangeList<bool>(codePoint, codePoint, true);
        textlists[group] = new TextSaver(text, ignoreCase);
        expression.startCharacters.addGroup(group);
      }
    }

    return null;
  }

  Object visitNotPredicate(NotPredicateExpression expression) {
    var child = expression.expression;
    child.accept(this);
    expression.startCharacters.addGroup(Expression.unicodeGroup);
    return null;
  }

  Object visitOneOrMore(OneOrMoreExpression expression) {
    _visitChild(expression);
    return null;
  }

  Object visitOptional(OptionalExpression expression) {
    _visitChild(expression);
    return null;
  }

  Object visitOrderedChoice(OrderedChoiceExpression expression) {
    if (processed.contains(expression)) {
      return null;
    }

    processed.add(expression);
    for (var child in expression.expressions) {
      child.accept(this);
      _applyData(child, expression);
    }

    //processed.remove(expression);
    return null;
  }

  Object visitRule(RuleExpression expression) {
    var rule = expression.rule;
    if (rule != null) {
      var ruleExpression = rule.expression;
      ruleExpression.accept(this);
      _applyData(ruleExpression, expression);
    }

    return null;
  }

  Object visitSequence(SequenceExpression expression) {
    var expressions = expression.expressions;
    var length = expressions.length;
    var optional = 0;
    var skip = false;
    for (var i = 0; i < length; i++) {
      var child = expressions[i];
      child.accept(this);
      if (!skip) {
        var isNotPredicate = child.type == ExpressionTypes.NOT_PREDICATE;
        var needApply = true;
        if (isNotPredicate) {
          if (i != length - 1) {
            needApply = false;
          }
        }

        if (needApply) {
          _applyData(child, expression);
        }

        if (!(child.isOptional || isNotPredicate)) {
          skip = true;
        }

        if (child.isOptional) {
          optional++;
        }
      }
    }

    if (optional == length) {
      expression.startCharacters.addGroup(Expression.unicodeGroup);
    }

    return null;
  }

  Object visitZeroOrMore(ZeroOrMoreExpression expression) {
    _visitChild(expression);
    return null;
  }

  Object _applyData(Expression from, Expression to) {
    var startCharacters = to.startCharacters;
    for (var group in from.startCharacters.groups) {
      startCharacters.addGroup(group);
    }

    return null;
  }

  Object _visitChild(UnaryExpression expression) {
    var child = expression.expression;
    child.accept(this);
    return _applyData(child, expression);
  }
}
