//
//  TextScopeApp.swift
//  TextScope
//
//  Created by Vijayakumar B on 29/08/24.
//

import SwiftUI

@main
struct TextScopeApp: App {
    @StateObject var context = AppContext()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .environmentObject(context)
    }
}
