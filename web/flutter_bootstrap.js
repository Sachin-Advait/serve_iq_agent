{{flutter_js}}
{{flutter_build_config}}

// Load CanvasKit and fonts from this server instead of Google's CDN: the
// MSSPF network blocks gstatic.com, which left the app on a blank page and
// then with invisible text while the font requests hung.
// web/fonts/ mirrors the fonts.gstatic.com/s/ paths the engine asks for:
// Roboto (its default font) and Noto Sans Arabic (Arabic text). Any other
// script fails fast with a 404 instead of hanging.
_flutter.loader.load({
  config: {
    canvasKitBaseUrl: "canvaskit/",
    fontFallbackBaseUrl: "fonts/",
  },
});
