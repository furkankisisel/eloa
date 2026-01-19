// --- File 34 Models (Ethics & Principles) ---

import 'palmistry_data.dart';

class ForbiddenTerms {
  final List<String> forbiddenTerms;
  final List<String> preferredTerms;

  ForbiddenTerms({required this.forbiddenTerms, required this.preferredTerms});

  factory ForbiddenTerms.fromJson(Map<String, dynamic> json) {
    return ForbiddenTerms(
      forbiddenTerms: (json['forbidden_terms'] as List?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      preferredTerms: (json['preferred_terms'] as List?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }
}

class CorePhilosophy {
  final String manifesto;
  final ForbiddenTerms appIdentity;

  CorePhilosophy({required this.manifesto, required this.appIdentity});

  factory CorePhilosophy.fromJson(Map<String, dynamic> json) {
    return CorePhilosophy(
      manifesto: json['manifesto'] as String,
      appIdentity:
          ForbiddenTerms.fromJson(json['app_identity'] as Map<String, dynamic>),
    );
  }
}

class Disclaimer {
  final String id;
  final String location;
  final String text;
  final String? action;

  Disclaimer({
    required this.id,
    required this.location,
    required this.text,
    this.action,
  });

  factory Disclaimer.fromJson(Map<String, dynamic> json) {
    return Disclaimer(
      id: json['id'] as String,
      location: json['location'] as String,
      text: json['text'] as String,
      action: json['action'] as String?,
    );
  }
}

class AiRule {
  final String rule;
  final String instruction;

  AiRule({required this.rule, required this.instruction});

  factory AiRule.fromJson(Map<String, dynamic> json) {
    return AiRule(
      rule: json['rule'] as String,
      instruction: json['instruction'] as String,
    );
  }
}

class AiGuardrails {
  final String description;
  final List<AiRule> rules;

  AiGuardrails({required this.description, required this.rules});

  factory AiGuardrails.fromJson(Map<String, dynamic> json) {
    return AiGuardrails(
      description: json['description'] as String,
      rules: (json['rules'] as List?)
              ?.map((e) => AiRule.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class RephrasingTerm {
  final String bad;
  final String good;

  RephrasingTerm({required this.bad, required this.good});

  factory RephrasingTerm.fromJson(Map<String, dynamic> json) {
    return RephrasingTerm(
      bad: json['bad'] as String,
      good: json['good'] as String,
    );
  }
}

class RephrasingDictionary {
  final String description;
  final List<RephrasingTerm> terms;

  RephrasingDictionary({required this.description, required this.terms});

  factory RephrasingDictionary.fromJson(Map<String, dynamic> json) {
    return RephrasingDictionary(
      description: json['description'] as String,
      terms: (json['terms'] as List?)
              ?.map((e) => RephrasingTerm.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class EthicsData {
  final PalmistryCategoryInfo fileInfo;
  final CorePhilosophy corePhilosophy;
  final List<Disclaimer> disclaimers;
  final AiGuardrails aiGuardrails;
  final RephrasingDictionary rephrasingDictionary;

  EthicsData({
    required this.fileInfo,
    required this.corePhilosophy,
    required this.disclaimers,
    required this.aiGuardrails,
    required this.rephrasingDictionary,
  });

  factory EthicsData.fromJson(Map<String, dynamic> json) {
    return EthicsData(
      fileInfo: PalmistryCategoryInfo.fromJson(
          json['file_info'] as Map<String, dynamic>),
      corePhilosophy: CorePhilosophy.fromJson(
          json['core_philosophy'] as Map<String, dynamic>),
      disclaimers: (json['disclaimers'] as List?)
              ?.map((e) => Disclaimer.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      aiGuardrails:
          AiGuardrails.fromJson(json['ai_guardrails'] as Map<String, dynamic>),
      rephrasingDictionary: RephrasingDictionary.fromJson(
          json['rephrasing_dictionary'] as Map<String, dynamic>),
    );
  }
}
