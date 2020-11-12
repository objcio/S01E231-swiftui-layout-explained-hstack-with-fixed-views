//
//  Misc.swift
//  SwiftUILayout
//
//  Created by Florian Kugler on 26-10-2020.
//

import SwiftUI

struct Border<Content: View_>: View_, BuiltinView {
    var color: NSColor
    var width: CGFloat
    var content: Content
    
    func size(proposed: ProposedSize) -> CGSize {
        content._size(proposed: proposed)
    }
    
    func render(context: RenderingContext, size: CGSize) {
        content._render(context: context, size: size)
        context.saveGState()
        context.setStrokeColor(color.cgColor)
        context.stroke(CGRect(origin: .zero, size: size).insetBy(dx: width/2, dy: width/2), width: width)
        context.restoreGState()
    }
    
    var swiftUI: some View {
        content.swiftUI.border(Color(color), width: width)
    }
}

struct Overlay<Content: View_, O: View_>: View_, BuiltinView {
    let content: Content
    let overlay: O
    let alignment: Alignment_
    
    func render(context: RenderingContext, size: CGSize) {
        content._render(context: context, size: size)
        let childSize = overlay._size(proposed: ProposedSize(size))
        context.saveGState()
        context.align(childSize, in: size, alignment: alignment)
        overlay._render(context: context, size: childSize)
        context.restoreGState()
    }
    
    func size(proposed: ProposedSize) -> CGSize {
        content._size(proposed: proposed)
    }
    
    var swiftUI: some View {
        content.swiftUI.overlay(overlay.swiftUI, alignment: alignment.swiftUI)
    }
}

extension View_ {
    func border(_ color: NSColor, width: CGFloat) -> some View_ {
        Border(color: color, width: width, content: self)
    }
    
    func overlay<O: View_>(_  overlay: O, alignment: Alignment_ = .center) -> some View_  {
        Overlay(content: self, overlay: overlay, alignment: alignment)
    }
}

struct GeometryReader_<Content: View_>: View_, BuiltinView {
    let content: (CGSize) -> Content
    
    func render(context: RenderingContext, size: CGSize) {
        let child = content(size)
        let childSize = child._size(proposed: ProposedSize(size))
        context.saveGState()
        context.align(childSize, in: size, alignment: .center)
        child._render(context: context, size: childSize)
        context.restoreGState()
    }
    
    func size(proposed: ProposedSize) -> CGSize {
        return proposed.orDefault
    }
    
    var swiftUI: some View {
        GeometryReader { proxy in
            content(proxy.size).swiftUI
        }
    }
}

struct FixedSize<Content: View_>: View_, BuiltinView {
    var content: Content
    var horizontal: Bool
    var vertical: Bool
    
    func render(context: RenderingContext, size: CGSize) {
        content._render(context: context, size: size)
    }
    
    func size(proposed p: ProposedSize) -> CGSize {
        var proposed = p
        if horizontal { proposed.width = nil }
        if vertical { proposed.height = nil }
        return content._size(proposed: proposed)
    }
    
    var swiftUI: some View {
        content.swiftUI.fixedSize(horizontal: horizontal, vertical: vertical)
    }
}

extension View_ {
    func fixedSize(horizontal: Bool  = true, vertical: Bool  = true) -> some View_ {
        FixedSize(content: self, horizontal: horizontal, vertical: vertical)
    }
}
