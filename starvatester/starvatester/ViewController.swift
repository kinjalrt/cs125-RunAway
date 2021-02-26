//
//  ViewController.swift
//  starvatester
//
//  Created by Kay Lab on 2/24/21.
//  Copyright © 2021 Vinis Prjs. All rights reserved.
//

import UIKit
import AuthenticationServices
import Alamofire

class ViewController: UIViewController {
    
    private var authSession: ASWebAuthenticationSession?

    private let clientId: String = "61588"
    private let urlScheme: String = "testerapp"
    private let fallbackUrl: String = "testerapp.com"
    private let clientSecret: String = "4c5efd4b78648d6f3f21a4089c54d1bdfb49f8a6"
    var code: String = ""

       

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }

    @IBAction func connectStrava(_ sender: Any) {
        presentStrava()
    }
    
    private func presentStrava(){
        
        let url: String = "https://www.strava.com/oauth/mobile/authorize?client_id=\(clientId)&redirect_uri=\(urlScheme)%3A%2F%2F\(fallbackUrl)&response_type=code&approval_prompt=auto&scope=read"
        guard let authenticationUrl = URL(string: url) else { return }
        print(url)
        
        authSession = ASWebAuthenticationSession(url: authenticationUrl, callbackURLScheme: "\(urlScheme)://") { url, error in
                   if let error = error {
                       print(error)
                   } else {
                    if let code = self.getCode(from: url) {
                           print("sasuke")
                           print(code)
                        self.requestStravaTokens(with: code)
                        
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
    
    private func requestStravaTokens(with code: String) {
        let parameters: [String: Any] = ["client_id": clientId, "client_secret": clientSecret, "code": code, "grant_type": "authorization_code"]

        AF.request("https://www.strava.com/oauth/token", method: .post, parameters: parameters).response { response in
            guard let data = response.data else { return }
            let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            print("cat")
            let accessToken = dataDictionary["access_token"] as! String
            print(accessToken)
            self.retrieveSegments(with: accessToken)
        }
    }
    
    private func retrieveSegments(with accessToken: String){
        let parameters: [String: Any] = ["access_token": accessToken, "bounds": "[37.331193,-122.031401,40.331193,-119.031401]", "activity_type": "running"]

        AF.request("https://www.strava.com/api/v3/segments/explore", method: .get, parameters: parameters).response { response in
            guard let data = response.data else { return }
            let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            print(dataDictionary)
        }
        
        
    }
    
  
    
}

  
extension ViewController: ASWebAuthenticationPresentationContextProviding {

    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        UIApplication.shared.windows[0]
    }
}

