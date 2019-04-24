import Foundation
import Action
import RxSwift

final class ActionViewModel {
    
    init(action: Action<Void, Void>) {
        self.action = action
        
        executionIntents
            .flatMapLatest { _ in
                return action.executing.take(1)
            }
            .filter { !$0 }
            .flatMapLatest { _ in
                action.execute(())
            }
            .catchError { _ -> Observable<()> in
                assertionFailure()
                return .empty()
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
    
    var present: (ActionViewModelPresenters) -> Disposable? {
        return { [weak self] presenters in
            guard let someSelf = self else {
                return nil
            }
            
            let disposables = [
                presenters.simpleAction.present(someSelf.simpleAction),
                presenters.executing.present(someSelf.executing),
                presenters.enabled.present(someSelf.enabled)
            ]
                .compactMap { $0 }
            
            return CompositeDisposable(disposables: disposables)
        }
    }
    
}
