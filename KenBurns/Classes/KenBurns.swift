import Foundation
import UIKit
import CalmParametricAnimations
import Kingfisher

/*
 * a view that performs the Ken Burns effect on an image
 * see here: https://en.wikipedia.org/wiki/Ken_Burns_effect
 * http://www.twangnation.com/blog/http://example.com/uploads/2014/01/kenburns_portrait.jpg
 */

public typealias DurationRange = (max: Double, min: Double)

class KenBurnsAnimation : Equatable {
    let targetImage: UIImageView

    var startTime: TimeInterval
    var duration: TimeInterval

    let offsets: (x: Double, y: Double)
    let zoom: Double

    let fadeOutDuration: TimeInterval = 2.0

    var completion: ((_ animation: KenBurnsAnimation) -> ())?
    var willFadeOut: ((_ animation: KenBurnsAnimation) -> ())?

    init(targetImage: UIImageView, zoomIntensity: Double, durationRange: DurationRange, pansAcross: Bool) {
        self.targetImage = targetImage

        duration = Random.double(durationRange.min, durationRange.max)
        startTime = CACurrentMediaTime()

        let zoomMin = 1 + (0.3 * zoomIntensity)
        let zoomMax = 1 + (1.4 * zoomIntensity)
        zoom = Random.double(zoomMin, zoomMax)

        /* zooms to within maximal square within bounds that won't expose the edge of the image */
        let range = (min: (1 - zoom), max: 0.0)
        if pansAcross {
            offsets = (
                x: range.min,
                y: Random.double(0.3 * range.min, 0.7 * range.min)
            )
        } else {
            offsets = (
                x: Random.double(range.min, range.max),
                y: Random.double(range.min, range.max)
            )
        }
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
        return CGPoint(x: width * CGFloat(progressCurved * offsets.x),
                       y: height * CGFloat(progressCurved * offsets.y))
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
        willFadeOut(self)
        self.willFadeOut = nil // never call it again
    }

    func forceFadeOut() {
        self.duration = CACurrentMediaTime() - startTime + 2.0
    }

    func callCompletionIfNecessary() {
        if timeRemaining > 0 {
            return
        }
        guard let completion = self.completion else { return }
        completion(self)
        self.completion = nil // never call it again
    }
}

func ==(lhs: KenBurnsAnimation, rhs: KenBurnsAnimation) -> Bool {
    return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}

@objc public class KenBurnsImageView: UIView {
    public var loops = true
    public var pansAcross = false
    public var zoomIntensity = 1.0
    public var durationRange: DurationRange = (min: 10, max: 20)

    public var isAnimating: Bool {
        return !animations.isEmpty
    }

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
    var timeAtPause: CFTimeInterval = 0
    var completed : (() -> Void)?

    var imageQueue : RingBuffer<UIImage>? = nil
    var imageURLs : RingBuffer<URL>? = nil
    var imagePlaceholders : RingBuffer<UIImage>? = nil

    var index = -1
    private var remoteQueue = false

