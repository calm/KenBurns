# KenBurns

[![Version](https://img.shields.io/cocoapods/v/KenBurns.svg?style=flat)](http://cocoapods.org/pods/KenBurns)
[![License](https://img.shields.io/cocoapods/l/KenBurns.svg?style=flat)](http://cocoapods.org/pods/KenBurns)
[![Platform](https://img.shields.io/cocoapods/p/KenBurns.svg?style=flat)](http://cocoapods.org/pods/KenBurns)

![burns](KenBurns.gif)

A simple yet configurable Ken Burns effect using a single image looping over itself. Really draws the user’s attention, much more so than a static image.

`KenBurns` is written in Swift, but you can use `KenBurnsImageView` from Swift or Objective-C.  Examples are in Swift 3.0:

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
```

You can also initialize with a direct `UIImage` rather than a URL, and there are some paramaters you can set to configure the appearance:

```swift
func newKenBurnsImageView(image: UIImage) -> KenBurnsImageView {
    let ken = KenBurnsImageView()
    ken.setImage(image: image)
    ken.zoomIntensity = 1.5
    ken.loops = false
    ken.startAnimating()
    return ken
}
```

Powering [Calm](http://www.calm.com/ios)’s nature scenes and meditations since 2016.

## Installation

KenBurns is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod "KenBurns"
```
