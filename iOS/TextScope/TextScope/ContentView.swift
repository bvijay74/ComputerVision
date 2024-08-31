//
//  ContentView.swift
//  TextScope
//
//  Created by Vijayakumar B on 29/08/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var context: AppContext
    
    var body: some View {
        if context.activeView == .Home {
            HomeView()
                .environmentObject(context)
        } else {
            CaptureView()
                .environmentObject(context)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppContext())
}
