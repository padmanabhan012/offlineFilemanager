//
//  ViewController.swift
//  FileManager
//
//  Created by Rahul P John on 18/01/25.
//

import UIKit
//import CoreData

class ViewController: UIViewController {
    
    @IBOutlet weak var fileListCollectionView: UICollectionView!
    
    var folderList = [AddFiles]()
    var folderFavouriteList = [AddFiles]()
    
    var isFavorite: Bool = false
    let colorPicker = UIColorPickerViewController()
    var selectedFolderID = String()
    
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
        title = "Folders"
        
        // implementing left nav button for add new folder
        
        self.navigationItem.setLeftBarButton(createAddFolderButton(), animated: true)
        self.navigationItem.rightBarButtonItems = [createSortingButton(), createFavouriteButton()]
    }
    
    func createAddFolderButton() -> UIBarButtonItem {
        let addNewFolder = UIButton()
        addNewFolder.setImage(UIImage(systemName: "plus"), for: .normal)
        addNewFolder.addTarget(self, action: #selector(didTapAddFolderButton(_:)), for: .touchUpInside)
        let leftBarButton = UIBarButtonItem(customView: addNewFolder)
        return leftBarButton
    }
    
    func createFavouriteButton() -> UIBarButtonItem {
        let customButton = UIButton()
        customButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        customButton.addTarget(self, action: #selector(didTapFavouriteButton(_:)), for: .touchUpInside)
        let rightBarButton = UIBarButtonItem(customView: customButton)
        return rightBarButton
    }
    
    func createSortingButton() -> UIBarButtonItem {
        let customButton = UIButton()
        customButton.setTitle("Sort", for: .normal)
        customButton.setTitleColor(UIColor.tintColor, for: .normal)
        customButton.addTarget(self, action: #selector(didTapSortingButton(_:)), for: .touchUpInside)
        let rightBarButton = UIBarButtonItem(customView: customButton)
        return rightBarButton
    }
    
    // Button Actions
    
    @objc
    private func didTapAddFolderButton(_ sender: UIButton) {
        addFolderPopup()
    }
    
    @objc
    private func didTapFavouriteButton(_ sender: UIButton) {
        if isFavorite == false {
            folderFavouriteList.removeAll()
            folderFavouriteList = folderList.filter({ $0.isFavourite == true})
            fileListCollectionView.reloadData()
            isFavorite = true
        } else {
            folderFavouriteList.removeAll()
            fileListCollectionView.reloadData()
            isFavorite = false
        }
    }
    
    @objc
    private func didTapSortingButton(_ sender: UIButton) {
        let alert = UIAlertController(title: "Sort", message: "", preferredStyle: .actionSheet)
        let byDate = UIAlertAction(title: "Date", style: .default) { [weak self] _ in
            guard let self = self else { return }
            folderList = folderList.sorted(by: {$1.createdAt ?? Date() > $0.createdAt ?? Date()})
            folderFavouriteList = folderFavouriteList.sorted(by: {$1.createdAt ?? Date() > $0.createdAt ?? Date()})
            fileListCollectionView.reloadData()
        }
        
        let byName = UIAlertAction(title: "Name", style: .default) { [weak self] _ in
            guard let self = self else { return }
            folderList = folderList.sorted(by: {$1.folderName ?? "" > $0.folderName ?? ""})
            folderFavouriteList = folderFavouriteList.sorted(by: {$1.folderName ?? "" > $0.folderName ?? ""})
            fileListCollectionView.reloadData()
        }
        
        alert.addAction(byDate)
        alert.addAction(byName)
        present(alert, animated: true)
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
                    fetchData()
                } else {
                    let alert = UIAlertController(title: "File Manager", message: "Error while saving data", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default)
                    alert.addAction(okAction)
                    present(alert, animated: true)
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(createAction)
        alert.addAction(cancelAction)
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
                    present(alert, animated: true)
                    return
                }
                folderList = fetchedData.filter({ $0.isFolder == true })
                folderFavouriteList.removeAll()
                folderFavouriteList = folderList.filter({ $0.isFavourite == true})
                fileListCollectionView.delegate = self
                fileListCollectionView.dataSource = self
                fileListCollectionView.reloadData()
            } else {
                let alert = UIAlertController(title: "File Manager", message: "Error while fetching data", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default)
                alert.addAction(okAction)
                present(alert, animated: true)
            }
        }
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return isFavorite == true ? folderFavouriteList.count : folderList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let fileListCell = collectionView.dequeueReusableCell(withReuseIdentifier: "FIleListCollectionViewCell", for: indexPath) as? FIleListCollectionViewCell else { return UICollectionViewCell() }
        let data = isFavorite == true ? folderFavouriteList[indexPath.item] : folderList[indexPath.item]
//        UIImage
        fileListCell.imgFolder.image = UIImage(named: "file")?.withRenderingMode(.alwaysTemplate)
        fileListCell.imgFolder.tintColor = UIColor(hex: data.folderColor ?? "#5AC5FA")
        fileListCell.lblFolderName.text = data.folderName
        if data.isFavourite == true {
            fileListCell.btnFavourite.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        } else {
            fileListCell.btnFavourite.setImage(UIImage(systemName: "heart"), for: .normal)
        }
        fileListCell.vwBackground.tag = indexPath.item
        fileListCell.vwBackground.isUserInteractionEnabled = true
        fileListCell.vwBackground.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(didLongPressView(_:))))
        return fileListCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let data = folderList[indexPath.item]
        let VC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FolderDetailsViewController") as! FolderDetailsViewController
        VC.parentID = data.id ?? ""
        VC.parentName = data.folderName ?? ""
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    @objc
    private func didLongPressView(_ sender: UILongPressGestureRecognizer) {
        let location = sender.location(in: fileListCollectionView)
        if sender.state == .began || sender.state == .changed {
            guard let indexPath = fileListCollectionView.indexPathForItem(at: location) else { return }
            let data = folderList[indexPath.item]
            selectedFolderID = data.id ?? ""
            favouriteActionAlert(id: data.id ?? "")
        }
    }
    
    func favouriteActionAlert(id: String) {
        let alert = UIAlertController(title: "Favourite", message: "", preferredStyle: .actionSheet)
        let okAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let self = self else { return }
            colorPicker.delegate = self
            present(colorPicker, animated: true, completion: nil)
        }
        let removeAction = UIAlertAction(title: "Remove", style: .default) { _ in
            DataManager.sharedData.updateDate(id: id, isFavourite: false, folderColor: "#5AC5FA") { [weak self] isSuccess in
                guard let self = self else { return }
                if isSuccess {
                    fetchData()
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        alert.addAction(removeAction)
        present(alert, animated: true)
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
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

extension ViewController: UIColorPickerViewControllerDelegate {
    func colorPickerViewController(_ viewController: UIColorPickerViewController, didSelect color: UIColor, continuously: Bool) {
        colorPicker.dismiss(animated: true)
        let alert = UIAlertController(title: "Add to favourite", message: "", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let self = self else { return }
            DataManager.sharedData.updateDate(id: selectedFolderID, isFavourite: true, folderColor: color.toHex() ?? "#5AC5FA") { [weak self] isSuccess in
                guard let self = self else { return }
                if isSuccess {
                    fetchData()
                }
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(okAction)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
    
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
    }
}
