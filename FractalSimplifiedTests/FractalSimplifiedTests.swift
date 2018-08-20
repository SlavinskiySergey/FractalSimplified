import Foundation

@testable import FractalSimplified

final class FractalSimplifiedTests {
    
    let view: WelcomeScreenUseCase.TestView
    
    init() {
        // Inject your mock dependencies here
        self.root = WelcomeScreenUseCase()
        self.view = WelcomeScreenUseCase.TestView(AnyPresentable(self.root))
    }
    
    private let root: WelcomeScreenUseCase
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
