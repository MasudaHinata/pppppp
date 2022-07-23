//
//  ErrorWindow.swift
//  pppppp
//
//  Created by 増田ひなた on 2022/07/23.
//

import UIKit

final class CoverWindow: UIWindow {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if view == self { return nil }
        if view == rootViewController?.view { return nil }
        return view
    }
}
