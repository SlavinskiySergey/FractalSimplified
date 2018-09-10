import Foundation

@testable import FractalSimplified

final class FractalSimplifiedTests {
    
    let view: WelcomeScreenViewModel.TestView
    
    init() {
        // Inject your mock dependencies here
        self.root = WelcomeScreenViewModel()
        self.view = WelcomeScreenViewModel.TestView(AnyPresentable(self.root))
    }
    
    private let root: WelcomeScreenViewModel
}

extension FractalSimplifiedTests {
    
    func openSignUp() {
        self.view.signUpAction.simpleAction()
    }
    
    func signUp() {
        self.openSignUp()
        self.view.signUpScreen.email.sink("some@email.com")
        self.view.signUpScreen.passwordSink("123456")
        self.view.signUpAction.simpleAction()
    }
}
