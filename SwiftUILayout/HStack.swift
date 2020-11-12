//
//  HStack.swift
//  SwiftUILayout
//
//  Created by Chris Eidhof on 03.11.20.
//

import SwiftUI

struct HStack_: View_, BuiltinView {
    var children: [AnyView_]
    var alignment: VerticalAlignment_ = .center
    let spacing: CGFloat? = 0
    
    func render(context: RenderingContext, size: CGSize) {
        let sizes = layout(proposed: ProposedSize(size))
        var currentX: CGFloat = 0
        for idx in children.indices {
            let childSize = sizes[idx]
            context.saveGState()
            context.translateBy(x: currentX, y: 0)
            children[idx].render(context: context, size: childSize)
            context.restoreGState()
            currentX += childSize.width
        }
    }
    
    func size(proposed: ProposedSize) -> CGSize {
        let sizes = layout(proposed: proposed)
        let width: CGFloat = sizes.reduce(0) { $0 + $1.width }
        let height: CGFloat = sizes.reduce(0) { max($0, $1.height) }
        return CGSize(width: width, height: height)
    }
    
    func layout(proposed: ProposedSize) -> [CGSize] {
        var remainingWidth = proposed.width! // TODO
        var remaining = children
        var sizes: [CGSize] = []
        while !remaining.isEmpty {
            let width = remainingWidth / CGFloat(remaining.count)
            let child = remaining.removeFirst()
            let size = child.size(proposed: ProposedSize(width: width, height: proposed.height))
            sizes.append(size)
            remainingWidth -= size.width
            // todo check what happens when remaining width < 0
        }
        return sizes
    }
    
    var swiftUI: some View {
        HStack(alignment: alignment.swiftUI, spacing: spacing) {
            ForEach(children.indices, id: \.self) { idx in
                children[idx].swiftUI
            }
        }
    }
}

class AnyViewBase: BuiltinView {
    func render(context: RenderingContext, size: CGSize) {
        fatalError()
    }
    func size(proposed: ProposedSize) -> CGSize {
        fatalError()
    }
}

final class AnyViewImpl<V: View_>: AnyViewBase {
    let view: V
    init(_ view: V) {
        self.view = view
    }
    override func render(context: RenderingContext, size: CGSize) {
        view._render(context: context, size: size)
    }
    override func size(proposed: ProposedSize) -> CGSize {
        view._size(proposed: proposed)
    }
}

struct AnyView_: View_, BuiltinView {
    let swiftUI: AnyView
    let impl: AnyViewBase
    
    init<V: View_>(_ view: V) {
        self.swiftUI = AnyView(view.swiftUI)
        self.impl = AnyViewImpl(view)
    }
    
    func render(context: RenderingContext, size: CGSize) {
        impl.render(context: context, size: size)
    }
    
    func size(proposed: ProposedSize) -> CGSize {
        impl.size(proposed: proposed)
    }
}


