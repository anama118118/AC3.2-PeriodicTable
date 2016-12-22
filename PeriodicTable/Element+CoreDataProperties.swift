//
//  Element+CoreDataProperties.swift
//  PeriodicTable
//
//  Created by Ana Ma on 12/21/16.
//  Copyright © 2016 C4Q. All rights reserved.
//  This file was automatically generated and should not be edited.
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
            let number = dict["number"] as? Int64,
            let name = dict["name"] as? String,
            let group = dict["group"] as? Int64,
            let weight = dict["weight"] as? Double {
            self.symbol = symbol
            self.number = number
            self.name = name
            self.group = group
            self.weight = weight
        }
    }
}
