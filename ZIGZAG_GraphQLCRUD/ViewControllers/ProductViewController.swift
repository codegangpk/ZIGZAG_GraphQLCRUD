//
//  ProductViewController.swift
//  ZIGZAG_GraphQLCRUD
//
//  Created by Paul Kim on 2019/10/13.
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
    @IBOutlet weak var tableView: UITableView!
    private lazy var dataSource = setupDataSource()
    
    private var productId: String
    private var product: Product? {
        didSet {
            if let product = product {
                updateDataSource(with: product)
            }
        }
    }
    
    init(productId: String) {
        self.productId = productId
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        setupNavigationItem()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.reuseIdentifier)
        tableView.register(TextFieldTableViewCell.nib, forCellReuseIdentifier: TextFieldTableViewCell.reuseIdentifier)
        tableView.register(TextViewTableViewCell.nib, forCellReuseIdentifier: TextViewTableViewCell.reuseIdentifier)
        tableView.dataSource = dataSource
        
        ZAPINotificationCenter.addObserver(observer: self, selector: #selector(onDidProductRequestUpdated(_:)), notification: .didProductRequestUpdated)
        ZAPINotificationCenter.addObserver(observer: self, selector: #selector(onDidUpdateProductRequestUpdated(_:)), notification: .didUpdateProductRequestUpdated)
        ZAPINotificationCenter.addObserver(observer: self, selector: #selector(onDidDeleteProductRequestUpdated(_:)), notification: .didDeleteProductRequestUpdated)
        
        updateDataSource(with: product)
        fetchProduct(with: productId)
    }
}

extension ProductViewController {
    private func setupDataSource() -> TableViewDiffableDataSource {
        return TableViewDiffableDataSource(tableView: self.tableView) { [weak self] (tableView, indexPath, row) -> UITableViewCell? in
            guard let self = self else { return nil }
            
            switch row {
            case .descriptionKorean:
                let cell = tableView.dequeueReusableCell(withIdentifier: TextViewTableViewCell.reuseIdentifier, for: indexPath) as! TextViewTableViewCell
                cell.textView.text = self.product?.descriptionKo ?? "%L%: (상세 설명 미제공)"
                cell.textViewHeightLayoutConstraint.constant = ceil(cell.textView.sizeThatFits(CGSize(width: cell.textView.frame.width, height: .infinity)).height)
                cell.isUserInteractionEnabled = false
                return cell
            case .delete:
                let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.reuseIdentifier, for: indexPath)
                cell.textLabel?.text = "%L%: 제품 삭제하기"
                cell.textLabel?.textColor = .red
                cell.textLabel?.textAlignment = .center
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldTableViewCell.reuseIdentifier, for: indexPath) as! TextFieldTableViewCell
                
                cell.isUserInteractionEnabled = false
                
                if case .nameKorean = row {
                    cell.textField.text = self.product?.nameKo
                    cell.textField.placeholder = "%L%: 한국어 상품명"
                    cell.textFieldDidChange = { [weak self] textField in
                        guard let self = self else { return }
                        
                        self.product?.nameKo = textField.text
                    }
                } else if case .nameEnglish = row {
                    cell.textField.text = self.product?.nameEn?.isEmpty == false ? self.product?.nameEn : "%L%: (영어 상품명 미제공)"
                    cell.textField.placeholder = "%L%: 영어 상품명"
                    cell.textFieldDidChange = { [weak self] textField in
                        guard let self = self else { return }
                        
                        self.product?.nameEn = textField.text
                    }
                } else if case .price = row {
                    cell.textField.keyboardType = .numberPad
                    cell.textField.placeholder = "%L%: 상품 가격"
                    cell.textField.text = self.product?.price?.priceKRW ?? "%L%: (가격 미제공)"
                    cell.textFieldDidChange = { [weak self] textField in
                        guard let self = self else { return }
                        guard let text = textField.text else { return }
                        guard let price = Int(text) else { return }
                        
                        self.product?.price = price
                    }
                } else if case .supplier = row {
                    cell.textField.text = self.product?.supplier?.name
                    cell.textField.placeholder = "%L%: 공급사"
                    cell.textField.isUserInteractionEnabled = false
                    cell.accessoryType = .none
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
        
        if case .delete = row {
            let deleteProductInput = DeleteProductInput(id: productId)
            ZAPINotificationCenter.post(notification: .didDeleteProductRequested, userInfo: [.deleteProductInput: deleteProductInput])
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
}

extension ProductViewController {
    private func fetchProduct(with productId: String) {
        ZAPINotificationCenter.post(notification: .didProductRequested, object: self, userInfo: [.productId: productId])
    }
    
    private func updateDataSource(with product: Product?) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Row>()
        snapshot.deleteAllItems()

        if product != nil {
            snapshot.appendSections(Section.allCases)
            
            snapshot.appendItems([.nameKorean, .nameEnglish], toSection: .nameInfo)
            snapshot.appendItems([.descriptionKorean], toSection: .descriptionInfo)
            snapshot.appendItems([.price], toSection: .priceInfo)
            snapshot.appendItems([.supplier], toSection: .supplierInfo)
            snapshot.appendItems([.delete], toSection: .deleteProduct)
        }
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func setupNavigationItem() {
        navigationItem.title = "%L%: 상품 상세"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(onEdit))
        navigationItem.backBarButtonItem = UIBarButtonItem(title: nil, style: .plain, target: nil, action: nil)
    }
}

extension ProductViewController {
    @objc private func onEdit() {
        guard let product = product else { return }
        
        let productViewController = ProductFormViewController(mode: .edit(product))
        let productNavigationController = UINavigationController(rootViewController: productViewController)
        navigationController?.present(productNavigationController, animated: true, completion: nil)
    }
}

extension ProductViewController {
    @objc private func onDidProductRequestUpdated(_ notification: Notification) {
        guard let data = notification.userInfo else { return }
        guard let product = data[ZAPINotificationCenter.UserInfoKey.product] as? Product else { return }
        
        self.product = product
    }
    
    @objc private func onDidUpdateProductRequestUpdated(_ notification: Notification) {
        guard let data = notification.userInfo else { return }
        guard let product = data[ZAPINotificationCenter.UserInfoKey.product] as? Product else { return }

        self.product = product
    }
    
    @objc private func onDidDeleteProductRequestUpdated(_ notification: Notification) {
        guard let data = notification.userInfo else { return }
        guard let _ = data[ZAPINotificationCenter.UserInfoKey.product] as? Product else { return }
        
        navigationController?.popViewController(animated: true)
    }
}
