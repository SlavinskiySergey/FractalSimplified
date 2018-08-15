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
        
        let welcomeScreenUseCase = WelcomeScreenUseCase()
        self.disposable = welcomeViewController.presenter.present(welcomeScreenUseCase)
        self.root = welcomeScreenUseCase
        
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        self.disposable?.dispose()
    }
    
    private var disposable: Disposable?
    private var root: WelcomeScreenUseCase?
}

