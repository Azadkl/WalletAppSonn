import UIKit
import DGCharts

class DetailChartViewController: UIViewController {

    @IBOutlet weak var incomeChartView: PieChartView!
    @IBOutlet weak var expenseChartView: PieChartView!
    @IBOutlet weak var totalChartView: PieChartView!

    var transactions: [Transaction] = []

    // Renk sözlükleri
    let incomeCategoryColors: [String: UIColor] = [
        "Maaş": .systemGreen,
        "Prim": .systemBlue,
        "Hediye": .systemTeal,
        "Yatırım": .systemIndigo,
        "Diğer": .gray
    ]

    let expenseCategoryColors: [String: UIColor] = [
        "Market": .systemRed,
        "Kira": .systemOrange,
        "Eğlence": .systemYellow,
        "Ulaşım": .systemPink,
        "Fatura": .brown,
        "Diğer": .purple
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Gelir & Gider Detayları"
        setupIncomeChart()
        setupExpenseChart()
        setupTotalChart()
    }

    func setupIncomeChart() {
        let incomeTransactions = transactions.filter { $0.type == "Gelir" }
        var categoryTotals: [String: Double] = [:]

        for t in incomeTransactions {
            categoryTotals[t.category, default: 0.0] += t.amount
        }

        let total = categoryTotals.values.reduce(0, +)
        guard total > 0 else {
            incomeChartView.noDataText = "Gelir verisi yok."
            return
        }

        let entries = categoryTotals.map {
            PieChartDataEntry(
                value: $0.value,
                label: "\($0.key) %\(String(format: "%.1f", $0.value / total * 100))" // Tek satırda gösteriliyor
            )
        }

        let dataSet = PieChartDataSet(entries: entries, label: "Gelir Dağılımı")
        dataSet.colors = entries.map {
            let categoryName = $0.label?.components(separatedBy: " ").first ?? "" // Kategori adı alınıyor
            return incomeCategoryColors[categoryName] ?? .lightGray
        }

        dataSet.drawValuesEnabled = false
        dataSet.entryLabelColor = .black
        dataSet.valueTextColor = .black
        dataSet.valueFont = .systemFont(ofSize: 10) // Font boyutu küçültüldü

        incomeChartView.data = PieChartData(dataSet: dataSet)
        incomeChartView.centerText = "Gelir"
        incomeChartView.animate(xAxisDuration: 1.0, easingOption: .easeOutBack)
    }

    func setupExpenseChart() {
        let expenseTransactions = transactions.filter { $0.type == "Gider" }
        var categoryTotals: [String: Double] = [:]

        for t in expenseTransactions {
            categoryTotals[t.category, default: 0.0] += t.amount
        }

        let total = categoryTotals.values.reduce(0, +)
        guard total > 0 else {
            expenseChartView.noDataText = "Gider verisi yok."
            return
        }

        let entries = categoryTotals.map {
            PieChartDataEntry(
                value: $0.value,
                label: "\($0.key) %\(String(format: "%.1f", $0.value / total * 100))" // Tek satırda gösteriliyor
            )
        }

        let dataSet = PieChartDataSet(entries: entries, label: "Gider Dağılımı")
        dataSet.colors = entries.map {
            let categoryName = $0.label?.components(separatedBy: " ").first ?? "" // Kategori adı alınıyor
            return expenseCategoryColors[categoryName] ?? .lightGray
        }

        dataSet.drawValuesEnabled = false
        dataSet.entryLabelColor = .black
        dataSet.valueTextColor = .black
        dataSet.valueFont = .systemFont(ofSize: 10) // Font boyutu küçültüldü

        expenseChartView.data = PieChartData(dataSet: dataSet)
        expenseChartView.centerText = "Gider"
        expenseChartView.animate(xAxisDuration: 1.0, easingOption: .easeOutBack)
    }


    func setupTotalChart() {
        let incomeTotal = transactions.filter { $0.type == "Gelir" }.reduce(0.0) { $0 + $1.amount }
        let expenseTotal = transactions.filter { $0.type == "Gider" }.reduce(0.0) { $0 + $1.amount }

        guard incomeTotal > 0 || expenseTotal > 0 else {
            totalChartView.noDataText = "Toplam veri yok."
            return
        }

        let total = incomeTotal + expenseTotal

        let entries = [
            PieChartDataEntry(value: incomeTotal, label: "Gelir %\(String(format: "%.1f", incomeTotal / total * 100))"),
            PieChartDataEntry(value: expenseTotal, label: "Gider %\(String(format: "%.1f", expenseTotal / total * 100))")
        ]

        let dataSet = PieChartDataSet(entries: entries, label: "Genel Dağılım")
        dataSet.drawValuesEnabled = false
        dataSet.colors = [UIColor.systemGreen, UIColor.systemRed]
        dataSet.entryLabelColor = .black
        dataSet.valueTextColor = .black
        dataSet.valueFont = .systemFont(ofSize: 12)

        totalChartView.data = PieChartData(dataSet: dataSet)
        totalChartView.centerText = "Toplam"
        totalChartView.animate(xAxisDuration: 1.0, easingOption: .easeOutBack)
    }
}
