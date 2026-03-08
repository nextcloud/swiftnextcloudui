// SPDX-FileCopyrightText: Nextcloud GmbH
// SPDX-FileCopyrightText: 2026 tdhooghe
// SPDX-License-Identifier: GPL-3.0-or-later

import SwiftUI

#if os(iOS)
import AuthenticationServices
#endif

///
/// Presents the Nextcloud Login Flow v2 authentication UI.
///
/// On **iOS**, this uses `ASWebAuthenticationSession` which opens a system browser sheet
/// that properly handles cross-domain OIDC redirects, passkeys, and deep links.
///
/// On **macOS**, this presents a ``WebView`` in a sheet.
///
/// Credentials are obtained via the host app's polling mechanism on both platforms.
///
struct LoginSheet: ViewModifier {
    let userAgent: String?
    let onDismiss: () -> Void

    @Binding var loginURL: URL?
    @Binding var isPresented: Bool

    #if os(iOS)
    @State private var authSession: ASWebAuthenticationSession?
    @State private var sessionCoordinator = SessionCoordinator()
    #endif

    init(loginURL: Binding<URL?>, isPresented: Binding<Bool>, userAgent: String?, onDismiss: @escaping () -> Void) {
        self._loginURL = loginURL
        self._isPresented = isPresented
        self.userAgent = userAgent
        self.onDismiss = onDismiss
    }

    func body(content: Content) -> some View {
        content
            #if os(macOS)
            .sheet(isPresented: $isPresented, onDismiss: onDismiss) {
                WebView(initialURL: $loginURL, userAgent: userAgent)
                    .ignoresSafeArea()
                    .frame(minWidth: 800, minHeight: 800)
            }
            #else
            .onChange(of: isPresented) { _, presented in
                if presented, let url = loginURL {
                    startAuthSession(url: url)
                } else {
                    authSession?.cancel()
                    authSession = nil
                }
            }
            #endif
    }

    #if os(iOS)

    private func startAuthSession(url: URL) {
        let session = ASWebAuthenticationSession(url: url, callbackURLScheme: "nc") { _, error in
            authSession = nil
            if let error = error as? ASWebAuthenticationSessionError, error.code == .canceledLogin {
                onDismiss()
            }
        }

        session.presentationContextProvider = sessionCoordinator
        session.prefersEphemeralWebBrowserSession = true
        authSession = session
        session.start()
    }

    #endif
}

extension View {
    ///
    /// Present the login authentication UI appropriate for the current platform.
    ///
    /// See ``LoginSheet`` for the implementation.
    ///
    func loginSheet(loginURL: Binding<URL?>, isPresented: Binding<Bool>, userAgent: String?, onDismiss: @escaping () -> Void) -> some View {
        modifier(LoginSheet(loginURL: loginURL, isPresented: isPresented, userAgent: userAgent, onDismiss: onDismiss))
    }
}

// MARK: - ASWebAuthenticationSession Coordinator

#if os(iOS)

///
/// Provides the presentation anchor for `ASWebAuthenticationSession` in SwiftUI contexts.
///
@MainActor
private class SessionCoordinator: NSObject, ASWebAuthenticationPresentationContextProviding {
    nonisolated func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return MainActor.assumeIsolated {
            guard let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
                  let window = windowScene.windows.first(where: \.isKeyWindow)
            else {
                return ASPresentationAnchor()
            }
            return window
        }
    }
}

#endif
