import Foundation
import RxSwift
import Action

final class WelcomeScreenViewModel {
    
    init() {
        self.title = "Welcome"
        self.signUpTitle = "Sign Up"
        
        let showSignUp = Action<Void, Void>.echo()
        self.signUpAction = ActionViewModel(action: showSignUp)
        
        showSignUp.elements
            .flatMapLatest { (_) -> Observable<SignUpScreenViewModel?> in
                let viewModel = SignUpScreenViewModel()
                return viewModel.result.asObserver()
                    .filter { $0.isBack }
                    .map { _ in nil }
                    .take(1)
                    .startWith(viewModel)
            }
            .bind(to: self.signUpViewModel)
            .disposed(by: self.disposeBag)        
    }
    
    private let title: String
    private let signUpTitle: String
    private let signUpAction: ActionViewModel
    private let signUpViewModel = BehaviorSubject<SignUpScreenViewModel?>(value: nil)
    
    private let disposeBag = DisposeBag()
}

extension WelcomeScreenViewModel: Presentable {
    
    var present: (WelcomeScreenPresenters) -> Disposable {
        return { [weak self] presenters in
            guard let someSelf = self else {
                return Disposables.create()
            }
            
            let titleDisposable = presenters.title.present(someSelf.title)
            let signUpTitleDisposable = presenters.signUpTitle.present(someSelf.signUpTitle)
            let signUpActionDisposable = presenters.signUpAction.present(someSelf.signUpAction)
            let signUpScreenDisposable = presenters.signUpScreen.present(someSelf.signUpViewModel.asObservable().map { $0.map(AnyPresentable.init) })
            
            return CompositeDisposable(disposables: [titleDisposable, signUpTitleDisposable, signUpActionDisposable, signUpScreenDisposable])
        }
    }
}

extension Action where Input == Element {
    static func echo() -> Action {
        return Action(workFactory: { Observable.just($0) })
    }
}

private extension SignUpScreenViewModel.Result {
    var isBack: Bool {
        switch self {
        case .back: return true
        }
    }
}
