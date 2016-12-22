//
//  PeriodicTableCollectionViewController.swift
//  PeriodicTable
//
//  Created by Ana Ma on 12/21/16.
//  Copyright © 2016 C4Q. All rights reserved.
//

import UIKit
import CoreData


class PeriodicTableCollectionViewController: UICollectionViewController, NSFetchedResultsControllerDelegate, UICollectionViewDelegateFlowLayout {
    var fetchedResultsController: NSFetchedResultsController<Element>!
    let elements = [("H", 1), ("He", 2), ("Li", 3)]
    let endpoint = "https://api.fieldbook.com/v1/5859ad86d53164030048bae2/elements"
    let groupOffsets = [0, 1, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 1, 1, 1, 1, 1, 0]

    private let reuseIdentifier = "ElementCell"
    override func viewDidLoad() {
        super.viewDidLoad()
        // Register cell classes
        self.collectionView!.register(UINib(nibName: "ElementCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: self.reuseIdentifier)
        initializeFetchedResultsController()
        //self.getData()
    }
    
    func getData() {
        APIRequestManager.manager.getData(endPoint: self.endpoint) { (data: Data?) in
            guard let validData = data else { return }
            if let elementsJsonData = try? JSONSerialization.jsonObject(with: validData, options:[]){
                if let elements = elementsJsonData as? [[String: Any]] {
                    dump(elements)
                let moc = (UIApplication.shared.delegate as! AppDelegate).dataController.privateContext
                moc.performAndWait {
                    //let fetchRequest = NSFetchRequest<Element>(entityName: "Element")
                    //how to you want us to set the predicate
                    for elementDict in elements {
                        let elementInfo = NSEntityDescription.insertNewObject(forEntityName: "Element", into: moc) as! Element
                        elementInfo.populate(from: elementDict)
//                        if let elementsArr = try? fetchRequest.execute() {
//                            if let element = elementsArr.last {
//                                element.populate(from: elementDict)
//                            }
//                        }
                    }
                    do {
                        try moc.save()
                        moc.parent?.performAndWait {
                            do {
                                try moc.parent?.save()
                            }
                            catch {
                                fatalError("Failure to save context:\(error)")
                            }
                        }
                    }
                    catch {
                        fatalError("Failture to save context: \(error)")
                    }
                }
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                }
            }
        }
    }
    }
    
    func initializeFetchedResultsController() {
        let moc = (UIApplication.shared.delegate as! AppDelegate).dataController.managedObjectContext
        
        let request = NSFetchRequest<Element>(entityName: "Element")
        let sortByNumber = NSSortDescriptor(key: "number", ascending: true)
        let sortByGroup = NSSortDescriptor(key: "group", ascending: true)
        request.sortDescriptors = [sortByGroup, sortByNumber]
        let predicate = NSPredicate(format: "group <= %d", 18)
        request.predicate = predicate
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: "group", cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            let els = try moc.fetch(request)
            for el in els {
                print("\(el.group) \(el.number) \(el.symbol)")
            }
        }
        catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let sections = fetchedResultsController.sections else {
            print("No sections in fetchedResultsController")
            return 0
        }
        return sections.count
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //return self.elements.count
        //guard let sections = fetchedResultsController.sections else {
        //    fatalError("No sections in fetchedResultsController")
        //}
        //let sectionInfo = sections[section]
        //print(section)
        //return sectionInfo.numberOfObjects
        return 7

    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.reuseIdentifier, for: indexPath) as! ElementCollectionViewCell
//        let element = fetchedResultsController.object(at: indexPath)
//        cell.elementView.atomicNumberLabel.text = "\(element.number)"
//        if let validSymbol = element.symbol {
//            cell.elementView.symbolLabel.text = validSymbol
//        }
        
//        configureCell(cell, indexPath: indexPath)
//        let element = elements[indexPath.row]
//        cell.elementView.symbolLabel.text = element.0
//        cell.elementView.atomicNumberLabel.text = "\(element.1)"
        
        cell.elementView.symbolLabel.text = ""
        cell.elementView.atomicNumberLabel.text = ""
        
