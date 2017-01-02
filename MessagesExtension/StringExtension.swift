//
//  StringExtension.swift
//  UReact
//
//  Created by Sean Allen on 12/31/16.
//  Copyright © 2016 Sean Allen. All rights reserved.
//

import Foundation

extension String {
    
    func insert(string: String,ind: Int) -> String {
        return  String(self.characters.prefix(ind)) + string + String(self.characters.suffix(self.characters.count-ind))
    }
}
