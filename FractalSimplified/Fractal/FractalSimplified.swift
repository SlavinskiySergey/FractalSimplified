import Foundation
import RxSwift

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
    
    /// Present Observable of ViewModel
    func present(_ observable: Observable<ViewModel>) -> Disposable {
        let serialDisposable = SerialDisposable()
        
        let subscribeDisposable = observable.subscribe(onNext: { (viewModel) in
            serialDisposable.dispose()
            serialDisposable.disposable = self.present(viewModel)
        })
        
        return CompositeDisposable(serialDisposable, subscribeDisposable)
    }
    
    /// Present Variable of ViewModel
    func present(_ variable: Variable<ViewModel>) -> Disposable {
        return present(variable.asObservable())
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
