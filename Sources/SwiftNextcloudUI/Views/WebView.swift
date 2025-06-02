// SPDX-FileCopyrightText: Nextcloud GmbH
// SPDX-FileCopyrightText: 2025 Iva Horn
// SPDX-License-Identifier: GPL-3.0-or-later

import SwiftUI
import WebKit

///
/// A generic web view which makes `WKWebView` available in SwiftUI which otherwise is not.
///
/// This is the base block for presentation of web-based content.
/// Be it a live website in form of a login process or just a static HTML document about legal matters shipped with the app bundle.
///
/// The web view is inspectable by Safari on connected developer machines for eased debugging.
///
/// All of the web view session data is not persistent.
///
struct WebView: ViewRepresentable {
    ///
    /// This must be a binding to support presentation inside sheets.
    /// The way this view gets created and updated inside a sheet has a race condition with sheet presentation.
    /// A sheet might be displayed before a passed in state variable might have been set.
    ///
    let initialURL: Binding<URL?>
    let userAgent: String?

    func makeView() -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .nonPersistent()

        let webView = WKWebView(frame: CGRect.zero, configuration: configuration)
        webView.isInspectable = true

        if let userAgent {
            webView.customUserAgent = userAgent
        }

        return webView
    }

    func updateView(_ webView: WKWebView, context: Context) {

        guard let initialURL = initialURL.wrappedValue else {
            return
        }

        let request = URLRequest(url: initialURL)
        webView.load(request)
    }

    #if os(macOS)

    typealias NSViewType = WKWebView

    func makeNSView(context: Context) -> WKWebView {
        makeView()
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        updateView(webView, context: context)
    }

    #else

    func makeUIView(context: Context) -> WKWebView {
        makeView()
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        updateView(webView, context: context)
    }

    #endif
}

#Preview {
    // swiftlint:disable force_unwrapping
    WebView(initialURL: .constant(URL(string: "https://www.nextcloud.com")!), userAgent: nil)
}
