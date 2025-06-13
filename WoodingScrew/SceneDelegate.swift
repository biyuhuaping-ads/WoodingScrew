import UIKit
import SwiftUI
import AppsFlyerLib

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window

        // 从 storyboard 加载默认入口界面
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initialVC = storyboard.instantiateInitialViewController()
        window.rootViewController = initialVC
        window.makeKeyAndVisible()

        // 如果首次启动就带了 URL
        if let urlContext = connectionOptions.urlContexts.first {
            handleIncomingURL(urlContext.url)
        }
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        handleIncomingURL(url)
    }
    
    private func handleIncomingURL(_ url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else { return }

        if queryItems.contains(where: { $0.name == "name" && $0.value == "AppLovin" }) {
            print("URL 匹配到 AppLovin 广告页")

            DispatchQueue.main.async {
                let adView = AdLaunchView()
                let hostingController = UIHostingController(rootView: adView)
                hostingController.modalPresentationStyle = .fullScreen

                if let rootVC = self.window?.rootViewController {
                    rootVC.present(hostingController, animated: true, completion: nil)
                }
            }
        }
    }
}
