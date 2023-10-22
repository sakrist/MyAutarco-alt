//
//  ProcessInfo+extension.swift
//  MyAutarco
//
//  Created by Volodymyr Boichentsov on 05/11/2023.
//

import Foundation


public extension ProcessInfo {
    var isSwiftUIPreview: Bool {
        environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
}

