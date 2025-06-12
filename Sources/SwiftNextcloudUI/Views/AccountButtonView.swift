// SPDX-FileCopyrightText: Nextcloud GmbH
// SPDX-FileCopyrightText: 2025 Iva Horn
// SPDX-License-Identifier: GPL-3.0-or-later

import SwiftUI

///
/// Account menu to be used in the toolbar.
///
public struct AccountButtonView: View {
    @Binding var activeAccount: Account
    @Binding var accounts: [Account]

    @State var showLogin: Bool = false
    @State var showPopover: Bool
    @State var showSettings: Bool = false

    ///
    /// - Parameters:
    ///     - activeAccount: The currently selected account.
    ///     - accounts: All accounts available for selection.
    ///     - showPopover: Whether the popover is presented by default or not.
    ///
    public init(activeAccount: Binding<Account>, accounts: Binding<[Account]>, showPopover: Bool = false) {
        self._activeAccount = activeAccount
        self._accounts = accounts
        self.showPopover = showPopover
    }

    public var body: some View {
        Button {
            showPopover.toggle()
        } label: {
            activeAccount.image
        }
        .popover(isPresented: $showPopover) {
            VStack {
                ForEach(accounts) { account in
                    HStack(spacing: 0) {
                        Image(systemName: "circle.fill")
                            .resizable()
                            .frame(width: 10, height: 10)
                            .foregroundStyle(activeAccount == account ? Color.accentColor : Color.clear)
                            .padding([.leading, .trailing], 10)

                        account.image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40)
                            .padding(.trailing, 10)

                        VStack(alignment: .leading) {
                            Text(account.name)
                                .foregroundStyle(.primary)

                            Text(account.host.absoluteString)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()
                    }
                    .onTapGesture {
                        selectAccount(account)
                    }
                    .padding(.trailing)
                    .padding(.vertical, 10)

                    Divider()
                }

                HStack {
                    Button {
                        showLogin.toggle()
                    } label: {
                        Image(systemName: "person.fill.badge.plus")
                            .padding(.top, 5)
                            .padding([.leading, .bottom, .trailing])
                    }

                    Spacer()

                    Button {
                        showSettings.toggle()
                    } label: {
                        Image(systemName: "gear")
                            .padding(.top, 5)
                            .padding([.leading, .bottom, .trailing])
                    }
                }
            }
            .presentationCompactAdaptation(.popover)
        }
        .sheet(isPresented: $showLogin) {
            Text("This is the login sheet!")
        }
        .fullScreenCover(isPresented: $showSettings) {
            Text("These are the settings!")
        }
    }

    func selectAccount(_ account: Account) {
        activeAccount = account
    }
}

#Preview {
    // swiftlint:disable force_unwrapping
    let accounts = [
        Account("Jane Doe", on: URL(string: "http://localhost:8080")!, with: Image(systemName: "cat.circle.fill")),
        Account("Ariana Dane", on: URL(string: "http://localhost:33306")!, with: Image(systemName: "dog.circle.fill"))
    ]

    NavigationStack {
        TextField("Something", text: .constant("Derpsson"))
        .toolbar {
            ToolbarItem(placement: .navigation) {
                AccountButtonView(activeAccount: .constant(accounts.first!), accounts: .constant(accounts), showPopover: true)
            }
        }
    }
}
