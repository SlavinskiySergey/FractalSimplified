import Foundation
import RxSwift

@testable import FractalSimplified

extension WelcomeScreenViewModel {
    
    final class TestView: TestViewType {
        
        let _title = AnyTestView<String>.View()
        let _signUpTitle = AnyTestView<String>.View()
        let _signUpAction = ActionViewModel.TestView.View()
        let _signUpScreen = SignUpScreenViewModel.TestView.Optional.View()
        
        let disposable: Disposable?
        
        init(_ viewModel: AnyPresentable<WelcomeScreenPresenters>) {
            self.disposable = viewModel.present(WelcomeScreenPresenters(
                title: self._title.presenter,
                signUpTitle: self._signUpTitle.presenter,
                signUpAction: self._signUpAction.presenter,
                signUpScreen: self._signUpScreen.presenter
            ))
        }
    }
}

extension WelcomeScreenViewModel.TestView {
    var title: String! { return self._title.last?.value }
    var signUpTitle: String! { return self._signUpTitle.last?.value }
    var signUpAction: ActionViewModel.TestView! { return self._signUpAction.last }
    var signUpScreen: SignUpScreenViewModel.TestView! { return self._signUpScreen.last?.view }
}
