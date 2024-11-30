//
//  ContentView.swift
//  TextScope
//
//  Created by Vijayakumar B on 29/08/24.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var context: AppContext
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            Color.gray.opacity(0.2).ignoresSafeArea()
            
            VStack {
                Spacer()
                
                ZStack {
                    VStack {
                        Text(context.detectedText)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.all, 10)
                        HStack {
                            Spacer()
                            if !context.detectedText.isEmpty {
                                Button(action: {
                                    UIPasteboard.general.string = context.detectedText
                                } ) {
                                    ZStack {
                                        Image(systemName: "doc.on.doc.fill")
                                            .imageScale(.large)
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundColor(.blue)
                                    }
                                }.padding(.all, 20)
                            }
                        }.frame(minHeight: 100)
                    }.background {
                        ZStack {
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(.gray.opacity(0.75), lineWidth: 0.5)
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.gray.opacity(0.1))
                        }
                    }
                    
                    Spacer()
                }.padding(.all, 10)
                
                Button(action: { context.activeView = .Camera } ) {
                    ZStack {
                        Image(systemName: "camera.circle.fill")
                            .imageScale(.large)
                            .font(.system(size: 40, weight: .medium))
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

#Preview {
    HomeView()
        .environmentObject(AppContext())
}
