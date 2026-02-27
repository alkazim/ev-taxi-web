{{flutter_js}}
{{flutter_build_config}}

// Custom bootstrap: load Flutter without any loading indicator.
// Providing onEntrypointLoaded skips the default progress bar.
_flutter.loader.load({
  serviceWorkerSettings: {
    serviceWorkerVersion: {{flutter_service_worker_version}},
  },
  onEntrypointLoaded: async function (engineInitializer) {
    const appRunner = await engineInitializer.initializeEngine();
    await appRunner.runApp();
  },
});
