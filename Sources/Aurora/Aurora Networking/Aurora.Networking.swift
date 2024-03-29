// Aurora framework for Swift
//
// The **Aurora.framework** contains a base for your project.
//
// It has a lot of extensions built-in to make development easier.
//
// - Version: 1.0
// - Copyright: [Wesley de Groot](https://wesleydegroot.nl) ([WDGWV](https://wdgwv.com))\
//  and [Contributors](https://github.com/AuroraFramework/Aurora.swift/graphs/contributors).
//
// Thanks for using!
//
// Licence: MIT

import Foundation

#if canImport(Security)
import Security
#endif

#if canImport(UIKit)
import UIKit
#endif

#if !targetEnvironment(simulator)
#if canImport(CommonCrypto)
import CommonCrypto
#endif
#endif

@available(tvOS 12.0, *)
extension Aurora {
    /// All the cookies
    static var cookies: [HTTPCookie]? = []

    /// the full networkRequestResponse
    static var fullResponse: String? = ""

    /// The dispatch group
    static let group: DispatchGroup = .init()

    struct HTTPSCertificate {
        /// Server's public key hash
        static var publicKeyHash = ""

        /// Server's certificate hash
        static var certificateHash = ""
    }

    /// HTTP Method
    public enum HTTPMethod {
        /// POST
        ///
        /// Post a file or form
        case post

        /// GET
        ///
        /// Just a regular request to a webserver
        case get
    }

    /// Set hash of the server's certificate
    ///
    /// This saves the hash of the server's certificate
    ///
    /// - parameter certificateHash: Server's certificate hash
    public func set(certificateHash: String) {
        HTTPSCertificate.certificateHash = certificateHash
    }

    /// Set hash of the server's public key
    ///
    /// This saves the hash of the server's public key
    ///
    /// - parameter publicKeyHash: Server's public key hash
    public func set(publicKeyHash: String) {
        HTTPSCertificate.publicKeyHash = publicKeyHash
    }

    /// Get hash of the server's certificate
    ///
    /// This gets the hash of the server's certificate
    ///
    /// - returns Server's certificate hash
    public func getCertificateHash() -> String {
        return HTTPSCertificate.certificateHash
    }

    /// Get hash of the server's public key
    ///
    /// This gets the hash of the server's public key
    ///
    /// - returns Server's public key hash
    public func getPublicKeyHash() -> String {
        return HTTPSCertificate.publicKeyHash
    }

    /// Creates a network request that retrieves the contents of a URL \
    /// based on the specified URL request object and returns the data on completion
    ///
    ///
    ///
    /// - Parameters:
    ///   - url: A value that identifies the location of a resource, \
    ///   such as an item on a remote server or the path to a local file.
    ///   - method: The HTTP request method.
    ///   - values: POST values (if any)
    /// - Returns: The HTTP(S) request data
    /// - Note: This function uses the non blocking function \
    /// ``networkRequest(url:method:values:completionHandler:)`` and makes it blocking
    public func networkRequest(
        url: String,
        method: HTTPMethod,
        values: [String: Any]?
    ) -> Data? {
        var result: Data?
        var inGroup = true
        var waiting = true
        let dGroup = Aurora.group

        dGroup.enter()

        DispatchQueue.main.asyncAfter(deadline: .now() + Aurora.shared.timeout) {
            if waiting {
                Aurora.shared.log(
                    AuroraError(message: "Aurora.networking.timeout")
                )

                if inGroup {
                    dGroup.leave()
                }
            }
        }

        Aurora.shared.networkRequest(
            url: url,
            method: method,
            values: values) { response in
                waiting = false

                switch response {
                case .success(let data):
                    result = data
                case .failure(let error):
                    Aurora.shared.log("Failed: \(error.localizedDescription)")
                }

                if inGroup {
                    dGroup.leave()
                }
            }

        dGroup.wait()

        inGroup = false
        return result
    }

