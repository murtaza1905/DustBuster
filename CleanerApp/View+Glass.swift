import SwiftUI

// MARK: - Adaptive Glass Effect for Views
extension View {
    /// Applies Liquid Glass on macOS 26+, falls back to material background on older versions.
    @ViewBuilder
    func adaptiveGlassEffect<S: Shape>(
        _ material: Material = .ultraThinMaterial,
        in shape: S
    ) -> some View {
        if #available(macOS 26.0, *) {
            self.glassEffect(.regular, in: shape)
        } else {
            self.background(material, in: shape)
        }
    }
}

// MARK: - Adaptive Glass Button Styles
extension View {
    /// Applies glass button style on macOS 26+, falls back to bordered styles on older versions.
    @ViewBuilder
    func adaptiveGlassButtonStyle(prominent: Bool = false) -> some View {
        if #available(macOS 26.0, *) {
            if prominent {
                self.buttonStyle(.glassProminent)
            } else {
                self.buttonStyle(.glass)
            }
        } else {
            if prominent {
                self.buttonStyle(.borderedProminent)
            } else {
                self.buttonStyle(.bordered)
            }
        }
    }
}
