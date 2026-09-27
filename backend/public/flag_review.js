// Flagged-word review: live dictionary match hint and Fix-only fields.
// Same matching rules as Editorial::FlagReview.compare.
(function () {
  var STOP = ["a", "an", "the", "to", "of", "or", "and", "be", "one", "something", "someone", "kind", "type", "e", "g"];

  function alternatives(text) {
    return String(text || "").toLowerCase().replace(/\(.*?\)/g, " ").split(/[\/,;]|\bor\b/).map(function (part) {
      var words = (part.match(/[a-z]+/g) || []).map(function (w) { return w.length > 3 ? w.replace(/s$/, "") : w; })
        .filter(function (w) { return STOP.indexOf(w) < 0; });
      return words;
    }).filter(function (words) { return words.length > 0; });
  }

  function compare(ours, theirs) {
    var mine = alternatives(ours), ref = alternatives(theirs);
    if (!mine.length || !ref.length) return "check";
    var best = 0;
    mine.forEach(function (a) {
      ref.forEach(function (b) {
        var inter = a.filter(function (w) { return b.indexOf(w) >= 0; }).length;
        var union = a.length + b.filter(function (w) { return a.indexOf(w) < 0; }).length;
        best = Math.max(best, inter / union);
      });
    });
    return best >= 0.5 ? "ok" : best > 0 ? "check" : "fix";
  }

  var LABELS = { ok: "Matches our meaning — OK is likely right.", check: "Partly matches — check before deciding.", fix: "Doesn't match — consider Fix." };

  document.addEventListener("DOMContentLoaded", function () {
    document.querySelectorAll(".flag-form").forEach(function (form) {
      var gloss = form.querySelector(".dictionary-gloss");
      var hint = form.querySelector(".match-hint");
      var fixFields = form.querySelector(".fix-fields");
      var english = form.querySelector("[name=fixed_english]");

      function toggleFix() {
        var chosen = form.querySelector("[name=decision]:checked");
        fixFields.hidden = !(chosen && chosen.value === "fix");
      }

      gloss.addEventListener("input", function () {
        if (!gloss.value.trim()) { hint.textContent = ""; hint.dataset.verdict = ""; return; }
        var verdict = compare(gloss.dataset.ours, gloss.value);
        hint.textContent = LABELS[verdict];
        hint.dataset.verdict = verdict;
        if (verdict === "fix" && english && !english.value && gloss.value.split(/\s+/).length <= 3) english.placeholder = gloss.value;
      });
      form.querySelectorAll("[name=decision]").forEach(function (radio) { radio.addEventListener("change", toggleFix); });
      toggleFix();
    });
  });
})();
