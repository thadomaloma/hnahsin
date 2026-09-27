#!/usr/bin/env python3
"""Dependency-free Phase 2A learning-engine contract checks."""

from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def fail(message: str) -> None:
    raise SystemExit(f"ERROR: {message}")


def require(path: Path, contracts: tuple[str, ...]) -> str:
    if not path.is_file():
        fail(f"Required Phase 2A file is missing: {path.relative_to(ROOT)}")
    text = path.read_text(encoding="utf-8")
    for contract in contracts:
        if contract not in text:
            fail(f"{path.relative_to(ROOT)} is missing contract: {contract}")
    return text


def main() -> None:
    require(
        ROOT / "lib/features/learning/domain/learning_state.dart",
        (
            "enum LearningLevel { tq0, tq1, tq2, tq3, tq4, tq5, tq6, tq7 }",
            "enum MasteryStage",
            "class ItemMastery",
            "class LearningState",
            "placementCompleted",
            "recentOutcomes",
        ),
    )
    require(
        ROOT / "lib/features/learning/domain/learning_engine.dart",
        (
            "class PlacementEngine",
            "class SpacedRepetitionScheduler",
            "class AdaptiveDifficulty",
            "class DailyLessonPlanner",
            "ReviewRating.again",
        ),
    )
    repository = require(
        ROOT / "lib/data/quest_repository.dart",
        ("loadLearningState", "saveLearningState", "LearningState.fresh"),
    )
    if repository.count("Future<LearningState> loadLearningState") < 2:
        fail("In-memory learning-state persistence is incomplete")
    sqlite = require(
        ROOT / "lib/data/sqflite_quest_repository.dart",
        ("version:", "CREATE TABLE learning_state", "onUpgrade", "saveLearningState"),
    )
    if "version: 2" not in sqlite and "version: 3" not in sqlite:
        fail("SQLite schema must include the Phase 2A migration or a later version")
    preferences = require(
        ROOT / "lib/data/preferences_quest_repository.dart",
        ("phase2a.learning_state", "loadLearningState", "saveLearningState"),
    )
    invalid_reward_call = "_rewardsKey,\n      _learningKey,\n      <String>["
    if invalid_reward_call in preferences:
        fail("Learning key was inserted as an extra setStringList argument")
    reset_start = preferences.find("Future<void> resetAll()")
    if reset_start < 0 or "_learningKey," not in preferences[reset_start:]:
        fail("Preferences reset does not clear Phase 2A learning state")
    require(
        ROOT / "lib/features/learning/presentation/learning_screens.dart",
        (
            "class LearningOverviewCard",
            "class PlacementScreen",
            "class DailyReviewScreen",
            "Find My Mizo Level",
            "Start Daily Lesson",
        ),
    )
    require(
        ROOT / "lib/src/controller.dart",
        ("DailyLessonPlan get dailyPlan", "completePlacement", "recordReview"),
    )
    require(
        ROOT / "test/learning_engine_test.dart",
        ("TQ0 to TQ4", "spaced repetition", "daily planner", "JSON round-trip"),
    )
    require(
        ROOT / "test/learning_controller_test.dart",
        ("placement persists", "review outcome persists", "reset clears"),
    )
    require(
        ROOT / "docs/PHASE_2A_IMPLEMENTATION.md",
        ("TQ0–TQ4", "Spaced repetition", "DEVICE VERIFICATION PENDING"),
    )

    print("Phase 2A levels, placement, mastery, review queue and adaptive engine: PASS")


if __name__ == "__main__":
    main()
