import Foundation
import RxSwift

protocol TestViewType {
    associatedtype ViewModel
    init(_ viewModel: ViewModel)
    var disposeBag: DisposeBag? { get }
}

final class TestPresenter<TestView: TestViewType> {
    
    init() {}
    
    var presenter: Presenter<TestView.ViewModel> {
        return Presenter.Test { [weak self] presentable in
            let view = TestView(presentable)
            let presentedValue = PresentedValue(value: view)
            
            if let disposeBag = presentedValue.value.disposeBag {
                presentedValue.disposable.disposed(by: disposeBag)
            }
            
            self!.presented.append(presentedValue)
            return presentedValue.disposable
        }
    }
    
    public private(set) var presented: [PresentedValue<TestView>] = []
    public var last: TestView! { return self.presented.last?.value }
}

extension TestViewType {
    // TODO: Consider using 'TestPresenter' name
    public typealias View = TestPresenter<Self>
}

final class OptionalTestView<WrappedTestView: TestViewType>: TestViewType {
    
    let view: WrappedTestView?
    
    var disposeBag: DisposeBag? {
        return self.view?.disposeBag
    }
    
    init(_ viewModel: WrappedTestView.ViewModel?) {
        self.view = viewModel.map(WrappedTestView.init)
    }
}

extension TestViewType {
    public typealias Optional = OptionalTestView<Self>
}

final class AnyTestView<Value>: TestViewType {
    
    let value: Value
    var disposeBag: DisposeBag? { return nil }
    
    init(_ viewModel: Value) {
        self.value = viewModel
    }
}
