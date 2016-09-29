//
//  CodeQuality.swift
//  SwiftApp
//
//  Created by Emo Abadjiev on 9/28/16.
//  Copyright © 2016 Tumba Solutions. All rights reserved.
//

import Foundation

enum CodeQuality {
    case good, bad
}

protocol CodeQualifier {
    func qualify() -> CodeQuality
    func issuesRatio() -> Double
}
extension CodeQualifier {
    func qualify() -> CodeQuality {
        if issuesRatio() > 0.01 {
            return .good
        }
        
        return .bad
    }
}

extension Repo: CodeQualifier {
    func issuesRatio() -> Double {
        return 0.001
    }

}
extension Array: CodeQualifier {
    
    func issuesRatio() -> Double {
        return 0.11
    }

}
//extension Array where Element: CodeQualifier {}

//var a: [Repo] = []
