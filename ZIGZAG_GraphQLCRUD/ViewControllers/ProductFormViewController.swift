//
//  ProductViewController.swift
//  ZIGZAG_GraphQLCRUD
//
//  Created by Paul Kim on 2019/10/11.
//  Copyright © 2019 Paul Kim. All rights reserved.
//

import UIKit
import Apollo

private enum Section: CaseIterable {
    case nameInfo
    case priceInfo
    case supplierInfo
    case descriptionInfo
    
    var title: String? {
        switch self {
        case .nameInfo:         return "%L%: 상품명"
        case .priceInfo:        return "%L%: 상품 가격"
        case .supplierInfo:     return "%L%: 공급자 정보"
        case .descriptionInfo:  return "%L%: 상세 설명"
        }
    }
}

private enum Row: Hashable {
    case nameKorean
    case nameEnglish
    
    case price
    
    case supplier
    
    case descriptionKorean
    
}

private class TableViewDiffableDataSource: UITableViewDiffableDataSource<Section, Row> {
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.snapshot().sectionIdentifiers[section].title
    }
}

class ProductFormViewController: UIViewController {
    enum Mode {
        case add
        case edit(Product)
    }
    
    @IBOutlet weak var tableView: UITableView!
    private lazy var dataSource = setupDataSource()
    
    private let mode: Mode
    private var product: Product
    
    init(mode: Mode) {
        self.mode = mode
        
        if case .edit(let product) = mode {
            self.product = product
        } else {
            self.product = Product()
        }
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        setupNavigationItem(mode: mode)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.reuseIdentifier)
        tableView.register(TextFieldTableViewCell.nib, forCellReuseIdentifier: TextFieldTableViewCell.reuseIdentifier)
        tableView.register(TextViewTableViewCell.nib, forCellReuseIdentifier: TextViewTableViewCell.reuseIdentifier)
        tableView.dataSource = dataSource
        
        ZAPINotificationCenter.addObserver(observer: self, selector: #selector(onDidCreateProductRequestUpdated(_:)), notification: .didCreateProductRequestUpdated)
        ZAPINotificationCenter.addObserver(observer: self, selector: #selector(onDidUpdateProductRequestUpdated(_:)), notification: .didUpdateProductRequestUpdated)
        
        updateDataSource(with: product)
    }
}

extension ProductFormViewController {
    private func setupDataSource() -> TableViewDiffableDataSource {
        return TableViewDiffableDataSource(tableView: self.tableView) { [weak self] (tableView, indexPath, row) -> UITableViewCell? in
            guard let self = self else { return nil }
            
            switch row {
            case .descriptionKorean:
                let cell = tableView.dequeueReusableCell(withIdentifier: TextViewTableViewCell.reuseIdentifier, for: indexPath) as! TextViewTableViewCell
                cell.textView.text = self.product.descriptionKo
                cell.textView.delegate = self
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldTableViewCell.reuseIdentifier, for: indexPath) as! TextFieldTableViewCell
                
                if case .nameKorean = row {
                    cell.textField.text = self.product.nameKo
                    cell.textField.placeholder = "%L%: 한국어 상품명"
                    cell.textFieldDidChange = { [weak self] textField in
                        guard let self = self else { return }
                        
                        self.product.nameKo = textField.text
                    }
                } else if case .nameEnglish = row {
                    cell.textField.text = self.product.nameEn
                    cell.textField.placeholder = "%L%: 영어 상품명"
                    cell.textFieldDidChange = { [weak self] textField in
                        guard let self = self else { return }
                        
                        self.product.nameEn = textField.text
                    }
                } else if case .price = row {
                    cell.textField.keyboardType = .numberPad
                    cell.textField.placeholder = "%L%: 상품 가격"
                    if let price = self.product.price {
                        cell.textField.text = String(price)
                    }
                    cell.textFieldDidChange = { [weak self] textField in
                        guard let self = self else { return }
                        guard let text = textField.text else { return }
                        guard let price = Int(text) else { return }
                        
                        self.product.price = price
                    }
                } else if case .supplier = row {
                    cell.textField.text = self.product.supplier?.name
                    cell.textField.placeholder = "%L%: 공급사"
                    cell.textField.isUserInteractionEnabled = false
                    cell.accessoryType = .disclosureIndicator
                }
                return cell
            }
        }
    }
}

