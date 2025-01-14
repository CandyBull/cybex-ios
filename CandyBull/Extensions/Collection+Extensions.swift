//
//  Collection+Extensions.swift
//  CandyBull
//
//  Created by koofrank on 2018/4/12.
//  Copyright © 2018年 CandyBull. All rights reserved.
//

import Foundation

extension Collection {
  subscript(optional index: Index) -> Iterator.Element? {
    return self.indices.contains(index) ? self[index] : nil
  }
}

extension Array where Element: Hashable {
  func containHashable<T: Hashable>(_ element: T) -> (Contain: Bool, Index: Int) {
    let hashNum = self.map { $0.hashValue }
    if let index = hashNum.firstIndex(of: element.hashValue) {
      return (true, index)
    }
    return (false, 0)
  }
}
