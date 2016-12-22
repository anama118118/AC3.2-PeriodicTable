//
//  Element+JSON.swift
//  PeriodicTable
//
//  Created by Ana Ma on 12/21/16.
//  Copyright © 2016 C4Q. All rights reserved.
//

import Foundation
import CoreData


extension Element {
    
    //@nonobjc public class func fetchRequest() -> NSFetchRequest<Element> {
    //return NSFetchRequest<Element>(entityName: "Element");
    //}
    
    //symbol, name, number, group, and weight
    func populate(from dict: [String: Any]) {
        if let symbol = dict["symbol"] as? String,
            let number = dict["number"] as? Int,
            let name = dict["name"] as? String,
            let group = dict["group"] as? Int,
            let weight = dict["weight"] as? Double {
            self.symbol = symbol
            self.number = Int64(number)
            self.name = name
            self.group = Int64(group)
            self.weight = weight
        }
    }
}