    public init() {
        super.init(frame: .zero)

        isUserInteractionEnabled = false
        clipsToBounds = true


        addSubview(nextImageView)
        addSubview(currentImageView)
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    public override func awakeFromNib() {
        super.awakeFromNib()

        isUserInteractionEnabled = false
        clipsToBounds = true

        nextImageView.kf.indicatorType = .activity
        currentImageView.kf.indicatorType = .activity

        addSubview(nextImageView)
        addSubview(currentImageView)
    }

    deinit {
        stopAnimating()
    }

    public func setImage(_ image: UIImage) {
        index = -1
        currentImageView.image = image
        nextImageView.image = image
    }

    public func fetchImage(_ url: URL, placeholder: UIImage?) {
        [ currentImageView, nextImageView ].forEach {
            $0.kf.setImage(with: url, placeholder: placeholder, options: [.transition(.fade(0.2))])
        }
    }

    // Swift can set durationRange directly, but objc needs this method to modify tuple
    public func setDuration(min: Double, max: Double) {
        self.durationRange = (min: min, max: max)
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

        updatesDisplayLink.add(to: RunLoop.main, forMode: .common)
        startNewAnimationWithoutDelay()
    }

    public func setImageQueue(withImages images:[UIImage]) {
        if images.count == 0 {
            fatalError("This is an empty queue!")
        }

        remoteQueue = false
        index = 0
        self.imageQueue = RingBuffer(count: images.count)

        for i in images {
            self.imageQueue?.write(i)
        }

        queueNextImage()
    }

    public func setImageQueue(withUrls urls:[URL], placeholders: [UIImage]?) {
        guard placeholders == nil || placeholders?.count == urls.count else {
            fatalError("You don't have a placeholder for every image!")
        }

        remoteQueue = true
        self.imageURLs = RingBuffer<URL>(count: urls.count)
        self.imagePlaceholders = RingBuffer<UIImage>(count: urls.count)

        for u in urls {
            self.imageURLs?.write(u)
        }

        self.fetchImage(self.imageURLs!.read()!, placeholder: nil)

        if placeholders != nil {
            for p in placeholders! {
                self.imagePlaceholders!.write(p)
            }
        }

        index = 0

        queueNextImage()
    }

    public func stopAnimating() {
        [ currentImageView, nextImageView ].forEach {
            $0.layer.removeAllAnimations()
            $0.alpha = 1
            $0.transform = CGAffineTransform.identity
            $0.size = self.size
            $0.position = .zero
        }

        if !isAnimating {
            return
        }

        animations.removeAll()
        updatesDisplayLink.remove(from: RunLoop.main, forMode: .common)
    }

    public func pause()  {
        updatesDisplayLink.isPaused = true
        // Save the time so we can resume the animation from where we left of.
        timeAtPause = layer.convertTime(CACurrentMediaTime(), from: nil)
    }

    public func resume() {
        let timeSincePause = layer.convertTime(CACurrentMediaTime(), from: nil) - timeAtPause
        // Add the elapsed time since pause to startTime, so the progress is caculated from where we left off.
        animations.forEach { $0.startTime += timeSincePause }
        updatesDisplayLink.isPaused = false
    }

    func startNewAnimationWithoutDelay() {
        currentImageView.transform = CGAffineTransform.identity
        currentImageView.size = self.size
        let animation = KenBurnsAnimation(targetImage: currentImageView, zoomIntensity: zoomIntensity, durationRange: (min: 1, max: 1), pansAcross: pansAcross)
        animation.completion = self.didFinishAnimation
        animation.willFadeOut = self.willFadeOutAnimation
        animations.append(animation)
    }

    func startNewAnimation() {
        currentImageView.transform = CGAffineTransform.identity
        currentImageView.size = self.size
        let animation = KenBurnsAnimation(targetImage: currentImageView, zoomIntensity: zoomIntensity, durationRange: durationRange, pansAcross: pansAcross)
        animation.completion = self.didFinishAnimation
        animation.willFadeOut = self.willFadeOutAnimation
        animations.append(animation)
    }

    @objc func updateAllAnimations() {
        animations.forEach {
            $0.update(self.w, self.h)
        }
    }

    func didFinishAnimation(_ animation: KenBurnsAnimation) {
        animations.remove(animation)
        queueNextImage()
    }

    func nextImage() {
        animations[0].forceFadeOut()
    }

    func willFadeOutAnimation(_ animation: KenBurnsAnimation) {
        swapCurrentAndNext()
        startNewAnimation()
    }

    func queueNextImage() {
        if remoteQueue  {
            if imagePlaceholders == nil {
                nextImageView.kf.setImage(with: imageURLs!.read()!, placeholder: nil, options: [.transition(.fade(0.2))])
                nextImageView.kf.indicatorType = .activity

            } else {
                nextImageView.kf.setImage(with: imageURLs!.read()!, placeholder: nil, options: [.transition(.fade(0.2))])
                nextImageView.kf.indicatorType = .activity
            }
        } else {
            guard let queue = imageQueue else {
                nextImageView.image = currentImageView.image;
                return;
            }
            nextImageView.image = imageQueue!.read()
        }

    }

    func swapCurrentAndNext() {
        bringSubviewToFront(currentImageView)
        insertSubview(nextImageView, belowSubview: currentImageView)

        let temp = currentImageView
        currentImageView = nextImageView
        nextImageView = temp

    }
}
