import Foundation
import Action
import RxSwift

final class ActionViewModel {
    
    init(action: Action<Void, Void>) {
        self.action = action
        
        executionIntents
            .flatMapLatest { _ in
                action.execute(())
            }
            .subscribe()
            .disposed(by: disposeBag)
        
        self.simpleAction = self.executionIntents.onNext
        self.executing = self.action.executing
        self.enabled = self.action.enabled
    }
    
    private let executing: Observable<Bool>
    private let enabled: Observable<Bool>
    private let simpleAction: (Void) -> ()
    
    private let action: Action<Void, Void>
    private let executionIntents = PublishSubject<Void>()
    private let disposeBag = DisposeBag()
    
}

extension ActionViewModel: Presentable {
    
    var present: (ActionViewModelPresenters) -> Disposable {
        return { [weak self] presenters in
            guard let someSelf = self else {
                return Disposables.create()
            }
            
            let actionDisposable = presenters.simpleAction.present(someSelf.simpleAction)
            let executingDisposable = presenters.executing.present(someSelf.executing)
            let enabledDisposable = presenters.enabled.present(someSelf.enabled)
            
            return CompositeDisposable(actionDisposable, executingDisposable, enabledDisposable)
        }
    }
    
}
