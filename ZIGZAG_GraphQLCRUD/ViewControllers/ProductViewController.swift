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
    case name
    case description
    case supplierInfo
    
    var title: String? {
        switch self {
        case .description:  return "제품 설명"
        case .supplierInfo: return "제품 정보"
        default:            return nil
        }
    }
}

private enum Row: Hashable {
    case nameKorean
    case nameEnglish
    
    case descriptionKorean
    
    case price
    case supplier
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
    
    private var product: Product {
        didSet {
            updateDataSource(with: product)
        }
    }
    
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
                cell.textView.text = self.product.descriptionKo
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldTableViewCell.reuseIdentifier, for: indexPath) as! TextFieldTableViewCell
                if case .view = self.mode {
                    cell.isUserInteractionEnabled = false
                }
                
                if case .nameKorean = row {
                    cell.textField.text = self.product.nameKo
                    cell.textField.placeholder = "%L%: 한국어 상품명"
                } else if case .nameEnglish = row {
                    cell.textField.text = self.product.nameEn?.isEmpty == false ? self.product.nameEn : "%L%: 영어 상품명 없음"
                    cell.textField.placeholder = "%L%: 영어 상품명"
                } else if case .price = row {
                    //TODO: number pad
                    if let priceKRW = self.product.price?.priceKRW {
                        cell.textField.text = priceKRW
                    } else {
                        if case .view = self.mode {
                            cell.textField.text = "%L%: 가격 없음"
                        }
                    }
                    cell.textField.placeholder = "%L%: 상품 가격"
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
                    self.navigationController?.popViewController(animated: true)
                }
                navigationController?.pushViewController(suppliersViewController, animated: true)
            default:
                break
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
}

extension ProductViewController {
    private func updateDataSource(with product: Product) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Row>()
        snapshot.appendSections(Section.allCases)
        
        if case .add = mode {
            snapshot.appendItems([.nameKorean], toSection: .name)
            snapshot.appendItems([.price, .supplier], toSection: .supplierInfo)
        } else  {
            snapshot.appendItems([.nameKorean, .nameEnglish], toSection: .name)
            snapshot.appendItems([.descriptionKorean], toSection: .description)
            snapshot.appendItems([.price, .supplier], toSection: .supplierInfo)
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
        case .edit:
            navigationItem.title = "%L%: 상품 편집"
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(onEditDone))
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
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func onEditDone() {
        dismiss(animated: true, completion: nil)
    }
}
