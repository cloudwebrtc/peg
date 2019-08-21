part of peg.grammar_analyzer.grammar_analyzer;

class GrammarAnalyzer {
  List<String> analyze(Grammar grammar) {
    var rules = grammar.productionRules;
    var warnings = new List<String>();
    var startingRules = new StartingRulesFinder().find(rules);
    if (startingRules.length == 0) {
      warnings.add('Warning: Starting rule not found');
    } else if (startingRules.length > 1) {
      var rules = startingRules.map((e) => "\"${e.name}\"").join(", ");
      warnings.add('Warning: Found several starting rules: $rules');
    }

    var unresolvedRules = new UnresolvedRulesFinder().find(rules);
    for (var rule in unresolvedRules.keys) {
      var rules = unresolvedRules[rule].join(', ');
      warnings.add('Warning: Found unresolved rule(s) in "${rule.name}": $rules');
    }

    var leftRecursions = new LeftRecursionsFinder().find(rules);
    for (var rule in leftRecursions.keys) {
      for (var chain in leftRecursions[rule]) {
        if (chain is! List) {
          chain = [chain];
        }

        var list = [];
        var prev = rule;
        for (var link in chain) {
          list.add('${prev.name}.${link.name}');
          prev = link;
        }

        var rules = list.join(' -> ');
        warnings.add('Warning: Found left recursive rule "${rule.name}": $rules');
      }
    }

    var duplicates = new DuplicateRulesFinder().find(rules);
    for (var rule in duplicates) {
      warnings.add('Warning: Found several rules with name "${rule.name}"');
    }

    var nonterminalsWithLexemes = new NonterminalsWithLexemesFinder().find(rules);
    for (var rule in nonterminalsWithLexemes.keys) {
      var lexemes = nonterminalsWithLexemes[rule].join(", ");
      // TODO: Reduce restrictions
      //warnings.add('Warning: Found the direct use of characters in nonterminal "${rule.name}": $lexemes');
    }

    var infiniteLoops = new InfiniteLoopFinder().find(rules);
    for (var rule in infiniteLoops.keys) {
      var container = infiniteLoops[rule];
      for (var key in container.keys) {
        var expressions = container[key].join(", ");
        for (var expression in container[key]) {
          warnings.add('Warning: Found infinite loop in "${rule.name}": \"$key\" contains \"$expression\" which is able to not consume input');
        }
      }
    }

    var optionalInChoices = new ChoiceWithOptionalFinder().find(rules);
    for (var rule in optionalInChoices.keys) {
      var expression = optionalInChoices[rule].join(", ");
      warnings.add('Warning: Found optional expression in choice in "${rule.name}": $expression');
    }

    var predicatesWithOtionals = new PredicatesWithOptionalExpressionsFinder().find(rules);
    for (var rule in predicatesWithOtionals.keys) {
      var expression = predicatesWithOtionals[rule].join(", ");
      warnings.add('Warning: Found optional expression in predicate in "${rule.name}": $expression');
    }

    var predicatesWithEmpty = new PredicatesWithEmptylExpressionsFinder().find(rules);
    for (var rule in predicatesWithEmpty.keys) {
      var expression = predicatesWithEmpty[rule].join(", ");
      warnings.add('Warning: Found empty expression in predicate in "${rule.name}": $expression');
    }

    //var conflictingFollow = new ConflictingFollowFinder();
    //conflictingFollow.find(rules);

    var temp = rules.toList();
    temp.sort((a, b) => b.directCallers.length.compareTo(a.directCallers.length));
    if (unresolvedRules.isEmpty && !temp.isEmpty) {
      var rule = temp.first;
      if (!rule.isMorpheme) {
        warnings.add('Warning: Most used rule is not a morpheme: "${rule.name}"');
      }
    }

    return warnings;
  }
}
