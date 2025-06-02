// SPDX-FileCopyrightText: Nextcloud GmbH
// SPDX-FileCopyrightText: 2025 Iva Horn
// SPDX-License-Identifier: GPL-3.0-or-later

import CodeScanner
import SwiftUI

///
/// The full screen view in which a user enters the address of the server to log in on.
///
public struct ServerAddressView: View, QRCodeParsing, URLSanitizing {
    var delegate: (any ServerAddressViewDelegate)?
    var sharedAccounts: [SharedAccount]
    let userAgent: String?

    ///
    /// Create a new server address.
    ///
    /// - Parameters:
    ///     - backgroundColor: The main theme color the view should use.
    ///     - sharedAccounts: Any shared accounts from the app group being available.
    ///     - userAgent: An optional user agent string to override the one used by ``WKWebView``.
    ///
    public init(backgroundColor: Binding<Color>, delegate: any ServerAddressViewDelegate, sharedAccounts: [SharedAccount], userAgent: String? = nil) {
        self._backgroundColor = backgroundColor
        self.sharedAccounts = sharedAccounts
        self.delegate = delegate
        self.userAgent = userAgent
    }

    // MARK: - Environment

    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass

    // MARK: - Bindings

    @Binding var backgroundColor: Color

    // MARK: - State

    ///
    /// The unsanitized user input.
    ///
    @State var enteredServerAddress = ""

    ///
    /// Message to display in case of error.
    ///
    @State var errorMessage: String?

    ///
    /// Whether there currently is an activity which requires disabling the user interface.
    ///
    @State var isActive = false

    ///
    /// State toggle for presenting the error alert.
    ///
    @State var isPresentingAlert = false

    ///
    /// State toggle for presenting the web view sheet.
    ///
    @State var isPresentingWebView = false

    ///
    /// The login address acquired by the server through the login flow API.
    ///
    @State var loginAddress: URL?

    ///
    /// The temporarily known token to identify the login flow belonging to this view.
    ///
    @State var pollingToken: String?

    // MARK: - Implementation

    public var body: some View {
        ZStack {
            backgroundColor

            VStack {
                Spacer(minLength: 40)

                Image("BrandLogo")
                    .padding(.vertical, 40)

                // Some space between brand logo and server address field.
                if verticalSizeClass == .regular {
                    Spacer()
                        .frame(height: 50)
                }

                // Container to add horizontal spacers for regular size classes.
                HStack {
                    if horizontalSizeClass == .regular {
                        Spacer(minLength: 100)
                    }

                    // Container for the server address input and button.
                    HStack {
                        TextField(
                            text: $enteredServerAddress,
                            prompt: Text(verbatim: "https://example.org/").foregroundColor(.white.opacity(0.5))
                        ) {
                            Text("Server Address", comment: "Label for text field.")
                        }
                        .tint(.white)
                        .textContentType(.URL)
                        .autocorrectionDisabled()
                        #if os(iOS)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .submitLabel(.done)
                        #endif
                        .onSubmit {
                            sanitizeEnteredServerAddressAndLogIn()
                        }

                        if isActive {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .tint(.white)
                        } else {
                            Button {
                                sanitizeEnteredServerAddressAndLogIn()
                            } label: {
                                Image(systemName: "arrow.right")
                            }
                        }
                    }
                    .padding(EdgeInsets(top: 8, leading: 10, bottom: 8, trailing: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.white, lineWidth: 1)
                    )

                    if horizontalSizeClass == .regular {
                        Spacer(minLength: 100)
                    }
                }

                Text("The address of your Nextcloud web interface when you open it in your browser.", comment: "Label below the server address field in the login view.")
                    .font(.footnote)
                    .padding(4)

                Spacer()

                // Buttons for QR code and shared accounts.
                #if os(iOS)
                AlternativeLoginMethodsView(sharedAccounts: sharedAccounts, scanHandler: handleQRCodeScan, selectionHandler: handleSharedAccountSelection)
                #else
                AlternativeLoginMethodsView(sharedAccounts: sharedAccounts, selectionHandler: handleSharedAccountSelection)
                #endif

                Spacer()
            }
            .disabled(isActive)
            .foregroundStyle(.white)
            .padding()
            .safeAreaPadding(.all)
        }
        .ignoresSafeArea()
        .webSheet(initialURL: $loginAddress, isPresented: $isPresentingWebView, userAgent: userAgent, onDismiss: endWebView)
        .alert(String(localized: "Login Failed", comment: "Alert title"), isPresented: $isPresentingAlert) {
            Button(role: .cancel) {
                errorMessage = nil
            } label: {
                Text("OK", comment: "Button label for error alert dismissal.")
            }
        } message: {
            Text(errorMessage ?? "?")
        }
    }

    // MARK: - Logic

    #if os(iOS)
    func handleQRCodeScan(_ result: Result<ScanResult, ScanError>) {
        switch result {
            case .success(let result):
                do {
                    let (name, password, host) = try parse(result.string)
                    delegate?.addAccount(host: host, name: name, password: password)
                } catch {
                    errorMessage = error.localizedDescription
                    isPresentingAlert = true
                    return
                }
            case .failure(let error):
                errorMessage = error.localizedDescription
        }
    }
    #endif

    func handleSharedAccountSelection(_ account: SharedAccount) {
        enteredServerAddress = account.host.absoluteString
        sanitizeEnteredServerAddressAndLogIn(user: account.name)
    }

    ///
    ///
    ///
    func sanitizeEnteredServerAddressAndLogIn(user: String? = nil) {
        guard enteredServerAddress.trimmingCharacters(in: .whitespaces).isEmpty == false else {
            return
        }

        guard let sanitizedServerAddress = sanitize(enteredServerAddress) else {
            errorMessage = String(localized: "The entered server address is invalid.", comment: "This is an error message.")
            isPresentingAlert = true
            return
        }

        guard let delegate else {
            return
        }

        Task {
            var url = try await delegate.beginPolling(at: sanitizedServerAddress)

            if let user {
                url.append(queryItems: [URLQueryItem(name: "user", value: user)])
            }

            self.loginAddress = url
            isPresentingWebView = true
        }
    }

    ///
    /// Dismisses the sheet with the web view.
    ///
    /// Multiple paths can lead to here. In example:
    ///
    /// - The user dismisses the sheet without logging in.
    /// - The login completed successfully.
    ///
    func endWebView() {
        if let pollingToken {
            delegate?.cancelPolling(by: pollingToken)
            self.pollingToken = nil
        }

        isActive = false
        isPresentingWebView = false
    }

    ///
    /// Completing the login process regardless of success or failure.
    ///
    func endLogin(_ error: Error? = nil) {
        endWebView()

        if let error {
            errorMessage = error.localizedDescription
            isPresentingAlert = true
        }
    }
}
