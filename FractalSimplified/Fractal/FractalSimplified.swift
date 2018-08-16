import Foundation
import RxSwift
import RxCocoa

protocol Presentable: class {
    associatedtype Presenters
    var present: (Presenters) -> Disposable { get }
}

struct Presenter<ViewModel> {
    func present(_ viewModel: ViewModel) -> Disposable {
        return self.bind(viewModel)
    }
    
    fileprivate init(_ bind: @escaping (ViewModel) -> Disposable) {
        self.bind = bind
    }
    
    private let bind: (ViewModel) -> Disposable
}

extension Presenter {
    
    static func UI(bind: @escaping (ViewModel) -> Disposable) -> Presenter {
        return Presenter { viewModel -> Disposable in
            return MainScheduler.instance.schedule(viewModel, action: bind)
        }
    }
    
    static func Test(bind: @escaping (ViewModel) -> Disposable) -> Presenter {
        if NSClassFromString("XCTestCase") == nil {
            assertionFailure()
            return Presenter { _ in Disposables.create() }
        }
        return Presenter(bind)
    }
    
}

extension Presenter {
    
    /// Present Observable of ViewModel
    func present(_ observable: Observable<ViewModel>) -> Disposable {
        let serialDisposable = SerialDisposable()
        
        let subscribeDisposable = observable.subscribe(onNext: { (viewModel) in
            serialDisposable.disposable = self.present(viewModel)
        })
        
        return CompositeDisposable(serialDisposable, subscribeDisposable)
    }
    
    /// Present BehaviorRelay of ViewModel
    func present(_ behaviorRelay: BehaviorRelay<ViewModel>) -> Disposable {
        return present(behaviorRelay)
    }
    
    /// Present any Presentable with same Presenters
    func present<T: Presentable>(_ presentable: T) -> Disposable
        where ViewModel == AnyPresentable<T.Presenters> {
            return self.present(ViewModel(presentable))
    }
}

final class AnyPresentable<Presenters>: Presentable {
    let present: (Presenters) -> Disposable
    
    init<T: Presentable>(_ presentable: T) where T.Presenters == Presenters {
        self.present = presentable.present
    }
}
