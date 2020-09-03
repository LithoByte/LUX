//
//  LUXLoginViewModel.swift
//  ThryvUXComponents
//
//  Created by Elliot Schrock on 2/11/18.
//

import UIKit
import Combine
import FunNet
import Slippers
import Prelude

public protocol LUXLoginInputs {
    func usernameChanged(username: String?)
    func passwordChanged(password: String?)
    func submitButtonPressed()
    func viewDidLoad()
}

public protocol LUXLoginOutputs {
    var submitButtonEnabledPublisher: AnyPublisher<Bool, Never> { get }
    var activityIndicatorVisiblePublisher: AnyPublisher<Bool, Never> { get }
    var advanceAuthedPublisher: AnyPublisher<(), Never> { get }
}

public protocol LUXLoginProtocol {
    var inputs: LUXLoginInputs { get }
    var outputs: LUXLoginOutputs { get }
}

open class LUXLoginViewModel: LUXLoginProtocol, LUXLoginInputs, LUXLoginOutputs {
    open var inputs: LUXLoginInputs { return self }
    open var outputs: LUXLoginOutputs { return self }
    
    @Published var username = ""
    @Published var password = ""
    let submitButtonPressedProperty = PassthroughSubject<(), Never>()
    let viewDidLoadProperty = PassthroughSubject<(), Never>()
    
    public var submitButtonEnabledPublisher: AnyPublisher<Bool, Never>
    public var submitButtonEnabledSubject = PassthroughSubject<Bool, Never>()
    
    public var activityIndicatorVisiblePublisher: AnyPublisher<Bool, Never>
    var activityIndicatorVisibleSubject = PassthroughSubject<Bool, Never>()
    
    public var advanceAuthedPublisher: AnyPublisher<(), Never>
    public var advanceAuthed = PassthroughSubject<(), Never>()
    
    let credsSubject = CurrentValueSubject<(String?, String?)?, Never>(nil)
    
    public let credentialLoginCall: CombineNetCall?
    
    private var cancelBag = Set<AnyCancellable>()
    
    public init<T>(credsCall: CombineNetCall? = nil, loginModelToJson: @escaping (String, String) -> T, saveAuth: ((Data) -> Bool)? = nil) where T: Encodable {
        credentialLoginCall = credsCall
        
        activityIndicatorVisiblePublisher = activityIndicatorVisibleSubject.eraseToAnyPublisher()
        
        if let authSaved = saveAuth, let responder = credsCall?.responder {
            advanceAuthedPublisher = responder.$data.skipNils().map(authSaved).filter { $0 }.map { _ in () }.eraseToAnyPublisher()
        } else {
            advanceAuthedPublisher = advanceAuthed.eraseToAnyPublisher()
        }
        
        submitButtonEnabledPublisher = self.viewDidLoadProperty
            .map { _ in false }.eraseToAnyPublisher()
        
        submitButtonEnabledPublisher = submitButtonEnabledPublisher.merge(with: Publishers.CombineLatest($username, $password).map(type(of: self).isCredsPresent(username:password:)).eraseToAnyPublisher(),
            self.activityIndicatorVisiblePublisher.map({ visible in !visible}).eraseToAnyPublisher()).eraseToAnyPublisher()
        
            
        submitButtonPressedProperty.sink { _ in
            let model = loginModelToJson(self.username, self.password)
            self.credentialLoginCall?.endpoint.postData = try? JsonProvider.jsonEncoder.encode(model)
            self.credentialLoginCall?.fire()
            self.activityIndicatorVisibleSubject.send(true)
        }.store(in: &cancelBag)
        
        credentialLoginCall?.responder?.$httpResponse.skipNils().dropFirst().sink(receiveValue: authResponseReceived).store(in: &cancelBag)
        credentialLoginCall?.responder?.$error.skipNils().dropFirst().sink { _ in self.activityIndicatorVisibleSubject.send(false) }.store(in: &cancelBag)
        credentialLoginCall?.responder?.$response.skipNils().dropFirst().sink { _ in self.activityIndicatorVisibleSubject.send(false) }.store(in: &cancelBag)
    }
    
    open func usernameChanged(username: String?) {
        self.username = username ?? ""
    }
    
    open func passwordChanged(password: String?) {
        self.password = password ?? ""
    }
    
    open func submitButtonPressed() {
        self.submitButtonPressedProperty.send(())
    }
    
    open func viewDidLoad() {
        self.viewDidLoadProperty.send(())
    }
    
    open func authResponseReceived(response: HTTPURLResponse) {
        if response.statusCode < 300 {
            self.advanceAuthed.send(())
        }
        self.activityIndicatorVisibleSubject.send(false)
    }
    
    public static func isValidCreds(username: String, password: String) -> Bool {
        return true
    }
    
    public static func isInvalidCreds(username: String, password: String) -> Bool {
        return false
    }
    
    public static func isCredsPresent(username: String?, password: String?) -> Bool {
        return username != nil && !(username!.isEmpty) && password != nil && !(password!.isEmpty)
    }
}
