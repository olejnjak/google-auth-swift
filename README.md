# google-auth-swift

Swift library for implementing auth to Google services. The implementation is inspired by [official Google lib](https://github.com/googleapis/google-auth-library-swift), but with modern Swift interface.

## Installation

google-auth-swift is available through SPM, just add it to your Package.swift

```swift
    dependencies: [
        .package(
            url: "https://github.com/olejnjak/google-auth-swift", 
            from: "0.1.0"
        ),
    ],
    targets: [
        .target(
            name: "Target",
            dependencies: [
                .product(
                    name: "GoogleAuth", 
                    package: "google-auth-swift"
                ),
            ]
        ),
    ]
```

## Usage

All token providers share the same interface, so you just need to instantiate correct provider for your use case and call token function, that will fetch token for you
```swift
try await provider.token()
```

Once you get your token, it is recommended to use its helper function to modify required headers on your `URLRequest`

```swift
var request = URLRequest(url: url)
token.add(to: &request)
```

Currently you can use 3 token providers, it is suggested to use `DefaultCredentialsTokenProvider` as it can be safely used in local and also in server environment.

`DefaultCredentialsTokenProvider` implements part of [Google Application Default Credentials](https://cloud.google.com/docs/authentication/application-default-credentials). It internally uses `ServiceAccountTokenProvider` and `GoogleRefreshTokenProvider`.

`ServiceAccountTokenProvider` can be used for getting token from a service account, this should be used in CI environment.

`GoogleRefreshTokenProvider` implements refresh token flow, so it exchanges user's refresh token for a new access token.