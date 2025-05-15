import UIKit
import DGCharts

class ChartViewController: UIViewController {

    @IBOutlet weak var generalPieChartView: PieChartView!
    @IBOutlet weak var incomePieChartView: PieChartView!
    @IBOutlet weak var expensePieChartView: PieChartView!

    var incomeTotal: Double = 0.0
    var expenseTotal: Double = 0.0
    var incomeCategoriesTotal: [String: Double] = [:]
    var expenseCategoriesTotal: [String: Double] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        updatePieCharts()
    }

    func updatePieCharts() {
        // Gelir ve gider toplamlarını ve kategorilerini hesapla
        var incomeEntries: [PieChartDataEntry] = []
        for (category, total) in incomeCategoriesTotal {
            incomeEntries.append(PieChartDataEntry(value: total, label: category))
        }
        let incomeDataSet = PieChartDataSet(entries: incomeEntries, label: "Gelir Dağılımı")
        incomeDataSet.colors = [UIColor.green, UIColor.blue, UIColor.cyan, UIColor.purple]
        incomePieChartView.data = PieChartData(dataSet: incomeDataSet)
        incomePieChartView.centerText = "Gelirler"

        var expenseEntries: [PieChartDataEntry] = []
        for (category, total) in expenseCategoriesTotal {
            expenseEntries.append(PieChartDataEntry(value: total, label: category))
        }
        let expenseDataSet = PieChartDataSet(entries: expenseEntries, label: "Gider Dağılımı")
        expenseDataSet.colors = [UIColor.red, UIColor.orange, UIColor.yellow, UIColor.brown, UIColor.darkGray]
        expensePieChartView.data = PieChartData(dataSet: expenseDataSet)
        expensePieChartView.centerText = "Giderler"

        // Gelir ve Gider toplamlarını gösteren genel grafik
        let entry1 = PieChartDataEntry(value: incomeTotal, label: "Gelir")
        let entry2 = PieChartDataEntry(value: expenseTotal, label: "Gider")
        let dataSet = PieChartDataSet(entries: [entry1, entry2], label: "Gelir-Gider Dağılımı")
        dataSet.colors = [UIColor.green, UIColor.red]
        generalPieChartView.data = PieChartData(dataSet: dataSet)
        generalPieChartView.centerText = "Gelir ve Gider"
    }
}
