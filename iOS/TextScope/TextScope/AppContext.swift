//
//  AppContext.swift
//  TextScope
//
//  Created by Vijayakumar B on 31/08/24.
//

import Foundation

enum ActiveView : Int, Codable {
    case Home=0, Camera
}

final class AppContext : ObservableObject {
    @Published var activeView : ActiveView = .Home
    @Published var detectedText: String = ""
}
