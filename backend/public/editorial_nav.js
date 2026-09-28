document.addEventListener("DOMContentLoaded", function () {
  var link = document.getElementById("game-test-link");
  if (!link) return;

  function showNotice(message) {
    var notice = document.getElementById("game-test-notice");
    if (!notice) {
      notice = document.createElement("div");
      notice.id = "game-test-notice";
      notice.className = "flash danger game-test-notice";
      notice.setAttribute("role", "alert");
      document.body.appendChild(notice);
    }
    notice.textContent = message;
    clearTimeout(notice.hideTimer);
    notice.hideTimer = setTimeout(function () { notice.remove(); }, 9000);
  }

  link.addEventListener("click", function (event) {
    event.preventDefault();
    // Open the window now (browsers block pop-ups opened later), then point
    // it at the game only if something is serving it.
    var win = window.open(
      "about:blank",
      "hnahsinGameTest",
      "width=1280,height=860,menubar=no,toolbar=no,location=no,status=no"
    );
    fetch(link.href, { method: "HEAD", mode: "no-cors", cache: "no-store" }).then(
      function () {
        if (!win) { window.open(link.href, "_blank", "noopener"); return; }
        win.opener = null;
        win.location.href = link.href;
      },
      function () {
        if (win) win.close();
        showNotice(
          "Game test a tlan lo (" + link.href + "). ./run_backend.command hmangin Studio tan leh la " +
          "(game a build nghal ang), emaw ./run_local.command hmangin game leh Studio tan rawh."
        );
      }
    );
  });
});
