//
//  CollectionViewExtension.swift
//  UReact
//
//  Created by Sean Allen on 1/2/17.
//  Copyright © 2017 Sean Allen. All rights reserved.
//

import Foundation
import UIKit

extension UICollectionView {
    
    func reloadDataOnMainThread() {
        DispatchQueue.main.async {
            self.reloadData()
        }
    }
}
