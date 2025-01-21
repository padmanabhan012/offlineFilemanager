//
//  DataManager.swift
//  FileManager
//
//  Created by Rahul P John on 18/01/25.
//

import UIKit
import CoreData

class DataManager {
    static let sharedData: DataManager = .init()
    
    private init () { }
    
    let managedContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    
    func createFolder(folderName: String? = nil, fileData: Data? = nil, fileName: String? = nil, fileType: String? = nil, isFolder: Bool, parentID: String? = nil, isFavourite: Bool, folderColor: String = "#5AC5FA", completion: @escaping(Bool) -> Void) {
        guard let managedContext = managedContext else { return }
        guard let addFileEntity = NSEntityDescription.entity(forEntityName: "AddFiles", in: managedContext) else { return }
        let createdFolder = NSManagedObject(entity: addFileEntity, insertInto: managedContext)
        
        createdFolder.setValue("\(Date())", forKey: "id")
        createdFolder.setValue(folderName, forKey: "folderName")
        createdFolder.setValue(Date(), forKey: "createdAt")
        createdFolder.setValue(fileData, forKey: "fileData")
        createdFolder.setValue(fileName, forKey: "fileName")
        createdFolder.setValue(fileType, forKey: "fileType")
        createdFolder.setValue(isFolder, forKey: "isFolder")
        createdFolder.setValue(parentID, forKey: "parentID")
        createdFolder.setValue(isFavourite, forKey: "isFavourite")
        createdFolder.setValue(folderColor, forKey: "folderColor")
        
        do {
            try managedContext.save()
            completion(true)
        } catch {
            print("There was an error while saving data")
            completion(false)
        }
    }
    
    func fetchData1(completion: @escaping(Bool, [AddFiles]?) -> Void) {
        guard let managedContext = managedContext else { return }
        let fetchRequest = NSFetchRequest<AddFiles>(entityName: "AddFiles")
        do {
            let result = try managedContext.fetch(fetchRequest)
            completion(true, result)
        } catch let error {
            print(error)
            completion(false, nil)
        }
    }
    
    func updateDate(id: String, isFavourite: Bool, folderColor: String, completion: @escaping(Bool) -> Void) {
        guard let managedContext = managedContext else { return }
        let fetchRequest = NSFetchRequest<AddFiles>(entityName: "AddFiles")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        do {
            let result = try managedContext.fetch(fetchRequest)
            if let container = result.first {
                container.isFavourite = isFavourite
                container.folderColor = folderColor
                try managedContext.save()
            }
            completion(true)
        } catch let error {
            completion(false)
        }
    }
}
