#!/usr/bin/env python3
"""Dependency-free Phase 2B new-game contract checks."""

from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def fail(message: str) -> None:
    raise SystemExit(f"ERROR: {message}")


def require(path: Path, contracts: tuple[str, ...]) -> str:
    if not path.is_file():
        fail(f"Required Phase 2B file is missing: {path.relative_to(ROOT)}")
    text = path.read_text(encoding="utf-8")
    for contract in contracts:
        if contract not in text:
            fail(f"{path.relative_to(ROOT)} is missing contract: {contract}")
    return text


def main() -> None:
    # Audio (Listen & Pick, pronunciation playback) was removed on
    # 2026-09-27; Thumal Kawp replaced Listen & Pick as the second new game.
    require(
        ROOT / "lib/features/games/presentation/phase2b_games.dart",
        (
            "class SentenceBuilderGame",
            "gameId: 'sentence_builder'",
            "ContentReportButton",
        ),
    )
    require(
        ROOT / "lib/features/games/presentation/thumal_kawp_game.dart",
        ("class ThumalKawpGame", "static const gameId = 'thumal_kawp'", "GameRuntime"),
    )
    require(
        ROOT / "lib/features/games/engine/phase2b_engine.dart",
        ("class SentenceTile", "class SentenceBuilderEngine", "shuffledTiles", "const sentenceExercises"),
    )
    require(
        ROOT / "lib/features/learning/domain/learning_state.dart",
        ("contentReports", "reportedContentIds", "_readContentReports"),
    )
    require(
        ROOT / "lib/src/screens.dart",
        ("Thumal Kawp", "Sentence Builder"),
    )
    preferences = require(
        ROOT / "lib/data/preferences_quest_repository.dart",
        ("'thumal_kawp'", "'sentence_builder'"),
    )
    if preferences.count("'thumal_kawp'") < 2:
        fail("Thumal Kawp session is not covered by clear and reset paths")
    if preferences.count("'sentence_builder'") < 2:
        fail("Sentence Builder session is not covered by clear and reset paths")
    require(ROOT / "test/phase2b_engine_test.dart", ("validates order",))
    require(
        ROOT / "test/phase2b_widget_test.dart",
        ("Thumal Kawp deals hidden pairs", "sentence builder opens"),
    )
    pubspec = require(ROOT / "pubspec.yaml", ("version:",))
    if "just_audio" in pubspec:
        fail("pubspec.yaml still depends on just_audio; audio was removed")

    print("Phase 2B new games (Thumal Kawp, Sentence Builder) and content reports: PASS")


if __name__ == "__main__":
    main()
