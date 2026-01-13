//
//  String+Substring.swift
//  
//
//  Created by Dylan Elliott on 5/1/2026.
//

extension String {
    func substring(with intRange: Range<Int>) -> String {
        let startIndex = self.index(self.startIndex, offsetBy: intRange.lowerBound, limitedBy: self.endIndex)!
        let endIndex = self.index(self.startIndex, offsetBy: intRange.upperBound, limitedBy: self.endIndex)!
        return String(self[startIndex..<endIndex])
    }
    
    subscript (_ index: Int) -> Character {
        get {
            self[self.index(startIndex, offsetBy: index)]
        }
    }
}
