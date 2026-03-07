import Flutter
import UIKit

@main
@objc class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  var flutterEngine: FlutterEngine?

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    // Create and run the Flutter engine explicitly
    let engine = FlutterEngine(name: "main_engine")
    engine.run()
    flutterEngine = engine
    
    // Register plugins
    GeneratedPluginRegistrant.register(with: engine)
    
    // Create the FlutterViewController with the engine
    let flutterVC = FlutterViewController(engine: engine, nibName: nil, bundle: nil)
    
    // Set up the window programmatically (no storyboard)
    let window = UIWindow(frame: UIScreen.main.bounds)
    window.rootViewController = flutterVC
    window.makeKeyAndVisible()
    self.window = window
    
    return true
  }
}
