// SPDX-FileCopyrightText: Nextcloud GmbH
// SPDX-FileCopyrightText: 2025 Iva Horn
// SPDX-License-Identifier: GPL-3.0-or-later

import Foundation

///
/// Requirements for the type implementing the business logic for ``ServerAddressView``.
///
public protocol ServerAddressViewDelegate: AnyObject {
    ///
    /// A new remote user account should be added locally in the persistence of the app.
    ///
    /// This method is required, in example by the QR code scan. The scan happens in domain of this package and circumvents the polling logic of the hosting app.
    ///
    func addAccount(host: URL, name: String, password: String)

    ///
    /// The conforming type should start polling for the login flow status.
    ///
    /// - Parameters:
    ///     - url: The address of the server on which a login flow is to be started.
    ///
    /// - Returns: The delegate must return the address on which the user should enter the login flow which then will be navigated to in the web view of this package.
    ///
    func beginPolling(at url: URL) async throws -> URL

    ///
    /// The login process was cancelled. This can happen intentionally by the user dismissing the related views. The polling can be stopped.
    ///
    /// - Parameters:
    ///     - token: The polling token the login flow is identified by uniquely.
    ///
    func cancelPolling(by token: String)
}
