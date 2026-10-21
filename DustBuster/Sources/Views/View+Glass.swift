import SwiftUI

// MARK: - Adaptive Glass Effect for Views
// Liquid Glass API'si yalnızca Xcode 26 (Swift 6.2) SDK'sında vardır; eski Xcode ile derlenirken
// `#available` tek başına yetmez, çağrının kendisi derleyiciden gizlenmelidir.
extension View {
    /// Applies Liquid Glass on macOS 26+, falls back to material background on older versions.
    @ViewBuilder
    func adaptiveGlassEffect<S: Shape>(
        _ material: Material = .ultraThinMaterial,
        in shape: S
    ) -> some View {
        #if compiler(>=6.2)
        if #available(macOS 26.0, *) {
            self.glassEffect(.regular, in: shape)
        } else {
            self.background(material, in: shape)
        }
        #else
        self.background(material, in: shape)
        #endif
    }
}

// MARK: - Adaptive Glass Button Styles
extension View {
    /// Applies glass button style on macOS 26+, falls back to bordered styles on older versions.
    @ViewBuilder
    func adaptiveGlassButtonStyle(prominent: Bool = false) -> some View {
        #if compiler(>=6.2)
        if #available(macOS 26.0, *) {
            if prominent {
                self.buttonStyle(.glassProminent)
            } else {
                self.buttonStyle(.glass)
            }
        } else {
            adaptiveBorderedButtonStyle(prominent: prominent)
        }
        #else
        adaptiveBorderedButtonStyle(prominent: prominent)
        #endif
    }

    @ViewBuilder
    private func adaptiveBorderedButtonStyle(prominent: Bool) -> some View {
        if prominent {
            self.buttonStyle(.borderedProminent)
        } else {
            self.buttonStyle(.bordered)
        }
    }
}