        if indexPath.item >= groupOffsets[indexPath.section] {
            var modifiedIp = indexPath
            modifiedIp.item = indexPath.item - groupOffsets[indexPath.section]
            
            let element = fetchedResultsController.object(at: modifiedIp)
            
            cell.elementView.symbolLabel.text = element.symbol!
            cell.elementView.atomicNumberLabel.text = String(element.number)
            
            let dimension = self.collectionView!.bounds.height / 7 - spacing * 6
            cell.elementView.symbolLabel.font = UIFont.systemFont(ofSize: dimension/2)
            
            switch element.number {
            case 1, 6...8, 15, 16, 34:
                cell.elementView.backgroundColor = UIColor.cyan
            case 2, 10, 18, 36, 54, 86:
                cell.elementView.backgroundColor = UIColor.brown
            case 3, 11, 19, 37, 55, 87:
                cell.elementView.backgroundColor = UIColor.blue
            case 4, 12, 20, 38, 56, 88:
                cell.elementView.backgroundColor = UIColor.purple
            case 21...30, 39...48, 72...80, 104...112:
                cell.elementView.backgroundColor = UIColor.red
            case 5, 14, 32, 33, 51, 52, 84:
                cell.elementView.backgroundColor = UIColor.yellow
            case 9, 17, 35, 53, 85:
                cell.elementView.backgroundColor = UIColor.green
            case 13, 31, 49, 50, 81...83:
                cell.elementView.backgroundColor = UIColor.orange
            case 113...118:
                cell.elementView.backgroundColor = UIColor.lightGray
            case 57:
                cell.elementView.backgroundColor = UIColor.magenta
            case 89:
                cell.elementView.backgroundColor = UIColor.darkGray
            default:
                break
            }
        }
        
        return cell
    }
    
    func configureCell(_ cell: ElementCollectionViewCell, indexPath: IndexPath) {
        let element = fetchedResultsController.object(at: indexPath)
        cell.elementView.atomicNumberLabel.text = "\(element.number)"
        cell.elementView.symbolLabel.text = element.symbol
    }
    
    let spacing: CGFloat = 2.0
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let dimension = (self.collectionView?.bounds.height)! / 7 - spacing * 6
        return CGSize(width: dimension, height: dimension)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
    }
    
