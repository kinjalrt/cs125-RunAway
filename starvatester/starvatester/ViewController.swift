//
//  ViewController.swift
//  starvatester
//
//  Created by Kay Lab on 2/24/21.
//  Copyright © 2021 Vinis Prjs. All rights reserved.
//

import UIKit
import AuthenticationServices

class ViewController: UIViewController {
    
    private var authSession: ASWebAuthenticationSession?

    private let clientId: String = "61588"
    private let urlScheme: String = "testerapp"
    private let fallbackUrl: String = "http://localhost/"

       

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func connectStrava(_ sender: Any) {
        presentStrava()
    }
    
    private func presentStrava(){
        
       // https://www.strava.com/oauth/mobile/authorize?client_id=1234321&redirect_uri= YourApp%3A%2F%2Fwww.yourapp.com%2Fen-US&response_type=code&approval_prompt=auto&scope=activity%3Awrite%2Cread&state=test")!

        
        //let url: String = "https://www.strava.com/oauth/mobile/authorize?client_id=61588&redirect_uri= testerapp%3A%2F%2Fhttp://localhost/%2Fen-US&response_type=code&approval_prompt=auto&scope=activity%3Awrite%2Cread&state=test"

        
        //let url: String = "http://www.strava.com/oauth/authorize?client_id=\(clientId)&response_type=code&redirect_uri=http://localhost/exchange_token&approval_prompt=force&scope=read"
        let url: String = "https://www.strava.com/oauth/mobile/authorize?client_id=\(clientId)&redirect_uri=\(urlScheme)%3A%2F%2F\(fallbackUrl)&response_type=code&approval_prompt=auto&scope=read"
        guard let authenticationUrl = URL(string: url) else { return }
        print(url)
        
        authSession = ASWebAuthenticationSession(url: authenticationUrl, callbackURLScheme: "\(urlScheme)://") { url, error in
                   if let error = error {
                       print(error)
                   } else {
                       if let url = url {
                           print(url)
                       }
                   }
               }
        authSession?.presentationContextProvider = self
        authSession?.start()
    }
    
    private func getCode(from url: URL?) -> String? {
        guard let url = url?.absoluteString else { return nil }
        
        let urlComponents: URLComponents? = URLComponents(string: url)
        let code: String? = urlComponents?.queryItems?.filter { $0.name == "code" }.first?.value
        
        return code
    }
    
  
    
}

  
extension ViewController: ASWebAuthenticationPresentationContextProviding {

    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        UIApplication.shared.windows[0]
    }
}

