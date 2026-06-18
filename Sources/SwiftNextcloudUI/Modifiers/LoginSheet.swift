// SPDX-FileCopyrightText: Nextcloud GmbH
// SPDX-FileCopyrightText: 2025 tdhooghe
// SPDX-License-Identifier: GPL-3.0-or-later

import SwiftUI

///
/// Presents the Nextcloud Login Flow v2 authentication UI using the system browser.
///
/// Uses SwiftUI's `webAuthenticationSession`, which handles cross-domain OIDC redirects,
/// passkeys, and deep links on both iOS and macOS.
///
/// Credentials are obtained via the host app's polling mechanism. The browser session has
/// no callback to complete, so it is cancelled once polling reports success (when
/// `isPresented` becomes `false`).
///
struct LoginSheet: ViewModifier {
    @Environment(\.webAuthenticationSession) private var webAuthenticationSession

    let onDismiss: () -> Void

    @Binding var loginURL: URL?
    @Binding var isPresented: Bool

    @State private var authenticationTask: Task<Void, Never>?

    init(loginURL: Binding<URL?>, isPresented: Binding<Bool>, onDismiss: @escaping () -> Void) {
        self._loginURL = loginURL
        self._isPresented = isPresented
        self.onDismiss = onDismiss
    }

    func body(content: Content) -> some View {
        content.onChange(of: isPresented) { _, presented in
            if presented, let loginURL {
                startAuthentication(url: loginURL)
            } else {
                authenticationTask?.cancel()
                authenticationTask = nil
            }
        }
    }

    private func startAuthentication(url: URL) {
        authenticationTask = Task {
            defer { authenticationTask = nil }
            do {
                _ = try await webAuthenticationSession.authenticate(
                    using: url,
                    callbackURLScheme: "nc",
                    preferredBrowserSession: .ephemeral)
            } catch {
                if !Task.isCancelled {
                    onDismiss()
                }
            }
        }
    }
}

extension View {
    ///
    /// Present the Nextcloud login authentication UI using the system browser.
    ///
    /// See ``LoginSheet`` for the implementation.
    ///
    func loginSheet(loginURL: Binding<URL?>, isPresented: Binding<Bool>, onDismiss: @escaping () -> Void) -> some View {
        modifier(LoginSheet(loginURL: loginURL, isPresented: isPresented, onDismiss: onDismiss))
    }
}
