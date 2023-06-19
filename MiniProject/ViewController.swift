import UIKit

class ViewController: UIViewController, UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var img1: UIImageView!
    @IBOutlet weak var top: UITableView!
    
    var movies: [[String: String]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapImg1))
        img1.addGestureRecognizer(tapGesture)
        img1.isUserInteractionEnabled = true
        
        let imageNames = ["mario.jpeg", "dream.jpeg", "john.jpeg"]
        
        let containerView = UIView()
        var xOffset: CGFloat = 0
        
        for imageName in imageNames {
            let imageView = UIImageView(image: UIImage(named: imageName))
            
            imageView.frame = CGRect(x: xOffset, y: 0, width: scrollView.frame.width, height: scrollView.frame.height)
            containerView.addSubview(imageView)
            
            xOffset += scrollView.frame.width
        }
        
        containerView.frame = CGRect(x: 0, y: 0, width: xOffset, height: scrollView.frame.height)
        scrollView.contentSize = containerView.frame.size
        scrollView.addSubview(containerView)
        scrollView.isPagingEnabled = true
        scrollView.delegate = self
        
        pageControl.numberOfPages = imageNames.count
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = UIColor.gray
        pageControl.pageIndicatorTintColor = UIColor.white
        
        top.dataSource = self
        top.delegate = self
        top.register(MovieCell.self, forCellReuseIdentifier: "topCell")
        
        if let csvPath = Bundle.main.path(forResource: "movies_metadata2", ofType: "csv") {
            do {
                let csvContent = try String(contentsOfFile: csvPath, encoding: .utf8)
                movies = parseCSV(csvContent: csvContent)
                top.reloadData()
            } catch {
                print("CSV 파일 읽기 오류:", error.localizedDescription)
            }
        }
    }
    
    @objc func didTapImg1() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detailViewController = storyboard.instantiateViewController(withIdentifier: "Detail") as! DetailViewController
        
        if let navigationController = navigationController {
            navigationController.pushViewController(detailViewController, animated: true)
        } else {
            present(detailViewController, animated: true, completion: nil)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x / scrollView.frame.width)
        pageControl.currentPage = Int(pageIndex)
    }
    
    func parseCSV(csvContent: String) -> [[String: String]] {
        var rows: [[String: String]] = []
        
        let lines = csvContent.components(separatedBy: "\n")
        if lines.count > 1 {
            let header = lines[0].csvValues()
            for i in 1..<lines.count {
                let values = lines[i].csvValues()
                var row: [String: String] = [:]
                for j in 0..<min(header.count, values.count) {
                    let columnName = header[j]
                    let value = values[j]
                    
                    if columnName == "belongs_to_collection" && !value.isEmpty {
                        if let collectionData = value.data(using: .utf8) {
                            do {
                                if let collectionDict = try JSONSerialization.jsonObject(with: collectionData, options: []) as? [String: Any] {
                                    if let name = collectionDict["name"] as? String {
                                        row[columnName] = name
                                    }
                                }
                            } catch {
                                print("JSON 파싱 오류:", error.localizedDescription)
                            }
                        }
                    } else {
                        row[columnName] = value
                    }
                }
                rows.append(row)
            }
        }
        
        return rows
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count // 전체 영화 개수로 설정
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "topCell", for: indexPath)
        
        let movie = movies[indexPath.row]
        let originalTitle = movie["original_title"] ?? ""
        let voteAverage = movie["vote_average"] ?? ""
        
        cell.textLabel?.text = originalTitle
        cell.detailTextLabel?.text = "평점: \(voteAverage)"
        
        return cell
    }
}
