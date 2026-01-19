import 'palmistry_data.dart';

// --- File 32 Models (Category Map) ---

class VisualInput {
  final String target;
  final String reason;
  final String sourceJson;

  VisualInput(
      {required this.target, required this.reason, required this.sourceJson});

  factory VisualInput.fromJson(Map<String, dynamic> json) {
    return VisualInput(
      target: json['target'] as String,
      reason: json['reason'] as String,
      sourceJson: json['source_json'] as String,
    );
  }
}

class ManualInput {
  final String questionType;
  final String reason;
  final String sourceJson;

  ManualInput(
      {required this.questionType,
      required this.reason,
      required this.sourceJson});

  factory ManualInput.fromJson(Map<String, dynamic> json) {
    return ManualInput(
      questionType: json['question_type'] as String,
      reason: json['reason'] as String,
      sourceJson: json['source_json'] as String,
    );
  }
}

class RequiredData {
  final List<VisualInput> visualInputs;
  final List<ManualInput> manualInputs;

  RequiredData({required this.visualInputs, required this.manualInputs});

  factory RequiredData.fromJson(Map<String, dynamic> json) {
    return RequiredData(
      visualInputs: (json['visual_inputs'] as List?)
              ?.map((e) => VisualInput.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      manualInputs: (json['manual_inputs'] as List?)
              ?.map((e) => ManualInput.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class SubCategory {
  final String subcategoryId;
  final String displayTitle;
  final String description;
  final RequiredData requiredData;

  SubCategory({
    required this.subcategoryId,
    required this.displayTitle,
    required this.description,
    required this.requiredData,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      subcategoryId: json['subcategory_id'] as String,
      displayTitle: json['display_title'] as String,
      description: json['description'] as String,
      requiredData:
          RequiredData.fromJson(json['required_data'] as Map<String, dynamic>),
    );
  }
}

class AppCategory {
  final String categoryId;
  final String displayTitle;
  final String icon;
  final String description;
  final List<SubCategory> subcategories;

  AppCategory({
    required this.categoryId,
    required this.displayTitle,
    required this.icon,
    required this.description,
    required this.subcategories,
  });

  factory AppCategory.fromJson(Map<String, dynamic> json) {
    return AppCategory(
      categoryId: json['category_id'] as String,
      displayTitle: json['display_title'] as String,
      icon: json['icon'] as String? ?? '🔮',
      description: json['description'] as String,
      subcategories: (json['subcategories'] as List?)
              ?.map((e) => SubCategory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// Combines all visual inputs from all subcategories (for backward compatibility)
  List<VisualInput> get allVisualInputs {
    final Set<String> addedTargets = {};
    final List<VisualInput> result = [];
    for (var sub in subcategories) {
      for (var input in sub.requiredData.visualInputs) {
        if (!addedTargets.contains(input.target)) {
          result.add(input);
          addedTargets.add(input.target);
        }
      }
    }
    return result;
  }

  /// Combines all manual inputs from all subcategories (for backward compatibility)
  List<ManualInput> get allManualInputs {
    final Set<String> addedTypes = {};
    final List<ManualInput> result = [];
    for (var sub in subcategories) {
      for (var input in sub.requiredData.manualInputs) {
        if (!addedTypes.contains(input.questionType)) {
          result.add(input);
          addedTypes.add(input.questionType);
        }
      }
    }
    return result;
  }

  /// Backward compatibility wrapper
  RequiredData get requiredData => RequiredData(
        visualInputs: allVisualInputs,
        manualInputs: allManualInputs,
      );
}

class AppCategoryMap {
  final Map<String, dynamic> fileInfo;
  final List<AppCategory> appCategories;

  AppCategoryMap({required this.fileInfo, required this.appCategories});

  factory AppCategoryMap.fromJson(Map<String, dynamic> json) {
    return AppCategoryMap(
      fileInfo: json['file_info'] as Map<String, dynamic>,
      appCategories: (json['app_categories'] as List?)
              ?.map((e) => AppCategory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

// --- File 33 Models (Rules & Fingerprints) ---

class ReadingRuleDetail {
  final String? hand;
  final String? meaning;
  final String? interpretationLogic;

  ReadingRuleDetail({this.hand, this.meaning, this.interpretationLogic});

  factory ReadingRuleDetail.fromJson(Map<String, dynamic> json) {
    return ReadingRuleDetail(
      hand: json['hand'] as String?,
      meaning: json['meaning'] as String?,
      interpretationLogic: json['interpretation_logic'] as String?,
    );
  }
}

class ReadingRule {
  final String ruleId;
  final String name;
  final String description;
  final List<ReadingRuleDetail> details;

  ReadingRule({
    required this.ruleId,
    required this.name,
    required this.description,
    required this.details,
  });

  factory ReadingRule.fromJson(Map<String, dynamic> json) {
    return ReadingRule(
      ruleId: json['rule_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      details: (json['details'] as List?)
              ?.map(
                  (e) => ReadingRuleDetail.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class FingerprintPattern {
  final String patternId;
  final String name;
  final String visualDesc;
  final String meaning;

  FingerprintPattern({
    required this.patternId,
    required this.name,
    required this.visualDesc,
    required this.meaning,
  });

  factory FingerprintPattern.fromJson(Map<String, dynamic> json) {
    return FingerprintPattern(
      patternId: json['pattern_id'] as String,
      name: json['name'] as String,
      visualDesc: json['visual_desc'] as String,
      meaning: json['meaning'] as String,
    );
  }
}

class HandGestureType {
  final String style;
  final String meaning;

  HandGestureType({required this.style, required this.meaning});

  factory HandGestureType.fromJson(Map<String, dynamic> json) {
    return HandGestureType(
      style: json['style'] as String,
      meaning: json['meaning'] as String,
    );
  }
}

class HandGesture {
  final String gestureId;
  final String name;
  final List<HandGestureType> types;

  HandGesture({
    required this.gestureId,
    required this.name,
    required this.types,
  });

  factory HandGesture.fromJson(Map<String, dynamic> json) {
    return HandGesture(
      gestureId: json['gesture_id'] as String,
      name: json['name'] as String,
      types: (json['types'] as List?)
              ?.map((e) => HandGestureType.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class ReadingRulesData {
  final PalmistryCategoryInfo categoryInfo;
  final List<ReadingRule> readingRules;
  final List<FingerprintPattern> fingerprints;
  final List<HandGesture> handGestures;

  ReadingRulesData({
    required this.categoryInfo,
    required this.readingRules,
    required this.fingerprints,
    required this.handGestures,
  });

  factory ReadingRulesData.fromJson(Map<String, dynamic> json) {
    return ReadingRulesData(
      categoryInfo: PalmistryCategoryInfo.fromJson(
          json['category_info'] as Map<String, dynamic>),
      readingRules: (json['reading_rules'] as List?)
              ?.map((e) => ReadingRule.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      fingerprints: (json['fingerprints'] as List?)
              ?.map(
                  (e) => FingerprintPattern.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      handGestures: (json['hand_gestures'] as List?)
              ?.map((e) => HandGesture.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

// --- File 35 Models (Synthesis & Combinations) ---

class SynthesisHierarchyRule {
  final int rank;
  final String element;
  final String power;

  SynthesisHierarchyRule({
    required this.rank,
    required this.element,
    required this.power,
  });

  factory SynthesisHierarchyRule.fromJson(Map<String, dynamic> json) {
    return SynthesisHierarchyRule(
      rank: json['rank'] as int,
      element: json['element'] as String,
      power: json['power'] as String,
    );
  }
}

class SynthesisRules {
  final String ruleOfDominance;
  final List<SynthesisHierarchyRule> hierarchy;

  SynthesisRules({
    required this.ruleOfDominance,
    required this.hierarchy,
  });

  factory SynthesisRules.fromJson(Map<String, dynamic> json) {
    return SynthesisRules(
      ruleOfDominance: json['rule_of_dominance'] as String,
      hierarchy: (json['hierarchy'] as List?)
              ?.map((e) =>
                  SynthesisHierarchyRule.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class SynthesisCombination {
  final String comboId;
  final List<String> components;
  final String synthesis;

  SynthesisCombination({
    required this.comboId,
    required this.components,
    required this.synthesis,
  });

  factory SynthesisCombination.fromJson(Map<String, dynamic> json) {
    return SynthesisCombination(
      comboId: json['combo_id'] as String,
      components:
          (json['components'] as List?)?.map((e) => e as String).toList() ?? [],
      synthesis: json['synthesis'] as String,
    );
  }
}

class SynthesisConflictResolution {
  final String conflictType;
  final String scenario;
  final String resolution;

  SynthesisConflictResolution({
    required this.conflictType,
    required this.scenario,
    required this.resolution,
  });

  factory SynthesisConflictResolution.fromJson(Map<String, dynamic> json) {
    return SynthesisConflictResolution(
      conflictType: json['conflict_type'] as String,
      scenario: json['scenario'] as String,
      resolution: json['resolution'] as String,
    );
  }
}

class PalmistrySynthesisData {
  final Map<String, dynamic> fileInfo;
  final SynthesisRules synthesisRules;
  final List<SynthesisCombination> commonCombinations;
  final List<SynthesisConflictResolution> conflictResolution;

  PalmistrySynthesisData({
    required this.fileInfo,
    required this.synthesisRules,
    required this.commonCombinations,
    required this.conflictResolution,
  });

  factory PalmistrySynthesisData.fromJson(Map<String, dynamic> json) {
    return PalmistrySynthesisData(
      fileInfo: json['file_info'] as Map<String, dynamic>,
      synthesisRules: SynthesisRules.fromJson(
          json['synthesis_rules'] as Map<String, dynamic>),
      commonCombinations: (json['common_combinations'] as List?)
              ?.map((e) =>
                  SynthesisCombination.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      conflictResolution: (json['conflict_resolution'] as List?)
              ?.map((e) => SynthesisConflictResolution.fromJson(
                  e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
