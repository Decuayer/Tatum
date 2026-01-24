//
//  ViewControllerHolder.swift
//  Tatum
//
//  Created by Antigravity on 24.01.2026.
//

import SwiftUI
import UIKit

struct ViewControllerHolder {
    weak var value: UIViewController?
}

struct ViewControllerKey: EnvironmentKey {
    static var defaultValue: ViewControllerHolder {
        return ViewControllerHolder(value: UIApplication.shared.windows.first?.rootViewController)
    }
}

extension EnvironmentValues {
    var viewController: UIViewController? {
        get { return self[ViewControllerKey.self].value }
        set { self[ViewControllerKey.self].value = newValue }
    }
}

extension UIViewController {
    func present(swiftUIView: some View, animated: Bool = true, completion: (() -> Void)? = nil) {
        let hostingController = UIHostingController(rootView: swiftUIView)
        present(hostingController, animated: animated, completion: completion)
    }
}
