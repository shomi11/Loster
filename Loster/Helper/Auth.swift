//
//  Auth.swift
//  Loster
//
//  Created by Malovic, Milos on 4/24/20.
//  Copyright © 2020 Malovic, Milos. All rights reserved.
//

import Foundation
import LocalAuthentication

struct Auth {
  
    static let context = LAContext()
    static var error: NSError?
    
    static func checkAuth(completionHandler:@escaping (Bool?, NSError?) -> Void) {
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Inside app can be sensitive data, so please identify your self!"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { (succes, errorAuth) in
                DispatchQueue.main.async {
                    if succes {
                        completionHandler(true, nil)
                    } else {
                        completionHandler(false, self.error)
                    }
                }
            }
        } 
    }
    
}
