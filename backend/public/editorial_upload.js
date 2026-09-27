(() => {
  const form = document.querySelector("[data-audio-upload]");
  if (!form) return;
  const status = form.querySelector("[data-upload-status]");
  const submit = form.querySelector("[type=submit]");
  const fileInput = form.querySelector("[type=file]");
  const csrf = document.querySelector('meta[name="csrf-token"]')?.content;
  const setStatus = (message, failed = false) => {
    status.textContent = message;
    status.classList.toggle("danger-text", failed);
  };
  const sha256 = async (file) => {
    const digest = await crypto.subtle.digest("SHA-256", await file.arrayBuffer());
    const bytes = Array.from(new Uint8Array(digest));
    return {
      hex: bytes.map((byte) => byte.toString(16).padStart(2, "0")).join(""),
      base64: btoa(String.fromCharCode(...bytes))
    };
  };
  form.addEventListener("submit", async (event) => {
    event.preventDefault();
    const file = fileInput.files[0];
    if (!file) return setStatus("Choose an audio file first.", true);
    if (file.size > 25 * 1024 * 1024) return setStatus("Audio must be 25 MB or smaller.", true);
    submit.disabled = true;
    try {
      setStatus("Checking file integrity…");
      const checksum = await sha256(file);
      const data = new FormData(form);
      data.delete("audio_asset[file]");
      data.set("audio_asset[source_filename]", file.name);
      data.set("audio_asset[content_type]", file.type || "audio/wav");
      data.set("audio_asset[byte_size]", file.size.toString());
      data.set("audio_asset[checksum_sha256]", checksum.hex);
      setStatus("Preparing secure upload…");
      const ticketResponse = await fetch(form.action, { method: "POST", headers: { "Accept": "application/json", "X-CSRF-Token": csrf }, body: data });
      const ticket = await ticketResponse.json();
      if (!ticketResponse.ok) throw new Error(ticket.error || "Upload could not be prepared.");
      const headers = { ...ticket.required_headers };
      if (headers["x-amz-checksum-sha256"]) headers["x-amz-checksum-sha256"] = checksum.base64;
      setStatus("Uploading directly to protected media storage…");
      const uploadResponse = await fetch(ticket.upload_url, { method: "PUT", headers, body: file });
      if (!uploadResponse.ok) throw new Error("Audio upload failed integrity checks.");
      setStatus("Verifying stored file…");
      const verifyResponse = await fetch(ticket.verify_url, { method: "POST", headers: { "Accept": "application/json", "Content-Type": "application/json", "X-CSRF-Token": csrf }, body: "{}" });
      const verified = await verifyResponse.json();
      if (!verifyResponse.ok) throw new Error(verified.error || "Stored audio could not be verified.");
      window.location.assign(verified.show_url);
    } catch (error) {
      setStatus(error.message || "Audio upload failed.", true);
      submit.disabled = false;
    }
  });
})();
