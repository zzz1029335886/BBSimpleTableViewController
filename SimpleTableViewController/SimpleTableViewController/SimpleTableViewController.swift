//
//  SimpleTableViewController.swift
//
//  Created by zerry on 2021/4/14.
//  Copyright © 2021 yoao. All rights reserved.
//

import UIKit

protocol SimpleTableViewModelProtocol: class{
    func simpleTableViewCell(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell?
    func simpleTableViewCellHeight(_ tableView: UITableView, indexPath: IndexPath) -> CGFloat?
    func simpleTableViewCellSelected(_ tableView: UITableView, indexPath: IndexPath)
}

extension SimpleTableViewModelProtocol {
    func simpleTableViewCell(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell? { return nil }
    func simpleTableViewCellHeight(_ tableView: UITableView, indexPath: IndexPath) -> CGFloat? { return nil }
    func simpleTableViewCellSelected(_ tableView: UITableView, indexPath: IndexPath) { }
}

protocol SimpleTableViewProtocol : class{
    
    /// 二维数组：与rows二选一
    var rowSections: [[SimpleTableViewModelProtocol]]? {set get}
    /// 一维数组：与rowSections二选一
    var rows: [SimpleTableViewModelProtocol]? {set get}
    /// cellNib：与cellType二选一
    var cellNib: UINib? {set get}
    /// cellType：与cellNib二选一
    var cellType: UITableViewCell.Type? {get set}
    /// 自定义tableView
    var tableView: UITableView? {set get}
}

protocol SimpleTableViewControllerProtocol: class {
    var simpleTableViewController: SimpleTableViewController? {set get}
}

extension SimpleTableViewControllerProtocol where Self : UIViewController{
    
}

class SimpleTableViewConfig: NSObject, SimpleTableViewProtocol{
    var rowSections: [[SimpleTableViewModelProtocol]]?
    var rows: [SimpleTableViewModelProtocol]?
    
    var cellType: UITableViewCell.Type?
    var tableView: UITableView?
    var cellNib: UINib?
    
    init(
        tableView: UITableView? = nil,
        rowSections: [[SimpleTableViewModelProtocol]]? = nil,
        rows: [SimpleTableViewModelProtocol]? = nil,
        cellType: UITableViewCell.Type? = nil,
        cellNib: UINib? = nil
    ){
        super.init()
        self.tableView = tableView
        self.rowSections = rowSections
        self.rows = rows
        self.cellType = cellType
        self.cellNib = cellNib
    }
    
}

class SimpleTableViewController: UIViewController, SimpleTableViewControllerProtocol {
    var simpleTableViewController: SimpleTableViewController?
    
    typealias CallBack = (SimpleTableViewModelProtocol, UITableViewCell, IndexPath) -> Void
    typealias ReturnSelfCallBack = (SimpleTableViewController) -> Void
    
    convenience init<M: Any, Cell: UITableViewCell>(_ tableViewConfig: SimpleTableViewProtocol,
                                                    modelType: M.Type,
                                                    cellType: Cell.Type,
                                                    viewDidLoad: ReturnSelfCallBack?,
                                                    setCell: ((M, Cell, IndexPath) -> Void)?,
                                                    clickCell: ((M, Cell, IndexPath) -> Void)?
    ){
        self.init()
        self.tableViewConfig = tableViewConfig
        self.modelType = modelType
        self.cellType = cellType
        
        self.viewDidLoadCallBack = viewDidLoad
        
        if let setCell = setCell {
            self.setCell = {
                (model, cell, indexPath) in
                if cell is Cell{
                    setCell(model as! M, cell as! Cell, indexPath)
                }
            }
        }
        
        if let clickCell = clickCell {
            self.clickCell = {
                (model, cell, indexPath) in
                if cell is Cell{
                    clickCell(model as! M, cell as! Cell, indexPath)
                }
            }
        }
    }
    
    var tableViewConfig: SimpleTableViewProtocol?
    var modelType: Any?
    var cellType: Any?
    
    var setCell: CallBack?
    var clickCell: CallBack?
    var viewDidLoadCallBack: ReturnSelfCallBack?
    
    var tableView = UITableView.init(frame: .zero, style: .grouped)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let tableView = self.tableViewConfig?.tableView {
            self.tableView = tableView
        }
        
