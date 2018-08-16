import Foundation
import Quick
import Nimble
import RxSwift

@testable import FractalSimplified

extension ActionViewModel {
    
    final class TestView: TestViewType {
        
        let _simpleAction = AnyTestView<() -> Void>.View()
        let _executing = AnyTestView<Bool>.View()
        let _enabled = AnyTestView<Bool>.View()
        
        var disposeBag: DisposeBag?
        
        init(_ viewModel: AnyPresentable<ActionViewModelPresenters>) {
            let disposable = viewModel.present(ActionViewModelPresenters(
                simpleAction: self._simpleAction.presenter,
                executing: self._executing.presenter,
                enabled: self._enabled.presenter
            ))
            let disposeBag = DisposeBag()
            disposable.disposed(by: disposeBag)
            
            self.disposeBag = disposeBag
        }
    }
}

extension ActionViewModel.TestView {
    var simpleAction: (() -> Void)! { return self._simpleAction.last?.value }
    var executing: Bool! { return self._executing.last?.value }
    var enabled: Bool! { return self._enabled.last?.value }
}
