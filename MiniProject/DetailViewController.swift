//
//  DetailViewController.swift
//  MiniProject
//
//  Created by DongJu Lee on 2023/06/18.
//

import UIKit

class DetailViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var series: UITableView!
    
    let titles = ["분노의 질주: 더 얼티메이트", "분노의 질주: 홉스&쇼","분노의 질주: 더 익스트림","분노의 질주: 더 세븐","분노의 질주: 더 맥시멈","분노의 질주: 언리미티드","분노의 질주: 더 오리지널"]
       let subtitles = ["2021-05-19", "2019-08-14","2017-04-12","2015-04-01","2013-05-22","2011-04-20","2009-04-02"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        series.dataSource = self
        // Do any additional setup after loading the view.
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return titles.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "seriescell", for: indexPath)
            
            
            cell.textLabel?.text = titles[indexPath.row]
            cell.detailTextLabel?.text = subtitles[indexPath.row]
            
            return cell
        }

}
