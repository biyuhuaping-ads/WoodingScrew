import UIKit
import AppLovinSDK
import AppsFlyerLib

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let initConfig = ALSdkInitializationConfiguration(sdkKey: "LNR7IqQoTN_ruXr55ZWa_0SoWtyL65IFWSneUVVlGsv6RXs6idmUqtaf7AilM7UX_9NOyitGTFk_0prZ75JyhZ") { builder in
            builder.mediationProvider = ALMediationProviderMAX
        }
        
        ALSdk.shared().initialize(with: initConfig) { sdkConfig in
            print("AppLovin SDK initialized.")
            // 预加载广告等操作
            let _ = InterstitialAdVC.shared
        }
        
        AppsFlyerLib.shared().appleAppID = "id6746095021"
        AppsFlyerLib.shared().appsFlyerDevKey = "LKTSofNbQHd84hkMk5xJWd"
        
        // 监听 UIApplication 激活通知
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(sendLaunch),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        return true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    // 热启动（Hot Launch，从后台返回前台）等同于applicationDidBecomeActive
    @objc func sendLaunch(_ application: UIApplication) {
        // 从 UserDefaults 获取 customerUserId
        if let customUserId = UserDefaults.standard.string(forKey: "customerUserId"),
           !customUserId.isEmpty {
            // 设置到 AppsFlyer
            AppsFlyerLib.shared().customerUserID = customUserId
            // 启动 AppsFlyer
            AppsFlyerLib.shared().start()
        }
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {

    }
}

