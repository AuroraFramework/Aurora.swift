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

// Original non-modified:
// https://github.com/PiXeL16/RevealingSplashView
// Added: .init(.... backgroundView: yourview)
// Better handling of the onComplete.

// swiftlint:disable file_length
#if canImport(UIKit) && !os(watchOS) &&  !os(visionOS)
import UIKit

/// Protocol that represents splash animatable functionality
public protocol SplashAnimatable: AnyObject {

    /// The image view that shows the icon
    var imageView: UIImageView? { get set }

    /// The animation type
    var animationType: SplashAnimationType { get set }

    /// The duration of the overall animation
    var duration: Double { get set }

    /// The delay to play the animation
    var delay: Double { get set }

    /// The trigger to stop heartBeat animation
    var heartAttack: Bool { get set }

    /// The minimum number of beats before removing the splash view
    var minimumBeats: Int { get set }
}

/// The types of animation supported
/// - Twitter: The default animation type is the Twitter App animation
public enum SplashAnimationType: String {
    case twitter
    case rotateOut
    case woobleAndZoomOut
    case swingAndZoomOut
    case popAndZoomOut
    case squeezeAndZoomOut
    case heartBeat

}

// swiftlint:disable:next type_body_length
open class AnimatedSplashScreen: UIView, SplashAnimatable {
    /// The icon image to show and reveal with
    open var iconImage: UIImage? {
        didSet {
            if let iconImage = self.iconImage {
                imageView?.image = iconImage
            }
        }
    }

    /// The icon color of the image, defaults to white
    open var iconColor: UIColor = UIColor.white {
        didSet {
            imageView?.tintColor = iconColor
        }
    }

    open var useCustomIconColor: Bool = false {
        didSet {
            if useCustomIconColor == true {
                if let iconImage = self.iconImage {
                    imageView?.image = iconImage.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
                }
            } else {
                if let iconImage = self.iconImage {
                    imageView?.image = iconImage.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
                }
            }
        }
    }

    /// The initial size of the icon. Ideally it has to match with the size of the icon in your LaunchScreen Splash view
    open var iconInitialSize: CGSize = CGSize(width: 60, height: 60) {
        didSet {
            imageView?.frame = CGRect(x: 0, y: 0, width: iconInitialSize.width, height: iconInitialSize.height)
        }
    }

    /// The image view containing the background Image
    open var backgroundImageView: UIImageView?

    /// THe image view containing the icon Image
    open var imageView: UIImageView?

    /// The type of animation to use for the. Defaults to the twitter default animation
    open var animationType: SplashAnimationType = SplashAnimationType.twitter

    /// The duration of the animation, default to 1.5 seconds. In the case of heartBeat animation recommended value is 3
    open var duration: Double = 1.5

    /// The delay of the animation, default to 0.5 seconds
    open var delay: Double = 0.5

    /// The boolean to stop the heart beat animation, default to false (continuous beat)
    open var heartAttack: Bool = false

    /// The repeat counter for heart beat animation, default to 1
    open var minimumBeats: Int = 1

    /// Default constructor of the class
    ///
    ///  - parameter iconImage:       The Icon image to show the animation
    ///      - parameter iconInitialSize: The initial size of the icon image
    ///      - parameter backgroundColor: The background color of the image, ideally this should match your Splash view
    ///
    /// - returns: The created RevealingSplashViewObject
    public init(iconImage: UIImage, iconInitialSize: CGSize, backgroundColor: UIColor) {
        // Sets the initial values of the image view and icon view
        self.imageView = UIImageView()
        self.iconImage = iconImage
        self.iconInitialSize = iconInitialSize
        // Inits the view to the size of the screen
        super.init(frame: (UIScreen.main.bounds))

        imageView?.image = iconImage
        imageView?.tintColor = iconColor
        // Set the initial size and position
        imageView?.frame = CGRect(x: 0, y: 0, width: iconInitialSize.width, height: iconInitialSize.height)
        // Sets the content mode and set it to be centered
        imageView?.contentMode = UIView.ContentMode.scaleAspectFit
        imageView?.center = self.center

        // Adds the icon to the view
        guard let imageView = imageView else {
            fatalError("No image view to process.")
        }

        self.addSubview(imageView)

        // Sets the background color
        self.backgroundColor = backgroundColor

    }

    public init(iconImage: UIImage, iconInitialSize: CGSize, backgroundImage: UIImage) {
        // Sets the initial values of the image view and icon view
        self.imageView = UIImageView()
        self.iconImage = iconImage
        self.iconInitialSize = iconInitialSize
        // Inits the view to the size of the screen
        super.init(frame: (UIScreen.main.bounds))

        imageView?.image = iconImage
        imageView?.tintColor = iconColor
        // Set the initial size and position
        imageView?.frame = CGRect(x: 0, y: 0, width: iconInitialSize.width, height: iconInitialSize.height)
        // Sets the content mode and set it to be centered
        imageView?.contentMode = UIView.ContentMode.scaleAspectFit
        imageView?.center = self.center

        // Sets the background image
        self.backgroundImageView = UIImageView()
        backgroundImageView?.image = backgroundImage
        backgroundImageView?.frame = UIScreen.main.bounds
        backgroundImageView?.contentMode = UIView.ContentMode.scaleAspectFill

        self.addSubview(
            backgroundImageView.unwrap(orError: "Aurora.Animate.Splash.noBG")
        )

        // Adds the icon to the view
        self.addSubview(
            imageView.unwrap(orError: "Aurora.Animate.Splash.noImageView")
        )
    }

