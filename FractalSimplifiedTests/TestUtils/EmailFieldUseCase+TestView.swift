import Foundation
import Quick
import Nimble
import RxSwift

@testable import FractalSimplified

extension EmailFieldUseCase {
    
    final class TestView: TestViewType {
        
        let _placeholder = AnyTestView<String>.View()
        let _sink = AnyTestView<(String?) -> Void>.View()
        
        let disposable: Disposable?
        
        init(_ viewModel: AnyPresentable<EmailFieldPresenters>) {
            self.disposable = viewModel.present(EmailFieldPresenters(
                placeholder: self._placeholder.presenter,
                sink: self._sink.presenter
            ))
        }
    }
}

extension EmailFieldUseCase.TestView {
    var placeholder: String! { return self._placeholder.last?.value }
    var sink: ((String?) -> Void)! { return self._sink.last?.value }
}
