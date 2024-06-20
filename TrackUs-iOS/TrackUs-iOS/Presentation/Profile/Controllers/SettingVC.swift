//
//  SettingVC.swift
//  TrackUs-iOS
//
//  Created by 박소희 on 5/19/24.
//

import UIKit
import Firebase
import FirebaseAuth
import WebKit


class SettingVC: UIViewController {
    
    let authService = AuthService.shared
    
    private func performLogout() {
        authService.logOut()
        
        let loginVC = LoginVC()
        navigationController?.setViewControllers([loginVC], animated: true)
    }
    
    private lazy var webView: WKWebView = {
        let webView = WKWebView()
        webView.navigationDelegate = self
        return webView
    }()

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.backgroundColor = .white
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        view.backgroundColor = .white
        setupTableView()

    }

    private func setupNavBar() {
        self.navigationItem.title = "설정"
        
    let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(backButtonTapped))
        backButton.tintColor = .black
        self.navigationItem.leftBarButtonItem = backButton
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    @objc private func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self

        tableView.separatorStyle = .none
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
}

extension SettingVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 3
        case 2:
            return 1
        case 3:
            //return 1
            return 2
        case 4:
            return 2
        default:
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if indexPath.section == 0 {
            let versionLabel = UILabel()
            versionLabel.text = "v.1.0.0"
            versionLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            versionLabel.textColor = UIColor(named: "Gray1") ?? .gray
            versionLabel.sizeToFit()
            cell.accessoryView = versionLabel
        } else if indexPath.section == 4 && (indexPath.row == 0 || indexPath.row == 1) {
            let emptyView = UIView()
            cell.accessoryView = emptyView
        } else {
            cell.accessoryType = .disclosureIndicator
        }
        
        let textColor: UIColor
        let font: UIFont
        if indexPath.section == 4 && indexPath.row == 1 {
            textColor = .red
        } else {
            textColor = UIColor(named: "Gray1") ?? .gray
        }
        font = UIFont.systemFont(ofSize: 16, weight: .regular)
        
        switch indexPath.section {
        case 0:
            cell.textLabel?.text = "버전 정보"
        case 1:
            cell.textLabel?.text = indexPath.row == 0 ? "오픈소스/라이센스" : (indexPath.row == 1 ? "위치정보 서비스 및 이용약관" : "개인정보 처리방침")
        case 2:
            cell.textLabel?.text = "문의하기"
        case 3:
            //cell.textLabel?.text = "차단된 계정"
            cell.textLabel?.text = indexPath.row == 0 ? "차단된 계정" : "모든 사용자"
        case 4:
            cell.textLabel?.text = indexPath.row == 0 ? "로그아웃" : "회원탈퇴"
        default:
            break
        }
        
        cell.textLabel?.textColor = textColor
        cell.textLabel?.font = font
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "앱 정보"
        case 1:
            return "서비스"
        case 2:
            return "고객지원"
        case 3:
            return "차단"
        case 4:
            return "계정관리"
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .white
        let headerLabel = UILabel(frame: CGRect(x: 15, y: 0, width: tableView.bounds.size.width - 30, height: 44))
        headerLabel.textColor = .black
        headerLabel.font = UIFont.boldSystemFont(ofSize: 16)
        headerLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
        headerView.addSubview(headerLabel)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section < tableView.numberOfSections - 1 {
            let separatorView = UIView(frame: CGRect(x: 15, y: 0, width: tableView.bounds.size.width - 30, height: 1))
            separatorView.backgroundColor = UIColor.systemGray4
            return separatorView
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section < tableView.numberOfSections - 1 {
            return 1
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 0:
            break
        case 1:
            if indexPath.row == 0 {
                showWebView(with: "https://lizard-basketball-e41.notion.site/OPEN-SOURCE-LICENSE-a57a3078e21c4821932d2189859b8bcb?pvs=4", title: "오픈소스/라이센스")
            } else if indexPath.row == 1 {
                showWebView(with: "https://colorful-force-5d2.notion.site/TrackUs-be971d4c799c4c12ab9e984aeafedc1d?pvs=4", title: "위치정보 서비스 및 이용약관")
            } else if indexPath.row == 2 {
                showWebView(with: "https://colorful-force-5d2.notion.site/a3c5eb465e464a4a85ec708f97e0201e?pvs=4", title: "개인정보 처리방침")
            }
        case 2:
            let withdrawalVC = UserListVC()
            navigationController?.pushViewController(withdrawalVC, animated: true)
        case 3:
            let withdrawalVC = UserListVC()
            navigationController?.pushViewController(withdrawalVC, animated: true)
        case 4:
            if indexPath.row == 0 {
                performLogout()
            } else {
                let withdrawalVC = WithdrawalVC()
                navigationController?.pushViewController(withdrawalVC, animated: true)
                withdrawalVC.hidesBottomBarWhenPushed = true
            }
        default:
            break
        }
    }
    private func showWebView(with url: String, title: String) {
        if let url = URL(string: url) {
            let request = URLRequest(url: url)
            webView.load(request)
            
            let webViewController = UIViewController()
            webViewController.view.addSubview(webView)
            webView.frame = webViewController.view.bounds
            webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            webViewController.navigationItem.title = title
            webViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(webViewBackButtonTapped))
            webViewController.navigationItem.leftBarButtonItem?.tintColor = .black
            
            navigationController?.pushViewController(webViewController, animated: true)
        }
    }
    
    @objc private func webViewBackButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}
extension SettingVC: WKNavigationDelegate {
}