    public init(iconImage: UIImage, iconInitialSize: CGSize, backgroundView: UIView) {
        // Sets the initial values of the image view and icon view
        self.imageView = UIImageView()
        self.iconImage = iconImage
        self.iconInitialSize = iconInitialSize
        // Inits the view to the size of the screen
        super.init(frame: (UIScreen.main.bounds))

        imageView?.image = iconImage
        imageView?.tintColor = iconColor
        // Set the initial size and position
        imageView?.frame = CGRect(x: 0, y: 0, width: iconInitialSize.width, height: iconInitialSize.height)
        // Sets the content mode and set it to be centered
        imageView?.contentMode = UIView.ContentMode.scaleAspectFit
        imageView?.center = self.center

        // Sets the background view
        backgroundView.contentMode = UIView.ContentMode.scaleAspectFill

        self.addSubview(backgroundView)

        // Adds the icon to the view

        self.addSubview(
            imageView.unwrap(orError: "No image view")
        )
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented".auroraTranslate)
    }

    /// Starts the animation depending on the type
    public func startAnimation(_ completion: AuroraBlock? = nil) {
        switch animationType {
        case .twitter:
            playTwitterAnimation(completion)

        case .rotateOut:
            playRotateOutAnimation(completion)

        case .woobleAndZoomOut:
            playWoobleAnimation(completion)

        case .swingAndZoomOut:
            playSwingAnimation(completion)

        case .popAndZoomOut:
            playPopAnimation(completion)

        case .squeezeAndZoomOut:
            playSqueezeAnimation(completion)

        case .heartBeat:
            playHeartBeatAnimation(completion)
        }
    }

    /// Plays the twitter animation
    func playTwitterAnimation(_ completion: AuroraBlock? = nil) {
        if let imageView = self.imageView {
            // Define the shink and grow duration based on the duration parameter
            let shrinkDuration: TimeInterval = duration * 0.3

            // Plays the shrink animation
            UIView.animate(
                withDuration: shrinkDuration,
                delay: delay,
                usingSpringWithDamping: 0.7,
                initialSpringVelocity: 10,
                options: UIView.AnimationOptions(),
                animations: {
                    // Shrinks the image
                    let scaleTransform: CGAffineTransform = CGAffineTransform(scaleX: 0.75, y: 0.75)
                    imageView.transform = scaleTransform
                },
                completion: { _ in
                    // When animation completes, grow the image
                    self.playZoomOutAnimation(completion)
                }
            )
        }
    }

    /// Plays the Squeeze animation
    func playSqueezeAnimation(_ completion: AuroraBlock? = nil) {
        if let imageView = self.imageView {
            // Define the shink and grow duration based on the duration parameter
            let shrinkDuration: TimeInterval = duration * 0.5

            // Plays the shrink animation
            UIView.animate(
                withDuration: shrinkDuration,
                delay: delay / 3,
                usingSpringWithDamping: 10,
                initialSpringVelocity: 10,
                options: UIView.AnimationOptions(),
                animations: {
                // Shrinks the image
                let scaleTransform: CGAffineTransform = CGAffineTransform(scaleX: 0.30, y: 0.30)
                imageView.transform = scaleTransform

                // When animation completes, grow the image
            }, completion: { _ in
                self.playZoomOutAnimation(completion)
            })
        }
    }

