//
//  ContributorsListVC.swift
//  GitHubContributorsList
//
//  Created by Viacheslav Embaturov on 18.05.2021.
//

import UIKit


class ContributorsListVC: UITableViewController, ShowAlertProtocol {
    
    
    //MARK: -
    
    enum CellIdetifiers: String {
        case contributor = "ContributorCell"
    }
    
    enum Segue: String {
        case toDetail = "Contrib list to contrib details"
    }
    
    
    //MARK: - class variables
    
    private var contributors = [Contributor]()
    private let avatarPlaceholder = UIImage(named: "icon-avatar-placeholder-80x80")
    private var selectedContributor: SelectedContributor?
    private let networkClient = ContributorsNetworkClient()
    private var isDataFetchInProgress = false
    
    var selectedCell: ContributorInfoCell?
    
    
    //MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.delegate = self
        self.refreshControl?.addTarget(self, action: #selector(loadData), for: .valueChanged)
        self.loadData()
    }
    
    deinit {
        ImageFetchingService.shared.cancelDownloads()
    }
    
    
    //MARK: - Data loading
    
    @objc func loadData() {
        
        guard isDataFetchInProgress == false else {return}
        
        isDataFetchInProgress = true
        self.refreshControl?.beginRefreshing()
        
        networkClient.allContributors { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self?.contributors = data
                case .failure(let error):
                    self?.handleError(error)
                }
                
                self?.isDataFetchInProgress = false
                self?.tableView.reloadData()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self?.refreshControl?.endRefreshing()
                }
            }
        }
    }
    
    func handleError(_ error: ResponseError) {
        let title = "Something went wrong"
        let message = "Please try again later"
        let action = UIAlertAction(title: "Dismiss", style: .cancel)
        
        showAlert(with: title, message: message, actions: [action])
    }
    
    
    //MARK: - UITableViewDelegate, UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contributors.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = contributors[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdetifiers.contributor.rawValue) as! ContributorInfoCell
        
        cell.labelLogin.text = data.login
        cell.labelId.text = String(data.id)
        
        if let url = data.avatarUrl {
            ImageFetchingService.shared.fetchImage(with: url) { [weak cell, weak self] image in
                cell?.imgViewAvatar.image = image ?? self?.avatarPlaceholder
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let data = contributors[indexPath.row]
        
        if let url = data.avatarUrl, let cCell = cell as? ContributorInfoCell {
            cCell.imgViewAvatar.image = avatarPlaceholder
            ImageFetchingService.shared.cancelDownloadIfNeeded(for: url)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) as? ContributorInfoCell {
            
            let data = contributors[indexPath.row]
            
            self.selectedContributor = SelectedContributor(info: data,
                                                           image: cell.imgViewAvatar.image)
            self.selectedCell = cell
            self.performSegue(withIdentifier: Segue.toDetail.rawValue, sender: nil)
        }
    }
    
    
    //MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == Segue.toDetail.rawValue, let data = selectedContributor {
            let vc = segue.destination as! ContributorDetailVC
            vc.data = data
        }
        super.prepare(for: segue, sender: sender)
    }
}



//MARK: - UINavigationControllerDelegate

extension ContributorsListVC: UINavigationControllerDelegate {

    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .push:
            if let to = toVC as? ContributorDetailVC {
                return PushAnimator(duration: 0.35, from: self, to: to)
            } else {
                return nil
            }
        case .pop:
            if let from = fromVC as? ContributorDetailVC {
                return PopAnimator(duration: 0.35, from: from, to: self)
            } else {
                return nil
            }
        default:
            return nil
        }
    }
}
