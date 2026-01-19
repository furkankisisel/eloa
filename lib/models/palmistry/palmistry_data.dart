class PalmistryCategoryInfo {
  final String title;
  final String? sourceBook;
  final String? pageRange;
  final String? description;

  PalmistryCategoryInfo({
    required this.title,
    this.sourceBook,
    this.pageRange,
    this.description,
  });

  factory PalmistryCategoryInfo.fromJson(Map<String, dynamic> json) {
    return PalmistryCategoryInfo(
      title: json['title'] as String? ?? 'Unknown Title',
      sourceBook: json['source_book'] as String?,
      pageRange: json['page_range'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'source_book': sourceBook,
        'page_range': pageRange,
        'description': description,
      };
}

class PalmistryFeature {
  final String id;
  final String name;
  final String bookContent;
  final String? imagePath;

  PalmistryFeature({
    required this.id,
    required this.name,
    required this.bookContent,
    this.imagePath,
  });

  factory PalmistryFeature.fromJson(Map<String, dynamic> json) {
    return PalmistryFeature(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      bookContent: json['book_content'] as String? ?? '',
      imagePath: json['imagePath'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'book_content': bookContent,
        if (imagePath != null) 'imagePath': imagePath,
      };
}

class PalmistrySection {
  final String id;
  final String title;
  final List<PalmistryFeature> features;

  PalmistrySection({
    required this.id,
    required this.title,
    required this.features,
  });
}

class PalmistryTopic {
  final String id;
  final PalmistryCategoryInfo categoryInfo;
  final List<PalmistrySection> sections;

  PalmistryTopic({
    required this.id,
    required this.categoryInfo,
    required this.sections,
  });

  factory PalmistryTopic.customFromJson(String id, Map<String, dynamic> json) {
    final categoryInfo = PalmistryCategoryInfo.fromJson(
        json['category_info'] as Map<String, dynamic>);

    final sections = <PalmistrySection>[];
    json.forEach((key, value) {
      if (key != 'category_info' && value is List) {
        final features = (value)
            .map((e) => PalmistryFeature.fromJson(e as Map<String, dynamic>))
            .toList();

        final title = _humanize(key);

        sections.add(PalmistrySection(
          id: key,
          title: title,
          features: features,
        ));
      }
    });

    return PalmistryTopic(
      id: id,
      categoryInfo: categoryInfo,
      sections: sections,
    );
  }

  static String _humanize(String text) {
    return text
        .split('_')
        .map((word) =>
            word.isEmpty ? '' : '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }
}

class PalmistryOption {
  final String answer;
  final String? jsonId;
  final String? implication;

  PalmistryOption({
    required this.answer,
    this.jsonId,
    this.implication,
  });

  factory PalmistryOption.fromJson(Map<String, dynamic> json) {
    return PalmistryOption(
      answer: json['answer'] as String,
      jsonId: json['json_id'] as String?,
      implication: json['implication'] as String?,
    );
  }
}

class PalmistryQuestion {
  final String? questionId;
  final String? userQuestion;
  final String? q;
  final String? instruction;
  final List<PalmistryOption> options;

  String get text => userQuestion ?? q ?? '';

  PalmistryQuestion({
    this.questionId,
    this.userQuestion,
    this.q,
    this.instruction,
    required this.options,
  });

  factory PalmistryQuestion.fromJson(Map<String, dynamic> json) {
    var rawOptions = json['options'];
    List<PalmistryOption> parsedOptions = [];
    if (rawOptions is List) {
      parsedOptions = rawOptions.map((e) {
        if (e is String) {
          return PalmistryOption(answer: e);
        } else {
          return PalmistryOption.fromJson(e as Map<String, dynamic>);
        }
      }).toList();
    }

    return PalmistryQuestion(
      questionId: json['question_id'] as String?,
      userQuestion: json['user_question'] as String?,
      q: json['q'] as String?,
      instruction: json['instruction'] as String?,
      options: parsedOptions,
    );
  }
}

class ManualQuestionsData {
  final PalmistryCategoryInfo categoryInfo;
  final List<PalmistryQuestion> tactileQuestions;
  final List<PalmistryQuestion> flexibilityQuestions;
  final List<PalmistryQuestion> colorConfirmationQuestions;

  ManualQuestionsData({
    required this.categoryInfo,
    required this.tactileQuestions,
    required this.flexibilityQuestions,
    required this.colorConfirmationQuestions,
  });

  factory ManualQuestionsData.fromJson(Map<String, dynamic> json) {
    return ManualQuestionsData(
      categoryInfo: PalmistryCategoryInfo.fromJson(
          json['category_info'] as Map<String, dynamic>),
      tactileQuestions: (json['tactile_questions'] as List?)
              ?.map(
                  (e) => PalmistryQuestion.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      flexibilityQuestions: (json['flexibility_questions'] as List?)
              ?.map(
                  (e) => PalmistryQuestion.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      colorConfirmationQuestions: (json['color_confirmation_questions']
                  as List?)
              ?.map(
                  (e) => PalmistryQuestion.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
