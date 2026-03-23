//
//  ParentNavigationBarHider.swift
//  PlantaxApp
//
//  Created by Dylan Elliott on 23/3/2026.
//

import SwiftUI

/// Walks up the UIKit view-controller hierarchy and hides the nearest
/// `UINavigationController`'s navigation bar. Useful for hiding the
/// navigation chrome that `DocumentGroup` adds around document views.
struct ParentNavigationBarHider: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        HiderViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

private class HiderViewController: UIViewController {
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        hideParentNavigationBar()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideParentNavigationBar()
    }

    private func hideParentNavigationBar() {
        // Walk up past our own SwiftUI hosting/navigation controllers
        // to find the DocumentGroup's UINavigationController.
        var candidate = parent
        while let vc = candidate {
            if let nav = vc.navigationController {
                nav.setNavigationBarHidden(true, animated: false)
                return
            }
            candidate = vc.parent
        }
    }
}

extension View {
    func hidingParentNavigationBar() -> some View {
        background { ParentNavigationBarHider().frame(width: 0, height: 0) }
    }
}
