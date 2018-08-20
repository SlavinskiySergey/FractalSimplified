import Foundation
import Quick
import Nimble
import RxSwift

@testable import FractalSimplified

final class EmailFieldUseCaseSpec: QuickSpec {
    
    override func spec() {
        
        describe("EmailField") {
            
            typealias SUT = EmailFieldUseCase
            
            var sut: SUT!
            var view: SUT.TestView!
            
            beforeEach {
                sut = SUT()
                view = SUT.TestView((AnyPresentable(sut)))
            }
            
            afterEach {
                sut = nil
                view = nil
            }
            
            it("presents a correct placeholder") {
                expect(view.placeholder) == "Email"
            }
            
            it("has an invalid result") {
                expect(try! sut.result.value()) == .invalid(nil)
            }
            
            describe("when a user enters an invalid email") {
                
                let invalidEmail = "invalid_email"
                
                beforeEach {
                    view.sink(invalidEmail)
                }
                
                it("has an invalid result") {
                    expect(try! sut.result.value()) == .invalid(invalidEmail)
                }
            }
            
            describe("when a user enters a valid email") {
                
                let validEmail = "some@email.com"
                
                beforeEach {
                    view.sink(validEmail)
                }
                
                it("has a valid result") {
                    expect(try! sut.result.value()) == .valid(validEmail)
                }
                
                describe("when a user enters an invalid email") {
                    
                    let invalidEmail = "some@emailcom"
                    
                    beforeEach {
                        view.sink(invalidEmail)
                    }
                    
                    it("has a valid result") {
                        expect(try! sut.result.value()) == .invalid(invalidEmail)
                    }
                }
            }
        }
    }
}
