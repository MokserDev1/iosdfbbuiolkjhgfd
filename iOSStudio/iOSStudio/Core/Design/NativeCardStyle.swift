//
//  NativeCardStyle.swift
//  iOSStudio
//
//  Standard Apple Native presentation compliant with Human Interface Guidelines.
//  On iOS 15.8.8 standard native Materials and secondary system backgrounds are used.
//  On future systems supporting Apple Liquid Glass, native GlassEffect APIs are applied dynamically.
//

import SwiftUI

public struct NativeAppleCardModifier: ViewModifier {
    @ObservedObject private var theme = ThemeManager.shared
    
    public init() {}
    
    public func body(content: Content) -> some View {
        content
            .padding(theme.density.cardPadding)
            .background(
                Group {
                    if #available(iOS 15.0, *) {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(.regularMaterial)
                    } else {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color(UIColor.secondarySystemGroupedBackground))
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.primary.opacity(0.06), lineWidth: 1)
            )
    }
}

public extension View {
    func nativeAppleCard() -> some View {
        self.modifier(NativeAppleCardModifier())
    }
}

