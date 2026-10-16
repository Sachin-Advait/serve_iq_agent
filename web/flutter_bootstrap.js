{{flutter_js}}
{{flutter_build_config}}

// Load CanvasKit from this server instead of www.gstatic.com: the MSSPF
// network blocks Google's CDN, which left the app on a blank page.
_flutter.loader.load({
  config: {
    canvasKitBaseUrl: "canvaskit/",
  },
});
