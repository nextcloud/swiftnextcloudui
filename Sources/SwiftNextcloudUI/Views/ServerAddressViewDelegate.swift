// SPDX-FileCopyrightText: Nextcloud GmbH
// SPDX-FileCopyrightText: 2025 Iva Horn
// SPDX-License-Identifier: GPL-3.0-or-later

import Foundation

///
/// Requirements for the type implementing the business logic for this view.
///
public protocol ServerAddressViewDelegate: AnyObject {
    ///
    /// A new remote user account should be added locally.
    ///
    /// This is required for the QR code scan, in example.
    ///
    func addAccount(host: URL, name: String, password: String)

    ///
    /// The polling can begin.
    ///
    /// - Parameters:
    ///     - url: The server address on which a login flow is to be started.
    ///
    /// - Returns: The address on which the user should start the login flow.
    ///
    func beginPolling(at url: URL) async throws -> URL

    ///
    /// The login process was cancelled on UI level and the polling can be stopped.
    ///
    /// - Parameters:
    ///     - token: The polling token the login flow is identified by uniquely.
    ///
    func cancelPolling(by token: String)
}
