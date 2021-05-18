//
//  ImageCache.swift
//  GitHubContributorsList
//
//  Created by Viacheslav Embaturov on 18.05.2021.
//

import UIKit

struct ImageCacheConfig {
    let countLimit: Int
    let costLimit: Int
    
    static var defaultConfig: ImageCacheConfig {
        return ImageCacheConfig(countLimit: 100,
                                costLimit: 1024 * 1024 * 200) //100 items, 200 MB total size
    }
}


class ImageCacheService {
    
    
    //MARK: - class variables
    
    let cache = NSCache<NSString, UIImage>()

    
    
    //MARK: - Lifecycle
    
    init(with config: ImageCacheConfig = ImageCacheConfig.defaultConfig) {
        cache.countLimit = config.countLimit
        cache.totalCostLimit = config.costLimit
    }
    
    //MARK: -
    
    func cachedImage(_ key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }
    
    func addImage(_ image: UIImage, for key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
}
