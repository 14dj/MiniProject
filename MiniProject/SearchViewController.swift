import UIKit

class SearchViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchTable: UITableView!
    
    var movies: [[String: String]] = []
    var filteredMovies: [[String: String]] = []
    
    static let storyboardName = "Main" // 스토리보드 이름
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        searchTable.dataSource = self
        searchTable.delegate = self
        
        searchTable.rowHeight = 80 
        
        if let csvPath = Bundle.main.path(forResource: "movies_metadata2", ofType: "csv") {
            do {
                let csvContent = try String(contentsOfFile: csvPath, encoding: .utf8)
                movies = parseCSV(csvContent: csvContent)
            } catch {
                print("CSV 파일 읽기 오류:", error.localizedDescription)
            }
        }
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
                    
                    row[columnName] = value
                }
                rows.append(row)
            }
        }
        
        return rows
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        if let searchText = searchBar.text {
            filteredMovies = movies.filter { movie in
                if let title = movie["original_title"] {
                    return title.lowercased().contains(searchText.lowercased())
                }
                return false
            }
            searchTable.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredMovies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath)
        
        let movie = filteredMovies[indexPath.row]
        
        if let title = movie["original_title"] {
            cell.textLabel?.text = title
        }
        
        let imageName = "poster_sample.jpg"
        if let image = UIImage(named: imageName) {
            cell.imageView?.image = image
        }
        
        if let overview = movie["overview"] {
            let maxTextLength = 200 // 최대 글자 제한
            var abbreviatedOverview = overview
            if overview.count > maxTextLength {
                let index = overview.index(overview.startIndex, offsetBy: maxTextLength)
                abbreviatedOverview = String(overview[..<index]) + "..."
            }
            
            cell.detailTextLabel?.numberOfLines = 0
            cell.detailTextLabel?.text = abbreviatedOverview
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let movie = filteredMovies[indexPath.row]
        
        if let movieDetailVC = UIStoryboard(name: SearchViewController.storyboardName, bundle: nil).instantiateViewController(withIdentifier: "MovieDetailViewController") as? MovieDetailViewController {
            movieDetailVC.movie = movie
            present(movieDetailVC, animated: true, completion: nil)
        }
    }




}
