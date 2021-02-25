//
//  stravaAPI.swift
//  runaway
//
//  Created by Kay Lab on 2/24/21.
//  Copyright © 2021 Vinis Prjs. All rights reserved.
//

import Foundation
import UIKit
import AuthenticationServices

class stravaAPI:UIViewController
    
{
    private var authSession: ASWebAuthenticationSession?

    private let clientId: String = "61588"
    private let urlScheme: String = "youUrlScheme"
    
    private func connectStrava()
    {
       
        let url: String = "http://www.strava.com/oauth/authorize?client_id=\(clientId)&redirect_uri=http://localhost/exchange_token&approval_prompt=force&scope=read"
        guard let authenticationUrl = URL(string: url) else { return }
        authSession = ASWebAuthenticationSession(url: authenticationUrl, callbackURLScheme: "\(urlScheme)://") { url, error in
                   if let error = error {
                       print(error)
                   } else {
                       if let url = url {
                           print(url)
                       }
                   }
               }
        
        
              
        
    }
}
