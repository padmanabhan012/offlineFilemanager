//
//  FolderDetailsViewController.swift
//  FileManager
//
//  Created by Rahul P John on 19/01/25.
//

import UIKit
import MobileCoreServices

class FolderDetailsViewController: UIViewController {
    
    @IBOutlet weak var folderDetailCollectionView: UICollectionView!

    var fileList = [AddFiles]()
        var parentID = String()
        var parentName = String()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            UIDecoration()
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            fetchData()
        }
        
        private func UIDecoration() {
            configNavBar()
        }
        
        private func configNavBar() {
            self.navigationController?.isNavigationBarHidden = false
            title = parentName
            
            self.navigationItem.setRightBarButton(createAddFileButton(), animated: true)
        }
        
        func createAddFileButton() -> UIBarButtonItem {
            let addNewFolder = UIButton()
            addNewFolder.setImage(UIImage(systemName: "plus"), for: .normal)
            addNewFolder.addTarget(self, action: #selector(didTapAddFolderButton(_:)), for: .touchUpInside)
            let leftBarButton = UIBarButtonItem(customView: addNewFolder)
            return leftBarButton
        }
        
        
        @objc
        private func didTapAddFolderButton(_ sender: UIButton) {
            let documentPicker = UIDocumentPickerViewController(documentTypes: [kUTTypeImage as String, kUTTypePDF as String, kUTTypeMovie as String], in: .import)
            documentPicker.delegate = self
            documentPicker.modalPresentationStyle = .formSheet
            
            present(documentPicker, animated: true, completion: nil)
        }
        
        private func addFolderPopup() {
            let alert = UIAlertController(title: "Add Folder", message: "", preferredStyle: .alert)
            alert.addTextField { textField in
                textField.placeholder = "Enter folder name"
            }
            let createAction = UIAlertAction(title: "Create", style: .default) { _ in
                guard let textField = alert.textFields?.first else { return }
                
                DataManager.sharedData.createFolder(folderName: textField.text ?? "Untitled Folder", isFolder: true, isFavourite: false) { [weak self] isSuccess in
                    guard let self = self else { return }
                    if isSuccess {
                        self.fetchData()
                    } else {
                        let alert = UIAlertController(title: "File Manager", message: "Error while saving data", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default)
                        alert.addAction(okAction)
                        self.present(alert, animated: true)
                    }
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            alert.addAction(createAction)
            present(alert, animated: true)
        }
        
        func fetchData() {
            DataManager.sharedData.fetchData1 { [weak self] isValid, fetchedData in
                guard let self = self else { return }
                if isValid {
                    guard let fetchedData = fetchedData else {
                        let alert = UIAlertController(title: "File Manager", message: "Something went wrong", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default)
                        alert.addAction(okAction)
                        self.present(alert, animated: true)
                        return
                    }
                    self.fileList = fetchedData.filter({ $0.parentID == self.parentID })
                    self.folderDetailCollectionView.delegate = self
                    self.folderDetailCollectionView.dataSource = self
                    self.folderDetailCollectionView.reloadData()
                } else {
                    let alert = UIAlertController(title: "File Manager", message: "Error while fetching data", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default)
                    alert.addAction(okAction)
                    self.present(alert, animated: true)
                }
            }
        }
    }

    extension FolderDetailsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return fileList.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            guard let fileListCell = collectionView.dequeueReusableCell(withReuseIdentifier: "FolderDetailsCollectionViewCell", for: indexPath) as? FolderDetailsCollectionViewCell else { return UICollectionViewCell() }
                
                let data = fileList[indexPath.item]
                fileListCell.lblFileName.text = data.fileName ?? ""
                
                if data.fileType == "image" {
                    if let fileData = data.fileData {
                        fileListCell.imgFile.image = UIImage(data: fileData)
                    } else {
                        fileListCell.imgFile.image = nil
                    }
                } else if data.fileType == "pdf" {
                    fileListCell.imgFile.image = UIImage(named: "icons8-pdf-100")
                } else if data.fileType == "video" {
                    fileListCell.imgFile.image = UIImage(systemName: "video")
                } else {
                    fileListCell.imgFile.image = nil
                }
                return fileListCell
        }
    }

    extension FolderDetailsViewController: UICollectionViewDelegateFlowLayout {
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let cellRect = CGSize(width: collectionView.frame.size.width / 4, height: 105.00)
            return cellRect
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return 0.0
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
            return 0.0
        }
    }

    extension FolderDetailsViewController: UIDocumentPickerDelegate {
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            
            let fileExtension = url.pathExtension.lowercased()
            let fileName = url.lastPathComponent
            
            do {
                let fileData = try Data(contentsOf: url)
                if fileExtension == "pdf" {
                    DataManager.sharedData.createFolder(fileData: fileData, fileName: fileName, fileType: "pdf", isFolder: false, parentID: parentID, isFavourite: false) { [weak self] isSuccess in
                        guard let self = self else { return }
                        if isSuccess {
                            self.fetchData()
                        } else {
                            print("Error saving PDF")
                        }
                    }
                } else if fileExtension == "mov" || fileExtension == "mp4" {
                    DataManager.sharedData.createFolder(fileData: fileData, fileName: fileName, fileType: "video", isFolder: false, parentID: parentID, isFavourite: false) { [weak self] isSuccess in
                        guard let self = self else { return }
                        if isSuccess {
                            self.fetchData()
                        } else {
                            print("Error saving video")
                        }
                    }
                } else if fileExtension == "jpg" || fileExtension == "png" {
                    DataManager.sharedData.createFolder(fileData: fileData, fileName: fileName, fileType: "image", isFolder: false, parentID: parentID, isFavourite: false) { [weak self] isSuccess in
                        guard let self = self else { return }
                        if isSuccess {
                            self.fetchData()
                        } else {
                            print("Error saving image")
                        }
                    }
                }
            } catch {
                print("Error reading file: \(error)")
            }
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            print("Document picker was cancelled")
            dismiss(animated: true, completion: nil)
        }
}