    // swiftlint:disable function_body_length
    /// Creates a network request that retrieves the contents of a URL \
    /// based on the specified URL request object, and calls a handler upon completion.
    ///
    /// Example:
    ///
    ///     self.networkRequest(url: url, method: .post, values: posting) { result in
    ///       switch result {
    ///         case .success(let data):
    ///           // do something with the data
    ///
    ///         case .failure(let error):
    ///           // Do something with the error
    ///       }
    ///     }
    ///
    /// - Parameters:
    ///   - url: A value that identifies the location of a resource, \
    ///   such as an item on a remote server or the path to a local file.
    ///   - method: The HTTP request method.
    ///   - values: POST values (if any)
    ///   - completionHandler: This completion handler takes the following parameters:
    ///   `Result<Data, Error>`
    ///     - `Data`: The data returned by the server.
    ///     - `Error`: An error object that indicates why the request failed, or nil if the request was successful.
    public func networkRequest(
        url: String,
        method: HTTPMethod,
        values: [String: Any]?,
        completionHandler: @escaping (Result<Data, Error>) -> Void
    ) {
        /// Check if the URL is valid
        guard let siteURL = URL(string: url) else {
            completionHandler(
                .failure(
                    AuroraError(message: "Aurora.networking.invalidURL")
                )
            )

            return
        }

        /// Create a new post dict, for the JSON String
        var post: String = ""

        // Try
        do {
            if let safeValues = values {
                /// Create JSON
                let JSON = try JSONSerialization.data(
                    withJSONObject: safeValues,
                    options: .sortedKeys
                )

                // set NewPosting
                post = String.init(
                    data: JSON,
                    encoding: .utf8
                ).unwrap(orError: "Failed to generate POST")
                    .addingPercentEncoding(withAllowedCharacters: .urlHostAllowed
                    ).unwrap(orError: "Failed to add Percent encoding")
            }
        }

        /// Catch errors
        catch let error as NSError {
            completionHandler(
                .failure(
                    AuroraError(message: "Error: \(error.description)")
                )
            )
        }

        /// Create a URL Request
        let request = URLRequest(url: siteURL).configure {
            // 30 Seconds before timeout (default)
            $0.timeoutInterval = Aurora.shared.timeout
            // Set Content-Type to FORM
            $0.setValue("close", forHTTPHeaderField: "Connection")
            $0.setValue(self.userAgent, forHTTPHeaderField: "User-Agent")

            if method == .post {
                // We're posting

                // Set the HTTP Method to POST
                $0.httpMethod = "POST"

                // Set Content-Type to FORM
                $0.setValue(
                    "application/x-www-form-urlencoded",
                    forHTTPHeaderField: "Content-Type"
                )

                // Set the httpBody
                $0.httpBody = post.data(using: .utf8)
            } else if method == .get {
                // We're getting

                // Set the HTTP Method to GET
                $0.httpMethod = "GET"
            } else {
                completionHandler(
                    .failure(
                        AuroraError(message: "Unknown method: \(method)")
                    )
                )
            }
        }

        /// Create a pinned URLSession
        var session: URLSession? = URLSession.init(
            // With default configuration
            configuration: .default,

            // With our pinning delegate
            delegate: AuroraURLSessionPinningDelegate(),

            // with no queue
            delegateQueue: nil
        )

        // Check if we have a public key, or certificate hash.
        if HTTPSCertificate.publicKeyHash.isBlank || HTTPSCertificate.certificateHash.isBlank {
            // Show a error, only on debug builds
            log(
                "[WARNING] No Public key pinning/Certificate pinning\n" +
                "           Improve your security to enable this!\n"
            )
            // Use a non-pinned URLSession
            session = URLSession.shared
        }

        if let cookieData = Aurora.cookies {
            session?.configuration.httpCookieStorage?.setCookies(
                cookieData,
                for: siteURL,
                mainDocumentURL: nil
            )
        }

        // Start our datatask
        session?.dataTask(with: request) { (sitedata, _, theError) in
            if let errorMessage = theError {
                completionHandler(.failure(errorMessage))
                return
            }

            /// Check if we got any useable site data
            guard let sitedata = sitedata else {
                completionHandler(.failure(
                    AuroraError.init(message: "Failed to decode the data")
                ))
                return
            }

            // Save our cookies
            Aurora.cookies = session?.configuration.httpCookieStorage?.cookies

            // Save full response
            Aurora.fullResponse = String.init(data: sitedata, encoding: .utf8)

            // Complete
            completionHandler(.success(sitedata))
        }.resume()

        // Release the session from memory
        session = nil
    }
    // swiftlint:enable function_body_length

    /// Return the full networkRequestResponse
    /// - Returns: the full networkRequestResponse
    public func networkRequestResponse() -> String? {
        return Aurora.fullResponse
    }
}
