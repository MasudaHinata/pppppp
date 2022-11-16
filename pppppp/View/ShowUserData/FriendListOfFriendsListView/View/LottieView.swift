import Foundation
import SwiftUI
import UIKit
import Lottie

struct LottieView: UIViewRepresentable {
    var name: String
    var contentMode: UIView.ContentMode
    var loopMode: LottieLoopMode
    var animationView = LottieAnimationView()
    func makeUIView(context: UIViewRepresentableContext<LottieView>) -> UIView {
        let view = UIView(frame: .zero)
        animationView.animation = Animation.named(name)
        animationView.contentMode = contentMode
        animationView.loopMode = loopMode
        animationView.play()
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        NSLayoutConstraint.activate([
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
        return view
    }
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<LottieView>) {
    }
}
