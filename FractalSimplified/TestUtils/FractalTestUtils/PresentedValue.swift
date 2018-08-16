import Foundation
import RxSwift

final class PresentedValue<T> {
    
    let value: T
    let presentedAt = PresentedTime.tick()
    
    let disposable = CompositeDisposable()
    private(set) var disposedAt: UInt64?
    
    public init(value: T) {
        self.value = value
        let timeDisposable = Disposables.create { [weak self] in
            self?.disposedAt = PresentedTime.tick()
        }
        _ = self.disposable.insert(timeDisposable)
    }
    
}

extension PresentedValue: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "<\(type(of: self)): value=\(value), presented=\(presentedAt), disposed=\(String(describing: disposedAt))>"
    }
}

private struct PresentedTime {
    static var time = UInt64(0)
    static func tick() -> UInt64 {
        time += 1
        return time
    }
}
