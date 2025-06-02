// SPDX-FileCopyrightText: Nextcloud GmbH
// SPDX-FileCopyrightText: 2025 Iva Horn
// SPDX-License-Identifier: GPL-3.0-or-later

@testable import SwiftNextcloudUI
import Testing

///
/// Test subject which conforms to ``URLSanitizing``.
///
struct URLSanitizingTestSubject: URLSanitizing {}

///
/// Tests for ``URLSanitizing``.
///
struct URLSanitizingTests {
    let testSubject: URLSanitizingTestSubject

    init() {
        testSubject = URLSanitizingTestSubject()
    }

    @Test func emptyString() async throws {
        try #require(testSubject.sanitize("") == nil)
    }

    @Test func invalidScheme() async throws {
        try #require(testSubject.sanitize("ssh://www.nextcloud.com") == nil)
    }

    @Test func validURL() async throws {
        try #require(testSubject.sanitize("https://www.nextcloud.com") != nil)
    }
}