        if #available(iOS 11.0, *) {
            tableView.safeAreaInsetsDidChange()
        } else {
            // Fallback on earlier versions
        }
        tableView.tableHeaderView = UIView.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0.1))
        setupTableView()
        
        self.viewDidLoadCallBack?(self)
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint.init(item: tableView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint.init(item: tableView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint.init(item: tableView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint.init(item: tableView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0))
        
        if let cellNib = self.tableViewConfig?.cellNib {
            tableView.register(cellNib, forCellReuseIdentifier: "SimpleTableViewControllerCell")
        }
        
        if let cellType = self.tableViewConfig?.cellType {
            tableView.register(cellType, forCellReuseIdentifier: "SimpleTableViewControllerCell")
        }        
    }
    
    func reload() {
        tableView.reloadData()
    }
}

extension SimpleTableViewController: UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableViewConfig?.rows != nil {
            return 1
        }
        
        if let rowSections = tableViewConfig?.rowSections {
            return rowSections.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let rows = tableViewConfig?.rows {
            return rows.count
        }
        
        if let rowSections = tableViewConfig?.rowSections {
            return rowSections[section].count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let model = self.getModel(indexPath) else { return UITableViewCell() }
        
        var cell: UITableViewCell!
        
        cell = model.simpleTableViewCell(tableView, indexPath: indexPath)
        
        if cell == nil {
            cell = tableView.dequeueReusableCell(withIdentifier: "SimpleTableViewControllerCell")
        }
        
        if let setCell = self.setCell {
            setCell(model, cell, indexPath)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let model = self.getModel(indexPath) else { return UITableView.automaticDimension }
        
        if let height = model.simpleTableViewCellHeight(tableView, indexPath: indexPath){
            return height
        }else {
            return tableView.rowHeight
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let model = self.getModel(indexPath) else { return }
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        model.simpleTableViewCellSelected(tableView, indexPath: indexPath)
        
        if let clickCell = self.clickCell {
            clickCell(model, cell, indexPath)
        }
    }
    
    func getModel(_ indexPath: IndexPath) -> SimpleTableViewModelProtocol? {
        
        var model : SimpleTableViewModelProtocol?
        
        if let rows = tableViewConfig?.rows {
            model = rows[indexPath.row]
        }else if let rowSections = tableViewConfig?.rowSections{
            model = rowSections[indexPath.section][indexPath.row]
        }
        
        return model
    }
}

extension SimpleTableViewController{
    
    class func pushFrom<M: Any, Cell: UITableViewCell>(_ viewController: SimpleTableViewControllerProtocol,
                                                       title: String,
                                                       tableViewConfig: SimpleTableViewProtocol,
                                                       modelType: M.Type,
                                                       cellType: Cell.Type,
                                                       viewDidLoad: SimpleTableViewController.ReturnSelfCallBack? = nil,
                                                       clickCell: ((M, Cell, IndexPath) -> Void)? = nil,
                                                       setCell: @escaping (M, Cell, IndexPath) -> Void
    ){
        var controller : SimpleTableViewController?
        if let viewController = viewController as? UIViewController {
            controller = viewController.pushSimpleController(title, navigationController: viewController.navigationController, tableViewConfig: tableViewConfig, modelType: modelType, cellType: cellType, viewDidLoad: viewDidLoad, clickCell: clickCell, setCell: setCell)
        }
        viewController.simpleTableViewController = controller

    }
}

extension UIViewController{
    
    @discardableResult
    func pushSimpleController<M: Any, Cell: UITableViewCell>(_ title: String,
                                                             navigationController: UINavigationController? = nil,
                                                             tableViewConfig: SimpleTableViewProtocol,
                                                             modelType: M.Type,
                                                             cellType: Cell.Type,
                                                             viewDidLoad: SimpleTableViewController.ReturnSelfCallBack? = nil,
                                                             clickCell: ((M, Cell, IndexPath) -> Void)? = nil,
                                                             setCell: ((M, Cell, IndexPath) -> Void)? = nil
    ) -> SimpleTableViewController{
        
        let controller = SimpleTableViewController(tableViewConfig,
                                                     modelType: modelType,
                                                     cellType: cellType,
                                                     viewDidLoad: viewDidLoad,
                                                     setCell: setCell,
                                                     clickCell: clickCell)
        controller.title = title
        (navigationController ?? self.navigationController)?.pushViewController(controller, animated: true)
        return controller
    }
}

