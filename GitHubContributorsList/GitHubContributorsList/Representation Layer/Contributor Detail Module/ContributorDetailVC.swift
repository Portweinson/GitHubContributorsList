//
//  ContributorDetailVC.swift
//  GitHubContributorsList
//
//  Created by Viacheslav Embaturov on 18.05.2021.
//

import UIKit


struct SelectedContributor {
    let info: Contributor
    let image: UIImage?
}


class ContributorDetailVC: UIViewController {
    
    
    //MARK: - Outlets
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var labelLogin: UILabel!
    
    
    //MARK: - Class Variables
    
    var data: SelectedContributor?
    
    
    //MARK: - View Lifecycle
    
    override func viewDidLoad() {
        self.imageView.image = data?.image
        self.labelLogin.text = data?.info.login
    }
}