    /// Plays the rotate out animation
    ///
    /// - parameter completion: when the animation completes
    func playRotateOutAnimation(_ completion: AuroraBlock? = nil) {
        if let imageView = self.imageView {
            /// Sets the animation with duration delay and completion
            UIView.animate(
                withDuration: duration,
                delay: delay,
                usingSpringWithDamping: 0.5,
                initialSpringVelocity: 3,
                options: UIView.AnimationOptions(),
                animations: {

                // Sets a simple rotate
                let rotateTranform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * 0.99))

                // Mix the rotation with the zoom out animation
                imageView.transform = rotateTranform.concatenating(self.getZoomOutTranform())

                // Removes the animation
                self.alpha = 0
            }, completion: { _ in
                self.removeFromSuperview()
                completion?()
            })

        }
    }

    /// Plays a wobble animtion and then zoom out
    ///
    /// - parameter completion: completion
    func playWoobleAnimation(_ completion: AuroraBlock? = nil) {
        if let imageView = self.imageView {

            let woobleForce = 0.5

            animateLayer({
                let rotation = CAKeyframeAnimation(keyPath: "transform.rotation")
                rotation.values = [0, 0.3 * woobleForce, -0.3 * woobleForce, 0.3 * woobleForce, 0]
                rotation.keyTimes = [0, 0.2, 0.4, 0.6, 0.8, 1]
                rotation.isAdditive = true

                let positionX = CAKeyframeAnimation(keyPath: "position.x")
                positionX.values = [0, 30 * woobleForce, -30 * woobleForce, 30 * woobleForce, 0]
                positionX.keyTimes = [0, 0.2, 0.4, 0.6, 0.8, 1]
                positionX.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
                positionX.isAdditive = true

                let animationGroup = CAAnimationGroup()
                animationGroup.animations = [rotation, positionX]
                animationGroup.duration = CFTimeInterval(self.duration/2)
                animationGroup.beginTime = CACurrentMediaTime() + CFTimeInterval(self.delay/2)
                animationGroup.repeatCount = 2
                imageView.layer.add(animationGroup, forKey: "wobble")
            }, completion: {

                self.playZoomOutAnimation(completion)
            })

        }
    }

    /// Plays the swing animation and zoom out
    /// - parameter completion: completion
    func playSwingAnimation(_ completion: AuroraBlock? = nil) {
        if let imageView = self.imageView {

            let swingForce = 0.8

            animateLayer({

                let animation = CAKeyframeAnimation(keyPath: "transform.rotation")
                animation.values = [0, 0.3 * swingForce, -0.3 * swingForce, 0.3 * swingForce, 0]
                animation.keyTimes = [0, 0.2, 0.4, 0.6, 0.8, 1]
                animation.duration = CFTimeInterval(self.duration/2)
                animation.isAdditive = true
                animation.repeatCount = 2
                animation.beginTime = CACurrentMediaTime() + CFTimeInterval(self.delay/3)
                imageView.layer.add(animation, forKey: "swing")

            }, completion: {
                self.playZoomOutAnimation(completion)
            })
        }
    }

    /// Plays the pop animation with completion
    /// - parameter completion: completion
    func playPopAnimation(_ completion: AuroraBlock? = nil) {
        if let imageView = self.imageView {

            let popForce = 0.5

            animateLayer({
                let animation = CAKeyframeAnimation(keyPath: "transform.scale")
                animation.values = [0, 0.2 * popForce, -0.2 * popForce, 0.2 * popForce, 0]
                animation.keyTimes = [0, 0.2, 0.4, 0.6, 0.8, 1]
                animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
                animation.duration = CFTimeInterval(self.duration/2)
                animation.isAdditive = true
                animation.repeatCount = 2
                animation.beginTime = CACurrentMediaTime() + CFTimeInterval(self.delay/2)
                imageView.layer.add(animation, forKey: "pop")
            }, completion: {
                self.playZoomOutAnimation(completion)
            })
        }
    }

    /// Plays the zoom out animation with completion
    /// - parameter completion: completion
    func playZoomOutAnimation(_ completion: AuroraBlock? = nil) {
        if let imageView = imageView {
            let growDuration: TimeInterval =  duration * 0.3
            completion?()

            UIView.animate(withDuration: growDuration, animations: {
                imageView.transform = self.getZoomOutTranform()
                self.alpha = 0

                // When animation completes remote self from super view
            }, completion: { _ in
                self.removeFromSuperview()
            })
        }
    }

    /// Retuns the default zoom out transform to be use mixed with other transform
    /// - returns: ZoomOut fransfork
    fileprivate func getZoomOutTranform() -> CGAffineTransform {
        let zoomOutTranform: CGAffineTransform = CGAffineTransform(scaleX: 20, y: 20)
        return zoomOutTranform
    }

    // MARK: - Private
    fileprivate func animateLayer(
        _ animation: AuroraBlock,
        completion: AuroraBlock? = nil) {
        CATransaction.begin()
        if let completion = completion {
            CATransaction.setCompletionBlock { completion() }
        }
        animation()
        CATransaction.commit()
    }

    /// Plays the heatbeat animation with completion
    /// - parameter completion: completion
    func playHeartBeatAnimation(_ completion: AuroraBlock? = nil) {
        if let imageView = self.imageView {

            let popForce = 0.8

            animateLayer({
                let animation = CAKeyframeAnimation(keyPath: "transform.scale")
                animation.values = [0, 0.1 * popForce, 0.015 * popForce, 0.2 * popForce, 0]
                animation.keyTimes = [0, 0.25, 0.35, 0.55, 1]
                animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
                animation.duration = CFTimeInterval(self.duration/2)
                animation.isAdditive = true
                animation.repeatCount = Float(minimumBeats > 0 ? minimumBeats : 1)
                animation.beginTime = CACurrentMediaTime() + CFTimeInterval(self.delay/2)
                imageView.layer.add(animation, forKey: "pop")
            }, completion: { [weak self] in
                if self?.heartAttack ?? true {
                    self?.playZoomOutAnimation(completion)
                } else {
                    self?.playHeartBeatAnimation(completion)
                }
            })
        }
    }

    /// Stops the heart beat animation after gracefully finishing the last beat
    ///
    /// This function will not stop the original completion block from getting called
    func finishHeartBeatAnimation() {
        self.heartAttack = true
    }
}
#endif
// swiftlint:enable file_length
