//
//  MovieDetailViewController.swift
//  MiniProject
//
//  Created by DongJu Lee on 2023/06/18.
//

import UIKit

class MovieDetailViewController: UIViewController {
    
    @IBOutlet var moviewtagline: UILabel!
    @IBOutlet var movieoverview: UITextView!
    @IBOutlet var movieruntime: UILabel!
    @IBOutlet var moviegenres: UILabel!
    @IBOutlet var moviedate: UILabel!
    @IBOutlet var movietitle: UILabel!
    
    
    @IBOutlet var reviewview: UITextView!
    @IBOutlet var reviewbtn: UIButton!
    @IBOutlet var reviewtext: UITextField!
    
    
    var movie: [String: String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        
        reviewbtn.addTarget(self, action: #selector(reviewButtonTapped), for: .touchUpInside)
    }
    
    func configureUI() {
            guard let movie = movie else {
                return
            }
            
        movietitle.text = movie["original_title"]
        moviedate.text = movie["release_date"]
        moviegenres.text = movie["genres"]
//        movieruntime.text = movie["runtime"]
        movieruntime.text = "런타임: \(movie["runtime"] ?? "")"
        movieoverview.text = movie["overview"]
        moviewtagline.text = movie["tagline"]
        }
    
    @objc func reviewButtonTapped() {
        if let reviewText = reviewtext.text, !reviewText.isEmpty {
            if let existingText = reviewview.text {
                reviewview.text = existingText + "\n" + reviewText
            } else {
                reviewview.text = reviewText
            }
            
            reviewtext.text = ""
        }
    }

}
