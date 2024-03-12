//
//  ViewController.swift
//  KeyChainDemo
//
//  Created by Trung on 12/03/2024.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
       getPassword()
    }
    func getPassword() {
        guard let data = KeychainManager.get(
            service: "facebook.com", account: "trungdepzai"
        )
        else {
            print("Failed to read password")
            return
        }
        let password = String(decoding: data, as: UTF8.self)
        print("Password is : \(password)")
    }
    func save() {
        do {
            try KeychainManager.save(service: "facebook.com", account: "trungdepzai", password: "something".data(using: .utf8) ?? Data())
        }
        catch {
            print(error)
        }
    }
}

class KeychainManager {
    enum KeychainError: Error {
        case duplicateEntry
        case unknown(OSStatus)
    }
    
    
    static func save(
        //service, account,password, class, data
        service: String,
        account: String,
        password: Data
    )
    throws {
        print("Started Saving")
        let query: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
            kSecValueData as String: password as AnyObject,
        ]
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status != errSecDuplicateItem else {
            throw KeychainError.duplicateEntry
        }
        guard status == errSecSuccess else {
            throw KeychainError.unknown(status)
        }
        
        
        print("saved")
    }
    static func get(
        //service, account, class, return-data, matchlimit
        service: String,
        account: String
    )
    -> Data? {
        print("Started Getting")
        let query: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
            kSecReturnData as String: kCFBooleanTrue,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        print("Read status: \(status)")
        
        return result as? Data
    }
}
