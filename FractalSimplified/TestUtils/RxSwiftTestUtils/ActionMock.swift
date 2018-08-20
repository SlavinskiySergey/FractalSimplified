import Foundation
import RxSwift
import Action

final class ActionMock<Input, Element> {
    
    typealias RxTask = Observable<Element>
    typealias RxAction = Action<Input, Element>
    
    let inputs = Variable<[Input]>([])
    let pipeInput = PublishSubject<Event<Element>>()
    let action: RxAction
    
    public init() {
        self.action = RxAction(workFactory: { [inputs, pipeInput] (input) -> Observable<Element> in
            inputs.value.append(input)
            return pipeInput.dematerialize()
        })
    }
    
    deinit {
//        self.pipeInput.onCompleted()
    }
}

extension ActionMock {
    
    var input: Input! {
        return self.inputs.value.last!
    }
    
    var inputsCount: Int {
        return self.inputs.value.count
    }
    
    func receive(_ value: Element) {
        self.pipeInput.onNext(.next(value))
        self.pipeInput.onNext(.completed)
    }
    
    func receive(_ error: Error) {
        self.pipeInput.onNext(.error(error))
    }
}