//    override func collectionView(_ collectionView: UICollectionView, targetContentOffsetForProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
//        <#code#>
//    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
/*

//
//  PeriodicCollectionViewController.swift
//  PeriodicTableOfTheElements
//
//  Created by Jason Gresh on 12/20/16.
//  Copyright © 2016 C4Q. All rights reserved.
//
import UIKit
import CoreData
private let reuseIdentifier = "elementCell"
class PeriodicCollectionViewController: UICollectionViewController, NSFetchedResultsControllerDelegate, UICollectionViewDelegateFlowLayout {
    var fetchedResultsController: NSFetchedResultsController<Element>!
    let groupOffsets = [0, 1, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 1, 1, 1, 1, 1, 0]
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeFetchedResultsController()
        getData()
        // Register cell classes
        self.collectionView!.register(UINib(nibName:"ElementCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    func getData() {
        APIRequestManager.manager.getData(endPoint: "https://api.fieldbook.com/v1/5859ad86d53164030048bae2/elements") { data in
            if let validData = data {
                if let jsonData = try? JSONSerialization.jsonObject(with: validData, options:[]),
                    let elements = jsonData as? [[String:Any]] {
                    
                    let moc = (UIApplication.shared.delegate as! AppDelegate).dataController.privateContext
                    Element.putElements(from: elements, into: moc)
                    DispatchQueue.main.async {
                        self.collectionView!.reloadData()
                    }
                }
            }
        }
    }
    
    func initializeFetchedResultsController() {
        let moc = (UIApplication.shared.delegate as! AppDelegate).dataController.managedObjectContext
        
        let request = NSFetchRequest<Element>(entityName: "Element")
        let groupSort = NSSortDescriptor(key: "group", ascending: true)
        let numberSort = NSSortDescriptor(key: "number", ascending: true)
        let predicate = NSPredicate(format: "group <= %d", 18)
        request.sortDescriptors = [groupSort, numberSort]
        request.predicate = predicate
        
        // diagnostic
        //        do {
        //            let els = try moc.fetch(request)
        //
        //            for el in els {
        //                print("\(el.group) \(el.number) \(el.symbol)")
        //            }
        //        }
        //        catch {
        //            print("error fetching")
        //        }
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: moc, sectionNameKeyPath: "group", cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    
    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        if let count = fetchedResultsController.sections?.count {
            return count
        }
        else {
            return 0
        }
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
        
        //        guard let sections = fetchedResultsController.sections else {
        //            fatalError("No sections in fetchedResultsController")
        //        }
        //        let sectionInfo = sections[section]
        //        return sectionInfo.numberOfObjects
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ElementCollectionViewCell
        
        cell.elementView.symbolLabel.text = ""
        cell.elementView.numberLabel.text = ""
        
        // bump the cells down
        if indexPath.item >= groupOffsets[indexPath.section] {
            var modifiedIp = indexPath
            modifiedIp.item = indexPath.item - groupOffsets[indexPath.section]
            
            let element = fetchedResultsController.object(at: modifiedIp)
            
            cell.elementView.symbolLabel.text = element.symbol!
            cell.elementView.numberLabel.text = String(element.number)
            
            let dimension = self.collectionView!.bounds.height / 7 - spacing * 6
            cell.elementView.symbolLabel.font = UIFont.systemFont(ofSize: dimension/2)
        }
        return cell
    }
    let spacing:CGFloat = 2.0
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let dimension = self.collectionView!.bounds.height / 7 - spacing * 6
        return CGSize(width: dimension, height: dimension)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }
    
    // you'd think you need this but our sections have only one column
    //    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    //        return spacing
    //    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: spacing)
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using [segue destinationViewController].
     // Pass the selected object to the new view controller.
     }
     */
}
*/

/*
override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let sections = fetchedResultsController.sections else {
        fatalError("No sections in fetchedResultsController")
    }
    let sectionInfo = sections[indexPath.section].numberOfObjects
    
    let offset = 7 - sectionInfo
    
    //Need to create default cell as well
    if indexPath.row < offset {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "defaultCell", for: indexPath)
    } else {
        let offSetIndexPath: IndexPath = [indexPath.section, indexPath.row - offset]
        return configureCell(indexPath: offSetIndexPath, collectionView: collectionView)
    }
}

func configureCell(indexPath: IndexPath, collectionView: UICollectionView) -> ElementCollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ElementCollectionViewCell
    
    let currentElement = fetchedResultsController.object(at: indexPath)
    
    cell.elementView.symbolLabel.text = currentElement.symbol!
    cell.elementView.numberLabel.text = currentElement.number.description
    
    switch currentElement.number {
    case 1, 6...8, 15, 16, 34:
        cell.elementView.backgroundColor = UIColor.cyan
    case 2, 10, 18, 36, 54, 86:
        cell.elementView.backgroundColor = UIColor.brown
    case 3, 11, 19, 37, 55, 87:
        cell.elementView.backgroundColor = UIColor.blue
    case 4, 12, 20, 38, 56, 88:
        cell.elementView.backgroundColor = UIColor.purple
    case 21...30, 39...48, 72...80, 104...112:
        cell.elementView.backgroundColor = UIColor.red
    case 5, 14, 32, 33, 51, 52, 84:
        cell.elementView.backgroundColor = UIColor.yellow
    case 9, 17, 35, 53, 85:
        cell.elementView.backgroundColor = UIColor.green
    case 13, 31, 49, 50, 81...83:
        cell.elementView.backgroundColor = UIColor.orange
    case 113...118:
        cell.elementView.backgroundColor = UIColor.lightGray
    case 57:
        cell.elementView.backgroundColor = UIColor.magenta
    case 89:
        cell.elementView.backgroundColor = UIColor.darkGray
    default:
        break
    }
    
    return cell
}
*/
