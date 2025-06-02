// SPDX-FileCopyrightText: Nextcloud GmbH
// SPDX-FileCopyrightText: 2025 Iva Horn
// SPDX-License-Identifier: GPL-3.0-or-later

import Foundation

///
/// Turn user input of a server address into a sanitized URL.
///
/// - Returns: If `input` is a valid URL, then the sanitized `URL` and otherwise `nil`.
///
protocol URLSanitizing {
    func sanitize(_ input: String) -> URL?
}

extension URLSanitizing {
    func sanitize(_ input: String) -> URL? {
        guard input.isEmpty == false else {
            return nil
        }

        guard var components = URLComponents(string: input) else {
            return nil
        }

        if let givenScheme = components.scheme {
            if ["http", "https"].contains(givenScheme) == false {
                return nil
            }
        } else {
            components.scheme = "https"
        }

        guard let url = components.url else {
            return nil
        }

        return url
    }
}
