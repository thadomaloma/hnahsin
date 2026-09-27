document.addEventListener("DOMContentLoaded", function () {
  var link = document.getElementById("game-test-link");
  if (!link) return;

  link.addEventListener("click", function (event) {
    event.preventDefault();
    window.open(
      link.href,
      "thumalQuestGameTest",
      "noopener,width=1280,height=860,menubar=no,toolbar=no,location=no,status=no"
    );
  });
});
