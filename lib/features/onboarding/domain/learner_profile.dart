import '../../../src/app_text.dart';

enum LearnerAgeBand { early, young, teen, adult }

extension LearnerAgeBandText on LearnerAgeBand {
  String get label => switch (this) {
        LearnerAgeBand.early => AppText.of('age.early'),
        LearnerAgeBand.young => AppText.of('age.young'),
        LearnerAgeBand.teen => AppText.of('age.teen'),
        LearnerAgeBand.adult => AppText.of('age.adult'),
      };

  String get description => switch (this) {
        LearnerAgeBand.early => AppText.of('age.early.note'),
        LearnerAgeBand.young => AppText.of('age.young.note'),
        LearnerAgeBand.teen => AppText.of('age.teen.note'),
        LearnerAgeBand.adult => AppText.of('age.adult.note'),
      };
}

enum MizoProficiency { newLearner, understandsSome, speaks, readsAndWrites }

extension MizoProficiencyText on MizoProficiency {
  String get label => switch (this) {
        MizoProficiency.newLearner => AppText.of('proficiency.new'),
        MizoProficiency.understandsSome => AppText.of('proficiency.some'),
        MizoProficiency.speaks => AppText.of('proficiency.speaks'),
        MizoProficiency.readsAndWrites => AppText.of('proficiency.reads'),
      };

  String get description => switch (this) {
        MizoProficiency.newLearner => AppText.of('proficiency.new.note'),
        MizoProficiency.understandsSome => AppText.of('proficiency.some.note'),
        MizoProficiency.speaks => AppText.of('proficiency.speaks.note'),
        MizoProficiency.readsAndWrites => AppText.of('proficiency.reads.note'),
      };
}

enum LearningGoal { conversation, vocabulary, reading, culture, refresh }

extension LearningGoalText on LearningGoal {
  String get label => switch (this) {
        LearningGoal.conversation => AppText.of('goal.conversation'),
        LearningGoal.vocabulary => AppText.of('goal.vocabulary'),
        LearningGoal.reading => AppText.of('goal.reading'),
        LearningGoal.culture => AppText.of('goal.culture'),
        LearningGoal.refresh => AppText.of('goal.refresh'),
      };
}

enum SupportLanguage { english, mizoOnly }

extension SupportLanguageText on SupportLanguage {
  String get label => switch (this) {
        SupportLanguage.english => AppText.of('support.english'),
        SupportLanguage.mizoOnly => AppText.of('support.mizoOnly'),
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
        LearnerAgeBand.early => AppText.of('profile.badge.early'),
        LearnerAgeBand.young => AppText.of('profile.badge.young'),
        LearnerAgeBand.teen => AppText.of('profile.badge.older'),
        LearnerAgeBand.adult => AppText.of('profile.badge.older'),
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
