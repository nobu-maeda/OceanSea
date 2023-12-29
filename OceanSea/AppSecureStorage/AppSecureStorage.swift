//
// AppSecureStorage.swift
// From: https://bsorrentino.github.io/bsorrentino/app/2023/05/29/swiftui-a-property-wrapper-to-secure-settings.html
//
import SwiftUI

@propertyWrapper
public struct AppSecureStorage: DynamicProperty {
    
    private let key: String
    private let accessibility:KeychainItemAccessibility
    
    public var wrappedValue: String? {
        get {
            KeychainWrapper.standard.string(forKey: key, withAccessibility: self.accessibility)
        }
        nonmutating set {
            if let newValue, !newValue.isEmpty {
                KeychainWrapper.standard.set( newValue, forKey: key, withAccessibility: self.accessibility)
            }
            else {
                KeychainWrapper.standard.removeObject(forKey: key, withAccessibility: self.accessibility)
            }
        }
    }
    
    public init(_ key: String, accessibility:KeychainItemAccessibility = .whenUnlocked ) {
        self.key = key
        self.accessibility = accessibility
    }
    
}
