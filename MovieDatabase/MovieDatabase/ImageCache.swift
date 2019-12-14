//
//  ImageCache.swift
//  MovieDatabase
//
//  Copyright © 2019 Chris Brown, All Rights Reserved
//

import UIKit

@objc protocol ImageCacheDelegate {
    func newImageAvailable()
}

@objc @objcMembers class ImageCache: NSObject {
    static var shared = ImageCache()
    var delegate: ImageCacheDelegate?

    private var cache = NSCache<NSString,UIImage>()

    /// Caches an image as a UI Image from a URL using the URL as the key
    /// - Parameter url: (String) key used for image cache
    /// - Returns: void
    func cacheImage(_ url: String?, callback: (() -> Void)?) {
        if let url = url {
            if cache.object(forKey: url as NSString) == nil {
                do {
                    let imageURL = URL(string: url)
                    let imageData = try Data(contentsOf: imageURL!)
                    let fetchedImage = UIImage(data: imageData)
                    let resizedImage = resizeImage(fetchedImage!)
                    DispatchQueue.main.async {
                        self.cache.setObject(resizedImage, forKey: url as NSString)
                        self.delegate?.newImageAvailable()
                        callback?()
                    }
                } catch {
                  print("bad image URL: \(url)")
                }
            }
        }
    }

    /// Fetches a UIImage from ImageCache using the provided url as a key
    /// - Parameter url: (String) key used for image cache
    /// - Returns: UIImage or nil
    func fetchImage(_ url: String?) -> UIImage? {
        if let url = url, let image = cache.object(forKey: url as NSString) {
            return image
        }
        return UIImage(named: "Icon")
    }

    /// Resizes an image to fit a given targetSize
    /// - Parameter image: Image ot resize
    /// - Returns: UIImage resized
    fileprivate func resizeImage(_ image: UIImage,
                              targetSize: CGSize = CGSize(width: 400, height: 400) ) -> UIImage {
        let size = image.size

        if size.width <= targetSize.width && size.height <= targetSize.height {
            return image
        }

        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height

        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }

        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
}

