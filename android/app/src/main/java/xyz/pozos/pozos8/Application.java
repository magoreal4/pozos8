package xyz.pozos.pozos8;

import io.flutter.app.FlutterApplication;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback;
import io.flutter.plugins.GeneratedPluginRegistrant;
//import io.flutter.plugins.firebasemessaging.FlutterFirebaseMessagingService;

// Nota, esta linea la agregue
//import io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin;
// import io.flutter.plugins.pathprovider.PathProviderPlugin;
// import io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin;
import io.flutter.view.FlutterMain;
import rekab.app.background_locator.LocatorService;

public class Application extends FlutterApplication implements PluginRegistrantCallback {
    @Override
    public void onCreate() {
        super.onCreate();
        // FlutterFirebaseMessagingService.setPluginRegistrant(this);
        LocatorService.setPluginRegistrant(this);
        FlutterMain.startInitialization(this);
    }

    @Override
    public void registerWith(PluginRegistry registry) {
        // if (!registry.hasPlugin("io.flutter.plugins.pathprovider")) {
        //     PathProviderPlugin.registerWith(registry.registrarFor("io.flutter.plugins.pathprovider"));
        // }
        // if (!registry.hasPlugin("io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin")) {
        //     SharedPreferencesPlugin.registerWith(registry.registrarFor("io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin"));
        // }

        //if (!registry.hasPlugin("io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin")) {
         //   FirebaseMessagingPlugin.registerWith(registry.registrarFor("io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin"));
        //}

    }
}