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
    
    var nextRowForAdd: Row? {
        switch self {
        case .nameKorean: return .price
        case .price: return .supplier
        default: return nil
        }
    }
    
    var nextRowForEdit: Row? {
        switch self {
        case .nameKorean: return .nameEnglish
        case .nameEnglish: return .price
        case .price: return .supplier
        case .supplier: return .descriptionKorean
        default: return nil
        }
    }
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
    private var product: Product {
        didSet {
            validateDoneButton()
        }
    }
    private var productEditSnapShot: Product?
    
    private var isMeaningfulUserAction: Bool {
        if case .add = mode {
            let isMeaningful = product.nameKo?.isEmpty == false ||
                product.price != nil ||
                product.supplier != nil
            return isMeaningful
        } else {
            let hasUserEdited: Bool = product.nameKo != productEditSnapShot?.nameKo ||
                product.nameEn != productEditSnapShot?.nameEn ||
                product.price != productEditSnapShot?.price ||
                product.supplier?.id != productEditSnapShot?.supplier?.id ||
                product.descriptionKo != productEditSnapShot?.descriptionKo
            return hasUserEdited
        }
    }
    
    init(mode: Mode) {
        self.mode = mode
        
        if case .edit(let product) = mode {
            self.product = product
            self.productEditSnapShot = product
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
        
        navigationController?.presentationController?.delegate = self
        
        tableView.register(TextFieldTableViewCell.nib, forCellReuseIdentifier: TextFieldTableViewCell.reuseIdentifier)
        tableView.register(TextViewTableViewCell.nib, forCellReuseIdentifier: TextViewTableViewCell.reuseIdentifier)
        tableView.dataSource = dataSource
        
        ZAPINotificationCenter.addObserver(observer: self, selector: #selector(onDidCreateProductRequestUpdated(_:)), notification: .didCreateProductRequestUpdated)
        ZAPINotificationCenter.addObserver(observer: self, selector: #selector(onDidUpdateProductRequestUpdated(_:)), notification: .didUpdateProductRequestUpdated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        validateDoneButton()
        updateDataSource(with: product)
        
        if let indexPath = dataSource.indexPath(for: .nameKorean) {
            tableView.cellForRow(at: indexPath)?.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        view.endEditing(true)
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
                    cell.textField.placeholder = "%L%: 한국어 상품명 (필수값)"
                    cell.textFieldDidChange = { [weak self] textField in
                        guard let self = self else { return }
                        
                        self.product.nameKo = textField.text
                    }
                    cell.textFieldDidEndOnExit = { [weak self] (textField) in
                        guard let self = self else { return }
                        
                        self.activateNextInput(for: .nameKorean)
                    }
                } else if case .nameEnglish = row {
                    cell.textField.text = self.product.nameEn
                    cell.textField.placeholder = "%L%: 영어 상품명"
                    cell.textFieldDidChange = { [weak self] textField in
                        guard let self = self else { return }
                        
                        self.product.nameEn = textField.text
                    }
                    cell.textFieldDidEndOnExit = { [weak self] (textField) in
                        guard let self = self else { return }
                        
                        self.activateNextInput(for: .nameEnglish)
                    }
                } else if case .price = row {
                    cell.textField.keyboardType = .numberPad
                    cell.textField.placeholder = "%L%: 상품 가격 (필수값)"
                    cell.addDoneButtonToolBar()
                    if let price = self.product.price {
                        cell.textField.text = String(price)
                    }
                    cell.textFieldDidChange = { [weak self] textField in
                        guard let self = self else { return }
                        guard let text = textField.text, text.isEmpty == false else {
                            self.product.price = nil
                            return
                        }
                        guard let price = Int32(text) else {
                            textField.text = String(self.product.price!)
                            return
                        }
                        
                        textField.text = String(price)
                        self.product.price = Int(price)
                    }
                    cell.textFieldDidEndOnExit = { [weak self] (textField) in
                        guard let self = self else { return }
                        
                        self.activateNextInput(for: .price)
                    }
                } else if case .supplier = row {
                    cell.textField.text = self.product.supplier?.name
                    cell.textField.placeholder = "%L%: 공급사를 선택하세요 (필수값)"
                    cell.textField.isUserInteractionEnabled = false
                    cell.selectionStyle = .default
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
            self.pickSupplier()
        } else {
            tableView.cellForRow(at: indexPath)?.becomeFirstResponder()
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
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.activateNextInput(for: .descriptionKorean)
    }
}

extension ProductFormViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        return isMeaningfulUserAction == false
    }
    
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
       onCanceled()
    }
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        onCanceled()
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
    private func activateNextInput(for row: Row) {
        let nextRow: Row
        
        if case .add = mode {
            guard let nextRowForAdd = row.nextRowForAdd else { return }
            
            nextRow = nextRowForAdd
        } else {
            guard let nextRowForEdit = row.nextRowForEdit else { return }
            
            nextRow = nextRowForEdit
        }
        
        if case .supplier = nextRow {
            pickSupplier()
        } else {
            guard let indexPath = dataSource.indexPath(for: nextRow) else { return }
            tableView.cellForRow(at: indexPath)?.becomeFirstResponder()
        }
    }
    
    private func pickSupplier() {
        let suppliersViewController = SelectSupplierViewController(selectedSupplier: product.supplier) { [weak self] (_, selectedSupplier) in
            guard let self = self else { return }
            
            self.product.supplier = selectedSupplier
            self.updateDataSource(with: self.product)
            
            self.navigationController?.popViewController(animated: true)
            self.activateNextInput(for: .supplier)
        }
        navigationController?.pushViewController(suppliersViewController, animated: true)
    }
    
    private func validateDoneButton() {
        navigationItem.rightBarButtonItem?.isEnabled = isMeaningfulUserAction && product.isValidInfo
    }
    
    @objc private func onAddDone() {
        guard let supplierId = product.supplier?.id else { return }
        guard let nameKo = product.nameKo else { return }
        guard let price = product.price else { return }
        
        view.endEditing(true)
        
        let createProductInput = CreateProductInput(supplierId: supplierId, nameKo: nameKo, price: price)
        ZAPINotificationCenter.post(
            notification: .didCreateProductRequested,
            userInfo: [.createProductInput: createProductInput]
        )
    }
    
    @objc private func onEditDone() {
        guard let productId = product.id else { return }
        guard let nameKo = product.nameKo else { return }
        guard let price = product.price else { return }
        
        let nameEn = product.nameEn ?? ""
        let descriptionEn = ""
        let descriptionKo = product.descriptionKo ?? ""
        
        view.endEditing(true)
        
        let updateProductInput = UpdateProductInput(id: productId, nameKo: nameKo, nameEn: nameEn, descriptionKo: descriptionKo, descriptionEn: descriptionEn, price: price)
        ZAPINotificationCenter.post(notification: .didUpdateProductRequested, userInfo: [.updateProductInput: updateProductInput])
    }
    
    @objc private func onCanceled() {
        if isMeaningfulUserAction {
            if case .add = mode {
                showEndEditAlert(title: "%L%: 새 상품 등록을 그만두시겠습니까?")
            } else {
                showEndEditAlert(title: "%L%: 이 변경사항을 폐기하겠습니까?")
            }
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
}

extension ProductFormViewController {
    @objc private func onDidCreateProductRequestUpdated(_ notification: Notification) {
        guard let state = notification.zAPIState else { return }

        switch state {
        case .loading:
            showLoader()
        case .failed:
            hideLoader()
            showNetworkErrorAlert()
        case .success:
            hideLoader()
            if let navigationView = navigationController?.view {
                HudView.hud(inView: navigationView, text: "생성 완료", animated: true) { [weak self] in
                    guard let self = self else { return }
                    
                    self.dismiss(animated: true, completion: nil)
                }
            }
        default:
            break
        }
    }
    
    @objc private func onDidUpdateProductRequestUpdated(_ notification: Notification) {
        guard let state = notification.zAPIState else { return }
        
        switch state {
        case .loading:
            showLoader()
        case .failed:
            hideLoader()
            showNetworkErrorAlert()
        case .success:
            hideLoader()
            if let navigationView = navigationController?.view {
                HudView.hud(inView: navigationView, text: "업데이트 완료", animated: true) { [weak self] in
                    guard let self = self else { return }
                    
                    self.dismiss(animated: true, completion: nil)
                }
            }
        default:
            break
        }
    }
}

extension ProductFormViewController {
    @objc private func keyboardWillShow(notification: Notification) {
        guard let animation = notification.keyboardAnimation else { return }
     
        let keyboardHeight = animation.frame.height
        
        UIView.animate(withDuration: animation.duration, delay: 0, options: animation.options, animations: { [weak self] in
            guard let self = self else { return }
            
            self.tableView.contentInset.bottom = keyboardHeight
            self.tableView.verticalScrollIndicatorInsets.bottom = keyboardHeight
            
            if let descriptionKoreanIndexPath = self.dataSource.indexPath(for: .descriptionKorean),
                let descriptionKoreanCell = self.tableView.cellForRow(at: descriptionKoreanIndexPath) as? TextViewTableViewCell,
                descriptionKoreanCell.textView.isFirstResponder
            {
                let rowMaxY = descriptionKoreanCell.frame.maxY - self.tableView.contentOffset.y
                let keyboardOriginY = self.tableView.frame.height - keyboardHeight
                if rowMaxY > keyboardOriginY {
                    self.tableView.contentOffset.y += keyboardHeight - (self.tableView.frame.height - rowMaxY)
                }
            }
        }, completion: nil)
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        guard let animation = notification.keyboardAnimation else { return }
        
        UIView.animate(withDuration: animation.duration, delay: 0, options: animation.options, animations: { [weak self] in
            guard let self = self else { return }
            
            self.tableView.contentInset.bottom = 0
            self.tableView.verticalScrollIndicatorInsets.bottom = 0
        }, completion: nil)
    }
}
