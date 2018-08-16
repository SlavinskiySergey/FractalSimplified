import Foundation
import RxSwift

final class ObservableHistory<Element> {
    fileprivate(set) var elements: [Element] = []
    fileprivate(set) var error: Error?
    fileprivate(set) var completed: Bool = false
    fileprivate(set) var subscribe: Bool = false
    fileprivate(set) var subscribed: Bool = false
    fileprivate(set) var dispose: Bool = false
    
    init() {}
}


extension Observable {
    
    typealias History = ObservableHistory<Element>
    
    func saveHistoryTo(_ history: ObservableHistory<Element>) -> Observable {
        return self.do(
            onNext: { history.elements.append($0) },
            onError: { history.error = $0 },
            onCompleted: { history.completed = true },
            onSubscribe: { history.subscribe = true },
            onSubscribed: { history.subscribed = true },
            onDispose: { history.dispose = true }
        )
    }
    
}
