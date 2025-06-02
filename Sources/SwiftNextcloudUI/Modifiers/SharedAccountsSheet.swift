// SPDX-FileCopyrightText: Nextcloud GmbH
// SPDX-FileCopyrightText: 2025 Iva Horn
// SPDX-License-Identifier: GPL-3.0-or-later

import SwiftUI

///
/// The sheet wrapping ``SharedAccountsView``.
///
struct SharedAccountsSheet: ViewModifier {
    @Binding var isPresented: Bool

    var sharedAccounts: [SharedAccount]
    let selectionHandler: (SharedAccount) -> Void

    init(isPresented: Binding<Bool>, sharedAccounts: [SharedAccount], selectionHandler: @escaping (SharedAccount) -> Void) {
        self._isPresented = isPresented
        self.sharedAccounts = sharedAccounts
        self.selectionHandler = selectionHandler
    }

    func body(content: Content) -> some View {
        let sharedAccountsView = SharedAccountsView(sharedAccounts: sharedAccounts, selectionHandler: selectionHandler)

        return content.sheet(isPresented: $isPresented) {
            sharedAccountsView.presentationDetents([.medium])
        }
    }
}

extension View {
    ///
    /// Present a sheet to select an account already set up in another app of the same group.
    ///
    /// See ``SharedAccountsSheet`` for its implementation.
    ///
    func sharedAccountsSheet(isPresented: Binding<Bool>, sharedAccounts: [SharedAccount], selectionHandler: @escaping (SharedAccount) -> Void) -> some View {
        modifier(SharedAccountsSheet(isPresented: isPresented, sharedAccounts: sharedAccounts, selectionHandler: selectionHandler))
    }
}

#Preview {
    // swiftlint:disable force_unwrapping
    let accounts = [
        SharedAccount("jane", on: URL(string: "http://localhost:8080")!, with: Image(systemName: "person.circle.fill")),
        SharedAccount("john", on: URL(string: "http://localhost:8081")!, with: Image(systemName: "person.circle.fill")),
        SharedAccount("jean", on: URL(string: "http://localhost:8082")!, with: Image(systemName: "person.circle.fill"))
    ]

    return ZStack {
        Color.blue
            .ignoresSafeArea()
    }
    .sharedAccountsSheet(isPresented: .constant(true), sharedAccounts: accounts) { _ in
        print("Account selected!")
    }
}
