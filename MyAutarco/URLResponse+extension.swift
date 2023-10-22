//
//  URLResponse+extension.swift
//  MyAutarco
//
//  Created by Volodymyr Boichentsov on 22/10/2023.
//

import Foundation

extension URLResponse {

    func getStatusCode() -> Int {
        if let httpResponse = self as? HTTPURLResponse {
            return httpResponse.statusCode
        }
        return 0
    }
    
    func responseMessage() -> String {
        let errorMessage: String
        switch getStatusCode() {
        case 404:
            errorMessage = "Page not found"
        case 401:
            errorMessage = "Authentication required"
        case 403:
            errorMessage = "Access denied"
        case 500:
            errorMessage = "Internal server error. Please try again later."
        default:
            errorMessage = "An error occurred. Please try again later."
        }
        // Display errorMessage to the user
        return errorMessage
    }
}
