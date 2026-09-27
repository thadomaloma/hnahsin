{{flutter_js}}
{{flutter_build_config}}

// CanvasKit is loaded from the local build (not Google's CDN) so the app
// keeps working when gstatic.com is blocked or unreachable (corporate
// network, ad-blocker, offline). Without this it renders a blank page
// while it waits forever for the CDN fetch.
_flutter.loader.load({
  config: {
    canvasKitBaseUrl: "canvaskit/"
  }
});
