//
//  AddWatchDeviceViewController.swift
//  MiHome
//
//  Created by CoolKernel on 9/14/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

import UIKit

fileprivate let cellReuseIdentifier = "cellReuseIdentifier_addWatchDevCell"
class AddWatchDeviceViewController: UIViewController {

    fileprivate lazy var tableview: UITableView = {
        return UITableView(frame: self.view.bounds, style: .grouped)
    }()
    
    var completion: ((_ saveDevList: [MHDataWatchDeviceConfig]?) -> Void)!
    
    var watchDevList: [MHDataWatchDeviceConfig] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableview)
        tableview.delegate = self
        tableview.dataSource = self
        tableview.register(WatchAddDeviceTableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        tableview.rowHeight = 63.0
        tableview.sectionFooterHeight = 0.0
        tableview.sectionHeaderHeight = 0.0
        tableview.separatorColor = color(withRGB: 0xE1E1E1)
        tableview.backgroundColor = color(withRGB: 0xf6f6f6)
        tableview.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 44, right: 0)
        setEditing(true, animated: true)
        self.view.backgroundColor = color(withRGB: 0xf6f6f6)
        
        let sureBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 70, height: 40))
        sureBtn.setTitle(NSLocalizedString("Ok", comment: "确定"), for: .normal)
        sureBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -7)
        sureBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17.0)
        sureBtn.contentHorizontalAlignment = .right
        sureBtn.setTitleColor(color(withRGB: 0x00bc9c), for: .normal)
        sureBtn.addTarget(self, action: #selector(self.sureAction), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: sureBtn)

        let cancelBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 70, height: 40))
        cancelBtn.setTitle(NSLocalizedString("Cancel", comment: "取消"), for: .normal)
        cancelBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: -7, bottom: 0, right: 0)
        cancelBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17.0)
        cancelBtn.contentHorizontalAlignment = .left
        cancelBtn.setTitleColor(UIColor.lightGray, for: .normal)
        cancelBtn.addTarget(self, action: #selector(self.cancelAction), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: cancelBtn)
        
        self.blankView.removeFromSuperview()
        if watchDevList.count == 0 {
            self.view.addSubview(self.blankView)
        }
    }
    
    @objc
    func sureAction() {
        _ = navigationController?.popViewController(animated: true)
        completion(watchDevList)
    }
    
    @objc
    func cancelAction() {
        _ = navigationController?.popViewController(animated: true)
        completion(nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension AddWatchDeviceViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return watchDevList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! WatchAddDeviceTableViewCell
        let model = watchDevList[indexPath.row]
        cell.titleLabel.text = model.name
        let device = MHDevListManager.shared().device(forDid: model.did)
        cell.iconImageView.loadIcon(for: device)
        if model.visible {
            tableview.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        } else {
            tableview.deselectRow(at: indexPath, animated: false)
        }
        
        return cell
    }
}

extension AddWatchDeviceViewController {
    @objc(tableView:didSelectRowAtIndexPath:)
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = watchDevList[indexPath.row]
        model.visible = true
    }
    
    @objc(tableView:didDeselectRowAtIndexPath:)
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let model = watchDevList[indexPath.row]
        model.visible = false
    }
}

//MARK: 编辑
extension AddWatchDeviceViewController {
    override func setEditing(_ editing: Bool, animated: Bool) {
        tableview.setEditing(editing, animated: animated)
    }
    
    @objc(tableView:canEditRowAtIndexPath:)
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    @objc(tableView:commitEditingStyle:forRowAtIndexPath:)
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
    }
    
    @objc(tableView:moveRowAtIndexPath:toIndexPath:)
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let m = watchDevList[sourceIndexPath.row]
        watchDevList.remove(at: sourceIndexPath.row)
        watchDevList.insert(m, at: destinationIndexPath.row)
        tableview.moveRow(at: sourceIndexPath, to: destinationIndexPath)
        updateAllRowSelectStatus()
    }
    
    @objc(tableView:targetIndexPathForMoveFromRowAtIndexPath:toProposedIndexPath:)
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        if sourceIndexPath.section == proposedDestinationIndexPath.section {
            return proposedDestinationIndexPath
        }
        
        return sourceIndexPath
    }
    
    @objc(tableView:heightForHeaderInSection:)
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 21
    }
    
    @objc(tableView:viewForHeaderInSection:)
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.bounds.size.width, height: 21))
        view.backgroundColor = color(withRGB: 0xf6f6f6)
        return view
    }
    
    @objc(tableView:editingStyleForRowAtIndexPath:)
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return UITableViewCell.EditingStyle.init(rawValue: (1 | 2))!
    }
}

extension AddWatchDeviceViewController {
    var blankView: UIView {
        let bv = UIView(frame: self.view.bounds)
        bv.backgroundColor = UIColor.white
        
        let icon = UIImageView(image: UIImage.init(named: "tableview_blank_logo"))
        icon.center = CGPoint(x: bv.center.x, y: bv.center.y - 50)
        bv.addSubview(icon)
        
        let lab = UILabel(frame: CGRect(x: 0, y: icon.frame.maxY, width: 250, height: 20))
        lab.center = CGPoint(x: bv.center.x, y: lab.center.y)
        lab.text = NSLocalizedString("list.blank", comment: "列表内容为空")
        lab.textAlignment = .center
        lab.textColor = color(withRGB: 0x666666)
        lab.font = UIFont.systemFont(ofSize: 15.0)
        bv.addSubview(lab)
        
        bv.alpha = 0
        UIView.animate(withDuration: 1.5) { 
            bv.alpha = 1.0
        }
        return bv
    }
    
    func updateAllRowSelectStatus() {
        var i = 0
        _ = watchDevList.map { [weak self] in
            guard let weakself = self else { return }
            let indexPath = IndexPath(row: i, section: 0)
            if $0.visible {
                weakself.tableview.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            } else {
                weakself.tableview.deselectRow(at: indexPath, animated: false)
            }
            i += 1
        }
    }
}
