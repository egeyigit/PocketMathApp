//
//  matview.swift
//  learningSwift
//
//  Created by Ege Yiğit Güven on 23.02.2025.
//

//import SwiftUI
//import SwiftMath
//
//struct MathView: UIViewRepresentable {
//    var equation: String
//    var font: MathFont = .latinModernFont
//    var textAlignment: MTTextAlignment = .center
//    var fontSize: CGFloat = 30
//    var labelMode: MTMathUILabelMode = .text
//    var insets: MTEdgeInsets = MTEdgeInsets()
//    
//    func makeUIView(context: Context) -> MTMathUILabel {
//        let view = MTMathUILabel()
//        return view
//    }
//    func updateUIView(_ view: MTMathUILabel, context: Context) {
//        view.latex = equation
//        view.font = MTFontManager().font(withName: font.rawValue, size: fontSize)
//        view.textAlignment = textAlignment
//        view.labelMode = labelMode
//        view.textColor = MTColor(Color.primary)
//        view.contentInsets = insets
//    }
//}

import SwiftUI
import SwiftMath

#if os(iOS)
struct MathView: UIViewRepresentable {
    var equation: String
    var font: MathFont = .latinModernFont
    var textAlignment: MTTextAlignment = .center
    var fontSize: CGFloat = 30
    var labelMode: MTMathUILabelMode = .text
    var insets: MTEdgeInsets = MTEdgeInsets()
    
    func makeUIView(context: Context) -> MTMathUILabel {
        let view = MTMathUILabel()
        return view
    }
    
    func updateUIView(_ view: MTMathUILabel, context: Context) {
        view.latex = equation
        view.font = MTFontManager().font(withName: font.rawValue, size: fontSize)
        view.textAlignment = textAlignment
        view.labelMode = labelMode
        view.textColor = MTColor(Color.primary)
        view.contentInsets = insets
    }
}
#else
struct MathView: NSViewRepresentable {
    var equation: String
    var font: MathFont = .latinModernFont
    var textAlignment: MTTextAlignment = .center
    var fontSize: CGFloat = 30
    var labelMode: MTMathUILabelMode = .text
    var insets: MTEdgeInsets = MTEdgeInsets()
    
    func makeNSView(context: Context) -> MTMathUILabel {
        let view = MTMathUILabel()
        return view
    }
    
    func updateNSView(_ view: MTMathUILabel, context: Context) {
        view.latex = equation
        view.font = MTFontManager().font(withName: font.rawValue, size: fontSize)
        view.textAlignment = textAlignment
        view.labelMode = labelMode
        view.textColor = MTColor(Color.primary)
        view.contentInsets = insets
    }
}

#endif
