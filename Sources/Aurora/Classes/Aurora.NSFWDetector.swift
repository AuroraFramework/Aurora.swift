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

#if canImport(CoreML) && canImport(Vision) && !os(tvOS) && canImport(UIKit)
import CoreML
import Vision
import UIKit

/// NSFW Detector
///
/// Example
///
///     Aurora.NSFWDetector.shared.check(image: image) { result in
///        switch result {
///        case .error:
///            Aurora.shared.log("Detection failed")
///        case let .success(nsfwConfidence: confidence):
///            Aurora.shared.log(String(format: "%.1f %% NSFW", confidence * 100.0))
///        }
///    }
@available(macOS 10.14, *)
@available(iOS 12.0, *)
public class NSFWDetector {
    /// Singleton for NSFWDetector
    public static let shared = NSFWDetector()

    /// Core ML model used with Vision requests.
    private let model: VNCoreMLModel

    /// Initialize
    public required init() {
        var NSFWModel: MLModel?

        guard let modelURL = Bundle.module.url(forResource: "NSFW", withExtension: "mlmodel") else {
            fatalError("No model found.")
        }

        do {
            let config = MLModelConfiguration().configure {
                $0.computeUnits = .all
            }

            NSFWModel = try MLModel(contentsOf: modelURL, configuration: config)
        } catch {
            fatalError("Error loading model: \(error)")
        }

        guard let model = try? VNCoreMLModel(for: NSFWModel.unwrap()) else {
            fatalError("NSFW should always be a valid model")
        }

        self.model = model
    }

    /// The Result of an NSFW Detection
    ///
    /// - error: Detection was not successful
    /// - success: Detection was successful. `nsfwConfidence`: 0.0 for safe content - 1.0 for hardcore porn ;)
    public enum DetectionResult {
        /// error: Detection was not successful
        case error(Error)

        /// success: Detection was successful. `nsfwConfidence`: 0.0 for safe content - 1.0 for hardcore porn ;)
        case success(nsfwConfidence: Float)
    }

    /// Check the image
    /// - Parameters:
    ///   - image: Image
    ///   - completion: Detection result
    public func check(image: UIImage, completion: @escaping (_ result: DetectionResult) -> Void) {
        // Create a requestHandler for the image
        let requestHandler: VNImageRequestHandler?

#if os(iOS)
        if let cgImage = image.cgImage {
            requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        } else if let ciImage = image.ciImage {
            requestHandler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        } else {
            requestHandler = nil
        }
#endif

#if os(macOS)
        // swiftlint:disable:next force_cast
        let cgImage = image.cgImage as! CGImage

        requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
#endif

#if os(iOS) || os(macOS)
        self.check(requestHandler, completion: completion)
#endif
    }

    /// Check the image (using pixels)
    /// - Parameters:
    ///   - cvPixelbuffer: Pixel buffer
    ///   - completion: On completion
    public func check(cvPixelbuffer: CVPixelBuffer, completion: @escaping (_ result: DetectionResult) -> Void) {
        /// VN Request handler
        let requestHandler = VNImageRequestHandler(
            cvPixelBuffer: cvPixelbuffer,
            options: [:]
        )

        self.check(requestHandler, completion: completion)
    }

    /// Check
    /// - Parameters:
    ///   - requestHandler: VN Request handler
    ///   - completion: Completion
    func check(_ requestHandler: VNImageRequestHandler?,
               completion: @escaping (_ result: DetectionResult) -> Void) {
        guard let requestHandler = requestHandler else {
            completion(
                .error(
                    NSError(
                        domain: "either cgImage or ciImage must be set inside of UIImage",
                        code: 0,
                        userInfo: nil
                    )
                )
            )
            return
        }

        /// The request that handles the detection completion
        let request = VNCoreMLRequest(
            model: self.model,
            completionHandler: { (request, _) in
                guard let observations = request.results as? [VNClassificationObservation],
                      let observation = observations.first(where: { $0.identifier == "NSFW" }) else {
                          completion(
                            .error(
                                NSError(
                                    domain: "Detection failed: No NSFW Observation found",
                                    code: 0,
                                    userInfo: nil
                                )
                            )
                          )

                          return
                      }

                completion(
                    .success(
                        nsfwConfidence: observation.confidence
                    )
                )
            })

        /// Start the actual detection
        do {
            try requestHandler.perform([request])
        } catch {
            completion(
                .error(
                    NSError(
                        domain: "Detection failed: No NSFW Observation found",
                        code: 0,
                        userInfo: nil
                    )
                )
            )
        }
    }
}
#endif
