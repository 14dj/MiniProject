import UIKit

class CategoryViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var categorytable: UITableView!
    @IBOutlet weak var picker: UIPickerView!

    let genres = ["","Action", "Adventure", "Drama", "Science Fiction", "Thriller", "Comedy", "Crime", "Animation", "History"] // 장르 데이터
    var selectedGenre: String = "" // 
    var movies: [[String: String]] = []
    var filteredMovies: [[String: String]] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        picker.dataSource = self
        picker.delegate = self

        categorytable.dataSource = self
        categorytable.delegate = self

        loadMovieData()
        updateTableData()
    }

    func loadMovieData() {
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

    func updateTableData() {
        if selectedGenre.isEmpty {
            filteredMovies = movies
        } else {
            filteredMovies = movies.filter { movie in
                if let genres = movie["genres"] {
                    return genres.contains(selectedGenre)
                }
                return false
            }
        }
        filteredMovies.sort { (movie1, movie2) -> Bool in
                if let voteAverage1 = Double(movie1["vote_average"] ?? ""),
                   let voteAverage2 = Double(movie2["vote_average"] ?? "") {
                    return voteAverage1 > voteAverage2
                }
                return false
            }
        categorytable.reloadData()
    }

    // MARK: - UIPickerViewDataSource

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1 // 피커뷰의 컴포넌트 수
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genres.count // 피커뷰의 행 수
    }

    // MARK: - UIPickerViewDelegate

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genres[row] // 피커뷰의 각 행에 표시될 데이터
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedGenre = genres[row] // 선택된 장르 업데이트
        updateTableData()
    }

}

extension CategoryViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredMovies.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)

        let movie = filteredMovies[indexPath.row]
        if let title = movie["original_title"] {
            cell.textLabel?.text = title
        }
        if let date = movie["release_date"] {
                cell.detailTextLabel?.text = " \(date)"
            }
            
            if let voteAverage = movie["vote_average"] {
                cell.detailTextLabel?.text?.append("  |  \(voteAverage)")
            }


        return cell
    }

}
