//
//  ImageFetchingService.swift
//  GitHubContributorsList
//
//  Created by Viacheslav Embaturov on 18.05.2021.
//

import UIKit


//MARK: - *** PendingOperationsStorage Class ***

class PendingOperationsStorage {
    
    lazy var downloadsInProgress: [String: Operation] = [:]
    
    lazy var downloadQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "com.GitHubContributorsList.DownloadQueue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
}


//MARK: - *** ImageDownloadOperation Class ***

class ImageDownloadOperation: Operation {
    
    private let url: URL
    var photo: UIImage?
    
    init(_ url: URL) {
        self.url = url
    }
    
    override func main() {
        
        if isCancelled {return}
        guard let imageData = try? Data(contentsOf: url) else { return }
        if isCancelled {return}
    
        if !imageData.isEmpty {
            photo = UIImage(data: imageData)
        }
    }
  }


//MARK: - *** ImageFetchingService Class ***

class ImageFetchingService {
    
    typealias ImageBlock = (UIImage?) -> Void
    
    
    //MARK: - class variables
    
    let storage = PendingOperationsStorage()
    let cache = ImageCacheService()
    static let shared = ImageFetchingService()

    
    
    //MARK: - Lifecycle
    
    private init() {
        
    }
    
    
    //MARK: - Download
    
    
    func cancelDownloads() {
        storage.downloadQueue.cancelAllOperations()
    }
    
    func cancelDownloadIfNeeded(for url: URL) {
        if let operation = storage.downloadsInProgress[url.path] {
            operation.cancel()
            storage.downloadsInProgress.removeValue(forKey: url.path)
        }
    }
    
    func fetchImage(with url: URL, completion: @escaping ImageBlock) {
        
        if let cachedImage = cache.cachedImage(url.path) {
            completion(cachedImage)
        } else {
            downloadImage(with: url, completion: completion)
        }
    }
    
    private func downloadImage(with url: URL, completion: @escaping ImageBlock) {
        
        guard storage.downloadsInProgress[url.path] == nil else {
          return
        }
        
        let operation = ImageDownloadOperation(url)
        
        operation.completionBlock = {
            if operation.isCancelled {return}
            
            DispatchQueue.main.async { [weak self] in
                self?.storage.downloadsInProgress.removeValue(forKey: url.path)
                
                if let img = operation.photo {
                    self?.cache.addImage(img, for: url.path)
                }
                
                completion(operation.photo)
            }
        }
        
        storage.downloadsInProgress[url.path] = operation
        storage.downloadQueue.addOperation(operation)
    }
}

