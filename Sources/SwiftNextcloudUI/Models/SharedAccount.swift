// SPDX-FileCopyrightText: Nextcloud GmbH
// SPDX-FileCopyrightText: 2025 Iva Horn
// SPDX-License-Identifier: GPL-3.0-or-later

import SwiftUI

///
/// View model for shared accounts as used in ``SharedAccountsView``.
///
public struct SharedAccount: Identifiable, Sendable {
    ///
    /// Unique identifier for this view model.
    ///
    public var id: UUID

    ///
    /// The image to present for this shared account.
    ///
    public let image: Image

    ///
    /// The host address of this shared account.
    ///
    public let host: URL

    ///
    /// The login name of this shared account.
    ///
    public let name: String

    ///
    /// Create a new shared account view model.
    ///
    /// - Parameters:
    ///     - name: See ``name``.
    ///     - host: See ``host``.
    ///     - image: See ``image``.
    ///
    public init(_ name: String, on host: URL, with image: Image) {
        self.id = UUID()
        self.name = name
        self.host = host
        self.image = image
    }
}
