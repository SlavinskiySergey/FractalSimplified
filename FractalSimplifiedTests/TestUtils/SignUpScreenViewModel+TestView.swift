import Foundation
import RxSwift

@testable import FractalSimplified

extension SignUpScreenViewModel {
    
    final class TestView: TestViewType {
        
        let _title = AnyTestView<String>.View()
        let _backTitle = AnyTestView<String>.View()
        let _backSink = AnyTestView<() -> Void>.View()
        let _passwordPlaceholder = AnyTestView<String>.View()
        let _passwordSink = AnyTestView<(String?) -> Void>.View()
        let _email = EmailFieldViewModel.TestView.View()
        let _signUpTitle = AnyTestView<String>.View()
        let _signUpAction = ActionViewModel.TestView.View()
        
        let disposable: Disposable?
        
        init(_ viewModel: AnyPresentable<SignUpScreenPresenters>) {
            self.disposable = viewModel.present(SignUpScreenPresenters(
                title: self._title.presenter,
                backTitle: self._backTitle.presenter,
                backSink: self._backSink.presenter,
                passwordPlaceholder: self._passwordPlaceholder.presenter,
                passwordSink: self._passwordSink.presenter,
                email: self._email.presenter,
                signUpTitle: self._signUpTitle.presenter,
                signUpAction: self._signUpAction.presenter
            ))
        }
    }
}

extension SignUpScreenViewModel.TestView {
    var title: String! { return self._title.last?.value }
    var backTitle: String! { return self._backTitle.last?.value }
    var backSink: (() -> Void)! { return self._backSink.last?.value }
    var passwordPlaceholder: String! { return self._passwordPlaceholder.last?.value }
    var passwordSink: ((String?) -> Void)! { return self._passwordSink.last?.value }
    var email: EmailFieldViewModel.TestView! { return self._email.last }
    var signUpTitle: String! { return self._signUpTitle.last?.value }
    var signUpAction: ActionViewModel.TestView! { return self._signUpAction.last }
}
