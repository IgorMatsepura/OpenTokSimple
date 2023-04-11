//
//  ContentView.swift
//  OpenTokSimple
//
//  Created by Igor Matsepura on 11.04.2023.
//

import SwiftUI
import OpenTok

struct ContentView: View {
    @ObservedObject var otManager = OpenTokManager()

    var body: some View {
        VStack {
          
            otManager.pubView.flatMap { view in
                OTView(view: view)
                    .frame(height: 200)
            }
            .cornerRadius(5.0)
            
            otManager.subView.flatMap { view in
                   OTView(view: view)
                       .frame(height: 200)
               }
            .cornerRadius(5.0)
//            .frame(maxWidth: .infinity)
            .alert(item: $otManager.error, content: { error -> Alert in
                Alert(title: Text("OpenTok Error"), message: Text(error.message), dismissButton: .default(Text("OK")))
                })
            
            .animation(.default)
                 
        .padding()
    }
        .onAppear(perform: {
            otManager.setup()
        })
}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
