//
//  CameraView.swift
//  TextScope
//
//  Created by Vijayakumar B on 29/08/24.
//

import SwiftUI

struct CaptureView: View {
    @EnvironmentObject var context: AppContext
    @State var detectedText: String = ""
    @State var error: Error? = nil
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            CameraView(detectedText: $detectedText, error: $error)
            
            VStack {
                if let error = self.error {
                    ZStack {
                        Text(error.localizedDescription)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.red.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.all, 10)
                    }.background(RoundedRectangle(cornerRadius: 20)
                        .fill(Color.black.opacity(0.25)))
                        .padding(.all, 20)
                }
                else {
                    ZStack {
                        Text(detectedText)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.all, 10)
                    }.background(RoundedRectangle(cornerRadius: 20)
                        .fill(Color.black.opacity(0.25)))
                        .opacity(detectedText.isEmpty ? 0.0 : 1.0)
                        .padding(.all, 20)
                }
                
                Spacer()
                
                HStack {
                    Spacer()
                    Button(action: { 
                        context.detectedText = detectedText
                        context.activeView = .Home
                    } ) {
                        ZStack {
                            Image(systemName: "checkmark.circle.fill")
                                .imageScale(.large)
                                .font(.system(size: 30, weight: .medium))
                                .foregroundColor(.blue)
                                .background(Circle().fill(Color.black))
                                .opacity(detectedText.isEmpty ? 0.5 : 1.0)
                        }
                    }
                    .disabled(detectedText.isEmpty)
                    .padding()
                    
                    Spacer()
                    
                    Button(action: {
                        context.detectedText = ""
                        context.activeView = .Home
                    } ) {
                        ZStack {
                            Image(systemName: "xmark.circle.fill")
                                .imageScale(.large)
                                .font(.system(size: 30, weight: .medium))
                                .foregroundColor(.blue)
                                .background(Circle().fill(Color.black))
                        }
                    }
                    .padding()
                    
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    CaptureView()
        .environmentObject(AppContext())
}
