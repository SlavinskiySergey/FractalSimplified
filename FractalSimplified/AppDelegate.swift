import UIKit
import RxSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        let welcomeViewController = WelcomeViewController.create()
        window.rootViewController = welcomeViewController
        window.makeKeyAndVisible()
        self.window = window
        
        let welcomeScreenViewModel = WelcomeScreenViewModel()
        self.disposable = welcomeViewController.presenter.present(welcomeScreenViewModel)
        self.root = welcomeScreenViewModel
        
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        self.disposable?.dispose()
    }
    
    private var disposable: Disposable?
    private var root: WelcomeScreenViewModel?
}

