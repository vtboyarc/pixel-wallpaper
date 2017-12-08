//
//  PhotoDataSource.swift
//  Pixel Walls
//
//  Created by Carter, Adam on 6/30/17.
//  Copyright © 2017 Carter, Adam. All rights reserved.
//

import UIKit

class PhotoDataSource: NSObject, UICollectionViewDataSource {
    
    var photos: [Photo] = []
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let identifier = "PhotoCollectionViewCell"
        let cell =
            collectionView.dequeueReusableCell(withReuseIdentifier: identifier,
                                               for: indexPath) as! PhotoCollectionViewCell
        
        return cell
    }
}
