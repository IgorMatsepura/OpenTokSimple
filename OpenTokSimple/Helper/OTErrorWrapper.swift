//
//  OTErrorWrapper.swift
//  OpenTokSimple
//
//  Created by Igor Matsepura on 11.04.2023.
//

import OpenTok
import SwiftUI

struct OTErrorWrapper: Identifiable {
    var id = UUID()
    let error: OTError
    let message: String
}



struct OTView: UIViewRepresentable {
    @State var view: UIView
    
    func makeUIView(context: Context) -> UIView {
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            self.view = uiView
        }
    }
}
