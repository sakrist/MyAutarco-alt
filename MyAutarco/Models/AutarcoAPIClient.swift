//
//  AutarcoAPIClient.swift
//  MyAutarco
//
//  Created by Volodymyr Boichentsov on 05/11/2023.
//

import Foundation

open class AutarcoAPIClient : ObservableObject {
    
    let apiEndpoint = "https://my.autarco.com/api/site"
    var public_key = ""
    var authData = ""
    var errorMessage = ""
    @Published var isTest: Bool = false
    @Published var isLoggedIn: Bool = false
    
    static var identifier: String {
//        return Bundle.main.bundleIdentifier ?? "com.sakrist.MyAutarco"
        return "com.sakrist.MyAutarco"
    }
    
    init() {
        if (!ProcessInfo.processInfo.isSwiftUIPreview) {
            authData = retrieveUserAuthData()
            isLoggedIn = !authData.isEmpty
        }
    }
    
    func login(user: String, password: String) async -> Bool {
        clearError()
        
        if (user == "test") {
            isTest = true
            return true
        }
        
        if let d = (user + ":" + password).data(using: .utf8) {
            authData = d.base64EncodedString()
        }
        
        await getPublicKey()
        
        if (errorMessage.isEmpty) {
            if let data = authData.data(using: .ascii) {
                Keychain.save(service: AutarcoAPIClient.identifier, key: "token", data: data)
                return true
            }
        }
        return false
    }
    
    func logout() {
        Keychain.delete(service: AutarcoAPIClient.identifier, key: "token")
        authData = ""
        isTest = false
    }
    
    fileprivate func retrieveUserAuthData() -> String {
        
        if let data = Keychain.retrieve(service: AutarcoAPIClient.identifier, key: "token") {
            return String(data: data, encoding: .ascii) ?? ""
        }
        return authData
    }
    
    fileprivate func createRequest(path:String) -> URLRequest? {
        
        if (authData.isEmpty) {
            return nil
        }
        
        let urlString = apiEndpoint + ((public_key != "") ? "/\(public_key)" : "") + ((path != "") ? "/\(path)" : "")
        if let url = URL(string: urlString) {
            var request = URLRequest(url: url)
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("Basic \(authData)", forHTTPHeaderField: "Authorization")
            return request
        }
        
        return nil
    }
    
    
    public func doRequest(path: String, completion: @escaping (Any) -> Void) async {
        self.errorMessage = ""
        if let powerRequest = createRequest(path: path) {
            await withTaskGroup(of: Void.self) { taskGroup in
                taskGroup.addTask {
                    do {
                        let (data, response) = try await URLSession.shared.data(for: powerRequest)
                        if response.getStatusCode() == 200 {
                            
                            #if DEBUG
                            if let string = String(data: data, encoding: .utf8) {
                                print("response for path: " + path)
                                print(string)
                            } else {
                                print("Failed to convert Data to String")
                            }
                            #endif
                            
                            if let json = try? JSONSerialization.jsonObject(with: data, options: []) {
                                completion(json)
                            } else {
                                self.errorMessage = "Failed to parse data from \(path)"
                            }
                        } else {
                            let error = response.responseMessage()
                            self.errorMessage = "Failed to request \(path), response: \(error)"
                        }
                    } catch {
                        self.errorMessage = "Failed to request \(path) \(error.localizedDescription)"
                    }
                }
            }
        } else {
            self.errorMessage = "Failed to request \(path)"
        }
    }
    
    public func getPublicKey() async {
        if (authData.isEmpty) {
            self.errorMessage = "No login information"
            return
        }
        
        await doRequest(path: "") { json in
            if let json = json as? [String : Any] {
                if (json.count > 0) {
                    if let data = json["data"] as? [Any] {
                        if let site = data[0] as? [String : Any] {
                            self.public_key = site["public_key"] as? String ?? ""
                            return
                        }
                    }
                }
            }
            self.errorMessage = "Failed to get API key"
        }
    }
    
    public func clearError() {
        self.errorMessage = ""
    }
}
