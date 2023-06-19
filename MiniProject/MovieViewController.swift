import UIKit

class MovieViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var btn: UIButton!
    @IBOutlet weak var movietable: UITableView!
    
    var movies: [[String: String]] = []
    var topMovies: [[String: String]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        movietable.dataSource = self
        movietable.delegate = self
        
        if let csvPath = Bundle.main.path(forResource: "movies_metadata2", ofType: "csv") {
            do {
                let csvContent = try String(contentsOfFile: csvPath, encoding: .utf8)
                movies = parseCSV(csvContent: csvContent)
                topMovies = getTopMovies(count: 20)
                movietable.reloadData()
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
                    
                    // belongs_to_collection
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
    
    func getTopMovies(count: Int) -> [[String: String]] {
        let sortedMovies = movies.sorted { movie1, movie2 in
            if let voteAverage1 = Double(movie1["vote_average"] ?? ""),
               let voteAverage2 = Double(movie2["vote_average"] ?? "") {
                return voteAverage1 > voteAverage2
            }
            return false
        }
        
        let topMovies = Array(sortedMovies.prefix(count))
        return topMovies
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topMovies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        
        let movie = topMovies[indexPath.row]
        let originalTitle = movie["original_title"] ?? ""
        let voteAverage = movie["vote_average"] ?? ""
        
        cell.textLabel?.text = originalTitle
        cell.detailTextLabel?.text = "평점: \(voteAverage)"
        
        return cell
    }

    // MARK: - IBActions
    
    @IBAction func btnTapped(_ sender: UIButton) {
        topMovies = getTopMovies(count: 20)
        movietable.reloadData()
    }
}

extension String {
    func csvValues() -> [String] {
        var values: [String] = []
        var currentValue = ""
        var isInsideQuotes = false
        
        for character in self {
            if character == "," && !isInsideQuotes {
                values.append(currentValue)
                currentValue = ""
            } else if character == "\"" {
                isInsideQuotes.toggle()
            } else {
                currentValue.append(character)
            }
        }
        
        values.append(currentValue)
        
        return values
    }
}
