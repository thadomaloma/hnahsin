enum LearnerAgeBand { early, young, teen, adult }

extension LearnerAgeBandText on LearnerAgeBand {
  String get label => switch (this) {
        LearnerAgeBand.early => 'Ages 5–7',
        LearnerAgeBand.young => 'Ages 8–13',
        LearnerAgeBand.teen => 'Ages 14–17',
        LearnerAgeBand.adult => 'Adult',
      };

  String get description => switch (this) {
        LearnerAgeBand.early => 'Picture leh game hmanga bulṭan',
        LearnerAgeBand.young => 'Words, spelling leh story hmanga zir',
        LearnerAgeBand.teen => 'Reading, conversation leh culture',
        LearnerAgeBand.adult => 'Mahni pace-a Mizo tawng zir leh',
      };
}

enum MizoProficiency { newLearner, understandsSome, speaks, readsAndWrites }

extension MizoProficiencyText on MizoProficiency {
  String get label => switch (this) {
        MizoProficiency.newLearner => "I'm new to Mizo",
        MizoProficiency.understandsSome => 'I understand some',
        MizoProficiency.speaks => 'I can speak Mizo',
        MizoProficiency.readsAndWrites => 'I can read and write',
      };

  String get description => switch (this) {
        MizoProficiency.newLearner => 'Thumal bul aṭangin min kaihhruai rawh',
        MizoProficiency.understandsSome => 'Ka hria deuh, sawi leh chhiar ka zir duh',
        MizoProficiency.speaks => 'Spelling leh reading ka tihpun duh',
        MizoProficiency.readsAndWrites => 'Tawng upa leh thiamna sang zâwk ka duh',
      };
}

enum LearningGoal { conversation, vocabulary, reading, culture, refresh }

extension LearningGoalText on LearningGoal {
  String get label => switch (this) {
        LearningGoal.conversation => 'Home Conversation',
        LearningGoal.vocabulary => 'Words & Spelling',
        LearningGoal.reading => 'Reading',
        LearningGoal.culture => 'Culture',
        LearningGoal.refresh => 'Refresh My Mizo',
      };
}

enum SupportLanguage { english, mizoOnly }

extension SupportLanguageText on SupportLanguage {
  String get label => switch (this) {
        SupportLanguage.english => 'English support',
        SupportLanguage.mizoOnly => 'Mizo only',
      };
}

class LearnerProfile {
  const LearnerProfile({
    required this.id,
    required this.ageBand,
    required this.proficiency,
    required this.goals,
    required this.supportLanguage,
    required this.dailyGoalMinutes,
    required this.reducedMotion,
    required this.onboardingCompleted,
    this.gentleMode = true,
  });

  factory LearnerProfile.fresh() => const LearnerProfile(
        id: 'guest',
        ageBand: LearnerAgeBand.young,
        proficiency: MizoProficiency.newLearner,
        goals: <LearningGoal>[LearningGoal.vocabulary],
        supportLanguage: SupportLanguage.english,
        dailyGoalMinutes: 5,
        reducedMotion: false,
        onboardingCompleted: false,
        gentleMode: true,
      );

  final String id;
  final LearnerAgeBand ageBand;
  final MizoProficiency proficiency;
  final List<LearningGoal> goals;
  final SupportLanguage supportLanguage;
  final int dailyGoalMinutes;
  final bool reducedMotion;
  final bool onboardingCompleted;
  final bool gentleMode;

  bool get isChild => ageBand != LearnerAgeBand.adult;

  String get experienceLabel => switch (ageBand) {
        LearnerAgeBand.early => 'Sprout',
        LearnerAgeBand.young => 'Explorer',
        LearnerAgeBand.teen => 'Journey',
        LearnerAgeBand.adult => 'Journey',
      };

  LearnerProfile copyWith({
    LearnerAgeBand? ageBand,
    MizoProficiency? proficiency,
    List<LearningGoal>? goals,
    SupportLanguage? supportLanguage,
    int? dailyGoalMinutes,
    bool? reducedMotion,
    bool? onboardingCompleted,
    bool? gentleMode,
  }) {
    return LearnerProfile(
      id: id,
      ageBand: ageBand ?? this.ageBand,
      proficiency: proficiency ?? this.proficiency,
      goals: List<LearningGoal>.unmodifiable(goals ?? this.goals),
      supportLanguage: supportLanguage ?? this.supportLanguage,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      reducedMotion: reducedMotion ?? this.reducedMotion,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      gentleMode: gentleMode ?? this.gentleMode,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'ageBand': ageBand.name,
        'proficiency': proficiency.name,
        'goals': goals.map((goal) => goal.name).toList(),
        'supportLanguage': supportLanguage.name,
        'dailyGoalMinutes': dailyGoalMinutes,
        'reducedMotion': reducedMotion,
        'onboardingCompleted': onboardingCompleted,
        'gentleMode': gentleMode,
      };

  factory LearnerProfile.fromJson(Map<String, Object?> json) {
    T enumValue<T extends Enum>(List<T> values, Object? raw, T fallback) {
      return values.where((value) => value.name == raw).firstOrNull ?? fallback;
    }

    final rawGoals = json['goals'];
    final goals = rawGoals is List
        ? rawGoals
            .whereType<String>()
            .map(
              (name) => LearningGoal.values
                  .where((value) => value.name == name)
                  .firstOrNull,
            )
            .whereType<LearningGoal>()
            .toList()
        : <LearningGoal>[];

    return LearnerProfile(
      id: json['id'] as String? ?? 'guest',
      ageBand: enumValue(
        LearnerAgeBand.values,
        json['ageBand'],
        LearnerAgeBand.young,
      ),
      proficiency: enumValue(
        MizoProficiency.values,
        json['proficiency'],
        MizoProficiency.newLearner,
      ),
      goals: List<LearningGoal>.unmodifiable(
        goals.isEmpty ? <LearningGoal>[LearningGoal.vocabulary] : goals,
      ),
      supportLanguage: enumValue(
        SupportLanguage.values,
        json['supportLanguage'],
        SupportLanguage.english,
      ),
      dailyGoalMinutes: (json['dailyGoalMinutes'] as num?)?.toInt() ?? 5,
      reducedMotion: json['reducedMotion'] as bool? ?? false,
      onboardingCompleted: json['onboardingCompleted'] as bool? ?? false,
      gentleMode: json['gentleMode'] as bool? ?? true,
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
