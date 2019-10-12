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
    case descriptionInfo
    case priceInfo
    case supplierInfo
    case deleteProduct
    
    var title: String? {
        switch self {
        case .nameInfo:         return "L%L: 상품명"
        case .descriptionInfo:  return "%L%: 상세 설명"
        case .priceInfo:        return "L%L: 상품 가격"
        case .supplierInfo:     return "%L%: 공급자 정보"
        default:                return nil
        }
    }
}

private enum Row: Hashable {
    case nameKorean
    case nameEnglish
    
    case descriptionKorean
    
    case price
    case supplier
    
    case delete
}

private class TableViewDiffableDataSource: UITableViewDiffableDataSource<Section, Row> {
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.snapshot().sectionIdentifiers[section].title
    }
}

class ProductViewController: UIViewController {
    enum Mode {
        case view(Product)
        case add
        case edit(Product)
    }
    
    @IBOutlet weak var tableView: UITableView!
    private lazy var dataSource = setupDataSource()
    
    private let mode: Mode
    
    private var product: Product
    
    init(mode: Mode) {
        self.mode = mode
        
        if case .view(let product) = mode {
            self.product = product
        } else if case .edit(let product) = mode {
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
        
        ZAPINotificationCenter.addObserver(observer: self, selector: #selector(onDidCreateProductRequestUpdated(_:)), notification: .didProductRequestUpdated)
        ZAPINotificationCenter.addObserver(observer: self, selector: #selector(onDidCreateProductRequestUpdated(_:)), notification: .didCreateProductRequestUpdated)
        ZAPINotificationCenter.addObserver(observer: self, selector: #selector(onDidUpdateProductRequestUpdated(_:)), notification: .didUpdateProductRequestUpdated)
        ZAPINotificationCenter.addObserver(observer: self, selector: #selector(onDidDeleteProductRequestUpdated(_:)), notification: .didDeleteProductRequestUpdated)
        
        updateDataSource(with: product)
    }
}

extension ProductViewController {
    private func setupDataSource() -> TableViewDiffableDataSource {
        return TableViewDiffableDataSource(tableView: self.tableView) { [weak self] (tableView, indexPath, row) -> UITableViewCell? in
            guard let self = self else { return nil }
            
            switch row {
            case .descriptionKorean:
                let cell = tableView.dequeueReusableCell(withIdentifier: TextViewTableViewCell.reuseIdentifier, for: indexPath) as! TextViewTableViewCell
                cell.textView.text = "%L%: 상세 설명 없음"
                if case .view = self.mode {
                    cell.textViewHeightLayoutConstraint.constant = ceil(cell.textView.sizeThatFits(CGSize(width: cell.textView.frame.width, height: .infinity)).height)
                    cell.isUserInteractionEnabled = false
                }
                return cell
            case .delete:
                let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.reuseIdentifier, for: indexPath)
                cell.textLabel?.text = "%L%: 제품 삭제하기"
                cell.textLabel?.textColor = .red
                cell.textLabel?.textAlignment = .center
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldTableViewCell.reuseIdentifier, for: indexPath) as! TextFieldTableViewCell
                
                if case .view = self.mode {
                    cell.isUserInteractionEnabled = false
                }
                
                if case .nameKorean = row {
                    cell.textField.text = self.product.nameKo
                    cell.textField.placeholder = "%L%: 한국어 상품명"
                    cell.textFieldDidChange = { [weak self] textField in
                        guard let self = self else { return }
                        
                        self.product.nameKo = textField.text
                    }
                } else if case .nameEnglish = row {
                    cell.textField.text = self.product.nameEn?.isEmpty == false ? self.product.nameEn : "%L%: 영어 상품명 없음"
                    cell.textField.placeholder = "%L%: 영어 상품명"
                    cell.textFieldDidChange = { [weak self] textField in
                        guard let self = self else { return }
                        
                        self.product.nameEn = textField.text
                    }
                } else if case .price = row {
                    cell.textField.keyboardType = .numberPad
                    cell.textField.placeholder = "%L%: 상품 가격"
                    if case .view = self.mode {
                        cell.textField.text = self.product.price?.priceKRW ?? "%L%: 가격 없음"
                    } else {
                        if let price = self.product.price {
                            cell.textField.text = String(price)
                        }
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
                    if case .view = self.mode {
                        cell.accessoryType = .none
                    } else {
                        cell.accessoryType = .disclosureIndicator
                    }
                }
                return cell
            }
        }
    }
}

extension ProductViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let row = dataSource.itemIdentifier(for: indexPath) else { return }
        
        if case .supplier = row {
            switch mode {
            case .add, .edit:
                let suppliersViewController = SelectSupplierViewController(selectedSupplier: product.supplier) { [weak self] (selectSupplierViewController, selectedSupplier) in
                    guard let self = self else { return }
                    
                    self.product.supplier = selectedSupplier
                    self.updateDataSource(with: self.product)
                    self.navigationController?.popViewController(animated: true)
                }
                navigationController?.pushViewController(suppliersViewController, animated: true)
            default:
                break
            }
        } else if case .delete = row {
            guard let productId = product.id else { return }
            
            let deleteProductInput = DeleteProductInput(id: productId)
            ZAPINotificationCenter.post(notification: .didDeleteProductRequested, userInfo: [.deleteProductInput: deleteProductInput])
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
}

extension ProductViewController {
    private func updateDataSource(with product: Product) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Row>()
        snapshot.deleteAllItems()
        
        if case .add = mode {
            snapshot.appendSections([.nameInfo, .priceInfo, .supplierInfo])
            snapshot.appendItems([.nameKorean], toSection: .nameInfo)
            snapshot.appendItems([.price], toSection: .priceInfo)
            snapshot.appendItems([.supplier], toSection: .supplierInfo)
        } else {
            snapshot.appendSections([.nameInfo, .descriptionInfo, .priceInfo, .supplierInfo])
            snapshot.appendItems([.nameKorean, .nameEnglish], toSection: .nameInfo)
            snapshot.appendItems([.descriptionKorean], toSection: .descriptionInfo)
            snapshot.appendItems([.price], toSection: .priceInfo)
            snapshot.appendItems([.supplier], toSection: .supplierInfo)
            
            if case .view = mode {
                snapshot.appendSections([.deleteProduct])
                snapshot.appendItems([.delete], toSection: .deleteProduct)
            }
        }
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func setupNavigationItem(mode: Mode) {
        switch mode {
        case .view:
            navigationItem.title = "%L%: 상품 상세"
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(onEdit))
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

extension ProductViewController {
    @objc private func onEdit() {
        let productViewController = ProductViewController(mode: .edit(product))
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

extension ProductViewController {
    @objc private func onDidProductRequestUpdated(_ notification: Notification) {
        guard let data = notification.userInfo else { return }
        guard let product = data[ZAPINotificationCenter.UserInfoKey.product] as? Product else { return }
        
        self.product = product
        updateDataSource(with: self.product)
    }
    
    @objc private func onDidCreateProductRequestUpdated(_ notification: Notification) {
        guard let data = notification.userInfo else { return }
        guard data[ZAPINotificationCenter.UserInfoKey.product] as? Product != nil else { return }
        
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func onDidUpdateProductRequestUpdated(_ notification: Notification) {
        guard let data = notification.userInfo else { return }
        guard let product = data[ZAPINotificationCenter.UserInfoKey.product] as? Product else { return }
        
        if case .view = mode {
            self.product = product
            updateDataSource(with: self.product)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @objc private func onDidDeleteProductRequestUpdated(_ notification: Notification) {
        guard let data = notification.userInfo else { return }
        guard let _ = data[ZAPINotificationCenter.UserInfoKey.product] as? Product else { return }
        
        navigationController?.popViewController(animated: true)
    }
}
