//
//  PhotoStore.swift
//  Pixel Walls
//
//  Created by Carter, Adam on 6/28/17.
//  Copyright © 2017 Carter, Adam. All rights reserved.
//

import UIKit
import CoreData

enum ImageResult {
    case success(UIImage)
    case failure(Error)
}

enum PhotoError: Error {
    case imageCreationError
}

enum PhotosResult {
    case success([Photo])
    case failure(Error)
}

class PhotoStore {
    
    private let imageStore = ImageStore()
    
    private let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Photorama")
        container.loadPersistentStores { (description, error) in
            if let error = error {
                print("Error setting up Core Data (\(error)).")
            }
        }
        return container
    }()
    
    let session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
    
    func processImageRequest(data: Data?, error: Error?) -> ImageResult {
        
        guard
            let imageData = data,
            let image = UIImage(data: imageData) else {
                
                // Couldn't create an image
                if data == nil {
                    return .failure(error!)
                } else {
                    return .failure(PhotoError.imageCreationError)
                }
        }
        return .success(image)
    }
    
    func fetchImage(for photo: Photo, completion: @escaping (ImageResult) -> Void) {
        
        guard let photoKey = photo.photoID else {
            preconditionFailure("Photo expected to have a photoID.")
        }
        
        if let image = imageStore.image(forKey: photoKey) {
            OperationQueue.main.addOperation {
                completion(.success(image))
            }
            return
        }
        
        guard let photoURL = photo.remoteURL else {
            preconditionFailure("Photo expected to have a remote URL.")
        }
        
        let request = URLRequest(url: photoURL as URL)
        
        let task = session.dataTask(with: request) {
            (data, response, error) -> Void in
            
            let result = self.processImageRequest(data: data, error: error)
            
            if case let .success(image) = result {
                self.imageStore.setImage(image, forKey: photoKey)
            }
            
            OperationQueue.main.addOperation {
                completion(result)
            }
        }
        task.resume()
    }
    
    func processPhotosRequest(data: Data?, error: Error?) -> PhotosResult {
        guard let jsonData = data else {
            return .failure(error!)
        }
        
        return PixelAPI.photos(fromJSON: jsonData,
                                into: persistentContainer.viewContext)
    }
    
    func fetchAllPhotos(completion: @escaping (PhotosResult) -> Void) {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        let sortByDateTaken = NSSortDescriptor(key: #keyPath(Photo.category), ascending: true)
        fetchRequest.sortDescriptors = [sortByDateTaken]
        
        let viewContext = persistentContainer.viewContext
        viewContext.perform {
            do {
                let allPhotos = try viewContext.fetch(fetchRequest)
                completion(.success(allPhotos))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
//    func fetchInterestingPhotos(completion: @escaping (PhotosResult) -> Void) {
//
//        let url = PixelAPI.interestingPhotosURL
//        let request = URLRequest(url: url)
//        let task = session.dataTask(with: request) {
//            (data, response, error) -> Void in
//
//            var result = self.processPhotosRequest(data: data, error: error)
//
//            if case .success(_) = result {
//                do {
//                    try self.persistentContainer.viewContext.save()
//                } catch {
//                    result = .failure(error)
//                }
//            }
//
//            OperationQueue.main.addOperation {
//                completion(result)
//            }
//        }
//        task.resume()
//    }
    
    
    func fetchInterestingPhotos(completion: @escaping (PhotosResult) -> Void) {
        
        let url = PixelAPI.interestingPhotosURL
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) {
            (data, response, error) -> Void in
//            if let jsonData = data {
//                do {
//                    let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
//
//                    print(jsonObject)
//                } catch let error {
//                    print("Error creating json oject: \(error)")
//                }
//            } else if let requestError = error {
//                print("Error fetching photos: \(requestError)")
//            } else {
//                print("Error with request")
//            }
            let result = self.processPhotosRequest(data: data, error: error)
            OperationQueue.main.addOperation {
                completion(result)
            }
            
        }
        task.resume()
    }
}
