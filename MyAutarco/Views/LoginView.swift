//
//  LoginView.swift
//  MyAutarco
//
//  Created by Volodymyr Boichentsov on 30/10/2023.
//

import SwiftUI


struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var loginInProgress = false
    
    @Environment(ModelData.self) private var modelData
    @EnvironmentObject var client: AutarcoAPIClient
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Login")) {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)

                    SecureField("Password", text: $password)
                }

                Section {
                    if (client.isLoggedIn) {
                        ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                    } else {
                        Button(action: {
                            loginInProgress = true
                            let emailStr = email
                            let passwordStr = password
                            Task {
                                client.isLoggedIn = await client.login(user:emailStr, password: passwordStr)
                                await modelData.power()
                                await modelData.energy()
                                loginInProgress = false
                            }
                            
                        }) {
                            Text("Log In")
                        }.disabled(loginInProgress || email.isEmpty || password.isEmpty)
                    }
                }
                
                if (!client.errorMessage.isEmpty) {
                    Section {
                        Text(client.errorMessage)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationBarTitle("Login page")
            .navigationDestination(isPresented: $client.isLoggedIn) {
                HouseView()
            }
        }
    }
}


#Preview {
    LoginView()
        .environment(ModelData.shared)
}
