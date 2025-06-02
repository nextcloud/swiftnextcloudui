<div align="center">
    <img src="SwiftNextcloudUI.svg" alt="Logo of SwiftNextcloudUI" width="256" height="256" />
</div>

# SwiftNextcloudUI

A package to provide common user interface elements of apps by Nextcloud written in SwiftUI.

## Features

- **Login**: From entering the server address over scanning QR codes to offering accounts shared in the app group.
- **Multiplatform**: Views are designed for iPhone and iPad with macOS being checked for compatibility.

## Development

Key traits of this package:

- **Swift 6.1**. Latest language features independent from the consuming projects.
- **Strict concurrency checks enabled**. Avoiding technical debt from the start as far as possible.
- **Built for the future**. Minimum requirements are iOS 17 and macOS 15. This enables the use of modern APIs which improve code and work significantly. [Nextcloud Notes](http://github.com/nextcloud/notes-ios) is the first app to adopt this and already requires iOS 17 by itself. macOS support is not planned officially but maintained as much as possible to keep the door open.
- **SwiftLint**. SwiftLint is used as a build tool plugin to enforce certain code style and quality.
- **Unit tests**. Existing projects did lack test coverage so these are considered where possible.
- **Separation of concerns**. This is a user interface package. It does not implement business logic. It does not even depend on [NextcloudKit](https://github.com/nextcloud/nextcloudkit). The delegate pattern and closures are used instead to leave business logic implementation to consumers of this library.
- **String catalogs**. The user interface naturally contains localizable strings. To leverage latest technologies and learnings, this package is using [string catalogs](https://developer.apple.com/documentation/xcode/localizing-and-varying-text-with-a-string-catalog) to _automatically on build_ update all the localizations in a single resource, including pluralization.

## Documentation

The developer documentation is build automatically in GitHub actions and deployed to GitHub pages.
