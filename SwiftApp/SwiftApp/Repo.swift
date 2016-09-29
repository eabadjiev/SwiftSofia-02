//
//  Repo.swift
//  SwiftApp
//
//  Created by Emo Abadjiev on 9/28/16.
//  Copyright © 2016 Tumba Solutions. All rights reserved.
//

import Foundation

struct Repo {
    
    let name: String
    let description: String?    
    
}

extension Repo {
    init?(json: [String: Any]) {
        guard let name = json["name"] as? String,
            let description = json["description"] as? String? else {
                return nil;
        }
        
        self.name = name
        self.description = description
    }
}