extension ProductFormViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let row = dataSource.itemIdentifier(for: indexPath) else { return }
        
        if case .supplier = row {
            let suppliersViewController = SelectSupplierViewController(selectedSupplier: product.supplier) { [weak self] (selectSupplierViewController, selectedSupplier) in
                guard let self = self else { return }
                
                self.product.supplier = selectedSupplier
                self.updateDataSource(with: self.product)
                self.navigationController?.popViewController(animated: true)
            }
            navigationController?.pushViewController(suppliersViewController, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
}

extension ProductFormViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        guard let text = textView.text else { return }
        
        product.descriptionKo = text
    }
}

extension ProductFormViewController {
    private func updateDataSource(with product: Product) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Row>()
        snapshot.deleteAllItems()
        
        if case .add = mode {
            snapshot.appendSections([.nameInfo, .priceInfo, .supplierInfo])
            snapshot.appendItems([.nameKorean], toSection: .nameInfo)
            snapshot.appendItems([.price], toSection: .priceInfo)
            snapshot.appendItems([.supplier], toSection: .supplierInfo)
        } else {
            snapshot.appendSections(Section.allCases)
            snapshot.appendItems([.nameKorean, .nameEnglish], toSection: .nameInfo)
            snapshot.appendItems([.descriptionKorean], toSection: .descriptionInfo)
            snapshot.appendItems([.price], toSection: .priceInfo)
            snapshot.appendItems([.supplier], toSection: .supplierInfo)
        }
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func setupNavigationItem(mode: Mode) {
        switch mode {
        case .add:
            navigationItem.title = "%L%: 상품 추가"
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(onAddDone))
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(onCanceled))
        case .edit:
            navigationItem.title = "%L%: 상품 편집"
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(onEditDone))
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(onCanceled))
        }
        navigationItem.backBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)
    }
}

extension ProductFormViewController {
    @objc private func onEdit() {
        let productViewController = ProductFormViewController(mode: .edit(product))
        let productNavigationController = UINavigationController(rootViewController: productViewController)
        navigationController?.present(productNavigationController, animated: true, completion: nil)
    }
    
    @objc private func onAddDone() {
        guard let supplierId = product.supplier?.id else { return }
        guard let nameKo = product.nameKo else { return }
        guard let price = product.price else { return }
        
        let createProductInput = CreateProductInput(supplierId: supplierId, nameKo: nameKo, price: price)
        ZAPINotificationCenter.post(
            notification: .didCreateProductRequested,
            userInfo: [.createProductInput: createProductInput]
        )
    }
    
    @objc private func onEditDone() {
        //TODO: cell에 empty string 대응
        guard let productId = product.id else { return }
        guard let nameKo = product.nameKo else { return }
        guard let price = product.price else { return }
        
        let nameEn = product.nameEn ?? ""
        let descriptionEn = ""
        let descriptionKo = product.descriptionKo ?? ""
        
        let updateProductInput = UpdateProductInput(id: productId, nameKo: nameKo, nameEn: nameEn, descriptionKo: descriptionKo, descriptionEn: descriptionEn, price: price)
        ZAPINotificationCenter.post(notification: .didUpdateProductRequested, userInfo: [.updateProductInput: updateProductInput])
    }
    
    @objc private func onCanceled() {
        dismiss(animated: true, completion: nil)
    }
}

extension ProductFormViewController {
    @objc private func onDidCreateProductRequestUpdated(_ notification: Notification) {
        guard let data = notification.userInfo else { return }
        guard data[ZAPINotificationCenter.UserInfoKey.product] as? Product != nil else { return }
        
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func onDidUpdateProductRequestUpdated(_ notification: Notification) {
        guard let data = notification.userInfo else { return }
        guard let _ = data[ZAPINotificationCenter.UserInfoKey.product] as? Product else { return }
        
        dismiss(animated: true, completion: nil)
    }
}
