// SPDX-FileCopyrightText: Nextcloud GmbH
// SPDX-FileCopyrightText: 2025 Iva Horn
// SPDX-License-Identifier: GPL-3.0-or-later

import SwiftUI

///
/// The view informing the user about shared accounts available for selection and offering a list to select from.
///
struct SharedAccountsView: View {
    var sharedAccounts: [SharedAccount]

    let selectionHandler: (SharedAccount) -> Void

    init(sharedAccounts: [SharedAccount], selectionHandler: @escaping (SharedAccount) -> Void) {
        self.selectionHandler = selectionHandler
        self.sharedAccounts = sharedAccounts
    }

    var body: some View {
        NavigationStack {
            VStack {
                Text("Accounts from our other apps were found on this device. Would you like to add one of these?")
                    .padding()

                List {
                    ForEach(sharedAccounts) { sharedAccount in
                        HStack {
                            sharedAccount
                                .image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 40, height: 40)
                                .padding(.trailing, 8)

                            VStack(alignment: .leading) {
                                Text(sharedAccount.name)
                                Text(sharedAccount.host.absoluteString)
                                    .foregroundStyle(.secondary)
                                    .font(.subheadline)
                            }
                        }
                        .onTapGesture {
                            selectionHandler(sharedAccount)
                        }
                    }
                }
                .listStyle(.plain)
                .navigationTitle(String(localized: "Shared Accounts", comment: "Navigation bar title"))
                #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
                #endif
            }
        }
    }
}

#Preview {
    // swiftlint:disable force_unwrapping
    let accounts = [
        SharedAccount("jane", on: URL(string: "http://localhost:8080")!, with: Image(systemName: "person.circle.fill")),
        SharedAccount("john", on: URL(string: "http://localhost:8081")!, with: Image(systemName: "person.circle.fill")),
        SharedAccount("jean", on: URL(string: "http://localhost:8082")!, with: Image(systemName: "person.circle.fill"))
    ]

    return SharedAccountsView(sharedAccounts: accounts) { _ in
        print("Account selected!")
    }
}
