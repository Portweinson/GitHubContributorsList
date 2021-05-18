//
//  ContributorsListVC.swift
//  GitHubContributorsList
//
//  Created by Viacheslav Embaturov on 18.05.2021.
//

import UIKit


class ContributorsListVC: UITableViewController {
    
    
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
    
    
    //MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let url = URL(string: "https://api.github.com/repos/videolan/vlc/contributors") else {
            return
        }
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode([Contributor].self, from: data) {
                    DispatchQueue.main.async {
                        self.contributors = decodedResponse
                        self.tableView.reloadData()
                    }
                    return
                }
            }
            print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
            
        }.resume()
    }
    
    deinit {
        ImageFetchingService.shared.cancelDownloads()
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
