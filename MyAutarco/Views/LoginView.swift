//
//  LoginView.swift
//  MyAutarco
//
//  Created by Volodymyr Boichentsov on 30/10/2023.
//

import SwiftUI

//struct LoginView: View {
//    var body: some View {
//        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
//    }
//}

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoggingIn = false
    @State private var isLoggedIn = false
    
    @Environment(ModelData.self) private var modelData
    
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
                    if (isLoggingIn) {
                        ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                    } else {
                        Button(action: {
                            isLoggingIn = true
                            
                            Task {
                                isLoggedIn = await modelData.client.login(user:email, password: password)
                                await modelData.power()
                                await modelData.energy()
                                isLoggingIn = false
                            }
                            
                        }) {
                            Text("Log In")
                        }.disabled(isLoggingIn || email.isEmpty || password.isEmpty)
                    }
                }
                
                if (!modelData.client.errorMessage.isEmpty) {
                    Section {
                        Text(modelData.client.errorMessage)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationBarTitle("Login page")
            .navigationDestination(isPresented: $isLoggedIn) {
                HouseView()
            }
        }
    }
}


#Preview {
    LoginView()
        .environment(ModelData())
}
