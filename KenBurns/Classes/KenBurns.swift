import Foundation
import UIKit
import CLKParametricAnimations
import SDWebImage

/* 
 * a view that performs the Ken Burns effect on an image
 * see here: https://en.wikipedia.org/wiki/Ken_Burns_effect
 * http://www.twangnation.com/blog/http://example.com/uploads/2014/01/kenburns_portrait.jpg
 */

class KenBurnsAnimation : Equatable {
    let targetImage: UIImageView

    let startTime: TimeInterval
    let duration: TimeInterval

    let xFactor: Double
    let yFactor: Double
    let zoom: Double

    let fadeOutDuration: TimeInterval = 2.0

    var completion: ((animation: KenBurnsAnimation) -> ())?
    var willFadeOut: ((animation: KenBurnsAnimation) -> ())?

    init(targetImage: UIImageView, zoomIntensity: Double) {
        self.targetImage = targetImage

        let zoomMin = 1 + (0.3 * zoomIntensity)
        let zoomMax = 1 + (1.4 * zoomIntensity)
        zoom = Random.double(zoomMin, zoomMax)
        xFactor = Random.double((1 - zoom), 0)
        yFactor = Random.double((1 - zoom), 0)
        duration = Random.double(12, 24)
        startTime = CACurrentMediaTime()
    }

    var timeRemaining: TimeInterval {
        return (1 - progress) * duration
    }

    var progress: Double {
        return (CACurrentMediaTime() - startTime) / duration
    }

    var progressCurved: Double {
        return kParametricTimeBlockAppleOut(progress)
    }

    var currentZoom: Double {
        return progressCurved * (zoom - 1) + 1
    }

    var currentAlpha: CGFloat {
        if timeRemaining > fadeOutDuration {
            return 1.0
        }
        return CGFloat(timeRemaining / fadeOutDuration)
    }

    func currentPosition(_ width: CGFloat, _ height: CGFloat) -> CGPoint {
        return CGPoint(x: width * CGFloat(progressCurved * xFactor),
                       y: height * CGFloat(progressCurved * yFactor))
    }

    func update(_ width: CGFloat, _ height: CGFloat) {
        targetImage.alpha = currentAlpha
        targetImage.position = currentPosition(width, height)
        let zoom = CGFloat(currentZoom)
        targetImage.transform = CGAffineTransform(scaleX: zoom, y: zoom)

        callWillFadeOutIfNecessary()
        callCompletionIfNecessary()
    }

    func callWillFadeOutIfNecessary() {
        if timeRemaining > fadeOutDuration {
            return
        }
        guard let willFadeOut = self.willFadeOut else { return }
        willFadeOut(animation: self)
        self.willFadeOut = nil // never call it again
    }

    func callCompletionIfNecessary() {
        if timeRemaining > 0 {
            return
        }
        guard let completion = self.completion else { return }
        completion(animation: self)
        self.completion = nil // never call it again
    }
}

func ==(lhs: KenBurnsAnimation, rhs: KenBurnsAnimation) -> Bool {
    return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}

@objc public class KenBurnsImageView: UIView {
    public var loops = true
    public var zoomIntensity = 1.0

    lazy var currentImageView: UIImageView = {
        return self.newImageView()
    }()

    lazy var nextImageView: UIImageView = {
        return self.newImageView()
    }()

    lazy var updatesDisplayLink: CADisplayLink = {
        return CADisplayLink(target: self, selector: #selector(updateAllAnimations))
    }()

    var animations: [KenBurnsAnimation] = []

    public var isAnimating: Bool {
        return !animations.isEmpty
    }

    public init() {
        super.init(frame: .zero)

        isUserInteractionEnabled = false
        clipsToBounds = true

        addSubview(nextImageView)
        addSubview(currentImageView)
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        stopAnimating()
    }

    public func setImage(image: UIImage) {
        currentImageView.image = image
        nextImageView.image = image
    }

    public func fetchImage(url: URL, placeholder: UIImage?) {
        [ currentImageView, nextImageView ].forEach {
            $0.setImageWith(url, placeholderImage: placeholder)
        }
    }

    func newImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }

    public func startAnimating() {
        if isAnimating {
            return
        }

        updatesDisplayLink.add(to: RunLoop.main(), forMode: RunLoopMode.commonModes.rawValue)
        startNewAnimation()
    }

    public func stopAnimating() {
        animations.removeAll()
        updatesDisplayLink.invalidate()

        [ currentImageView, nextImageView ].forEach {
            $0.layer.removeAllAnimations()
            $0.alpha = 1
            $0.transform = CGAffineTransform.identity
            $0.size = self.size
        }
    }

    func startNewAnimation() {
        currentImageView.transform = CGAffineTransform.identity
        currentImageView.size = self.size
        let animation = KenBurnsAnimation(targetImage: currentImageView, zoomIntensity: zoomIntensity)
        animation.completion = self.didFinishAnimation
        animation.willFadeOut = self.willFadeOutAnimation
        animations.append(animation)
    }

    func updateAllAnimations() {
        animations.forEach {
            $0.update(self.w, self.h)
        }
    }

    func didFinishAnimation(animation: KenBurnsAnimation) {
        animations.remove(object: animation)
    }

    func willFadeOutAnimation(animation: KenBurnsAnimation) {
        swapCurrentAndNext()
        startNewAnimation()
    }

    func swapCurrentAndNext() {
        bringSubview(toFront: currentImageView)

        let temp = currentImageView
        currentImageView = nextImageView
        nextImageView = temp
    }
}
