# Ken Burns

## Single Images

![burns](KenBurns.gif)

## Queue Images

![burns](KenBurns2.gif)

A simple yet configurable Ken Burns effect. Use a single image or queue multiple images. The Kens Burns effect is a popular transition effect in film popularized by American documentarian Ken Burns. It creates the effect of motion using still imagery.

### Usage

`KenBurns` is written in Swift, use `KenBurnsImageView` from Swift or Objective-C.  Examples are in Swift 3.0:

```swift
func newKenBurnsImageView(url: URL) -> KenBurnsImageView {
    let ken = KenBurnsImageView()
    ken.fetchImage(url: url, placeholder: UIImage(named: "placeholder"))
    ken.startAnimating()
    return ken
}

func stop(ken: KenBurnsImageView) {
    ken.stopAnimating()
}

func pause(ken: KenBurnsImageView) {
    ken.pause()
}

func resume(ken: KenBurnsImageView) {
    ken.resume()
}
```

Initialize with `UIImage` or `URL`, and there are some paramaters you can set to configure the appearance:

```swift
func newKenBurnsImageView(image: UIImage) -> KenBurnsImageView {
    let ken = KenBurnsImageView()
    ken.setImage(image: image)
    ken.zoomIntensity = 1.5
    ken.setDuration(min: 5, max: 13)
    ken.startAnimating()
    return ken
}
```

Ken Burns has been powering [Calm](http://www.calm.com/ios)’s nature scenes and meditations since 2016. We found that adding this effect in place of a static image improves click-through rates (and users love it).

Due to unfortunate circumstances, Calm has no direct affiliation with [Ken Burns](https://en.wikipedia.org/wiki/Ken_Burns) himself 😞

### Demo

Launch and run

```
roadtrip.xcworkspace
```

To view demo

### Installation

KenBurns is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod "KenBurns"
```
