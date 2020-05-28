import UIKit
import RxSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        /// Uncomment to show default flow
//        let window = UIWindow(frame: UIScreen.main.bounds)
//        let welcomeViewController = WelcomeViewController.create()
//        window.rootViewController = welcomeViewController
//        window.makeKeyAndVisible()
//        self.window = window
//
//        let welcomeScreenViewModel = WelcomeScreenViewModel()
//        self.disposable = welcomeViewController.presenter.present(welcomeScreenViewModel)
//        self.root = welcomeScreenViewModel
//
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.tintColor = .primary
        let viewController = SuperSecuredViewController()
        let container = UINavigationController(rootViewController: viewController)
        window.rootViewController = container
        window.makeKeyAndVisible()
        self.window = window
        
        let screen = SuperSecuredScreen()
        self.superSecuredScreen = screen
        
        self.disposable = viewController.presenter.present(screen)
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        self.disposable?.dispose()
    }
    
    private var disposable: Disposable?
    private var superSecuredScreen: SuperSecuredScreen?
}

