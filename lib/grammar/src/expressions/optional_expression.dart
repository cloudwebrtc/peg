part of peg.grammar.expressions;

class OptionalExpression extends SuffixExpression {
  OptionalExpression(Expression expression) : super(expression);

  int get minTimes => 0;


  get expressions => _getExpressions();

  _getExpressions() {
    if(_expression is OrderedChoiceExpression){
      return _expression.expressions;
    }
    return [];
  }

  String get suffix {
    return '?';
  }

  ExpressionTypes get type {
    return ExpressionTypes.OPTIONAL;
  }

  Object accept(ExpressionVisitor visitor) {
    return visitor.visitOptional(this);
  }
}
