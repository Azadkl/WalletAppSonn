import UIKit

struct Transaction: Codable {
    var type: String // "Gelir" veya "Gider"
    var category: String
    var amount: Double
    var date: Date // Tarih
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var transactionTableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!

    var balance: Double = 0.0
    var transactions: [Transaction] = []
    var filteredTransactions: [Transaction] = [] 

    let incomeCategories = ["Maaş", "Prim", "Hediye", "Diğer"]
    let expenseCategories = ["Market", "Kira", "Eğlence", "Ulaşım", "Diğer"]

    var selectedCategory: String?
    var isIncome: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()

       
        let creditCardImageView = UIImageView(image: UIImage(named: "creditCardImage"))
        creditCardImageView.contentMode = .scaleAspectFill
        creditCardImageView.frame = CGRect(x: 0, y: 100, width: self.view.frame.width, height: 80)
        self.view.addSubview(creditCardImageView)
        self.view.sendSubviewToBack(creditCardImageView)

        transactionTableView.delegate = self
        transactionTableView.dataSource = self

       
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)

        loadTransactionsFromFile()
        updateBalance()
        updateBalanceLabel()

       
        filterTransactions()
    }

    @objc func segmentChanged() {
        filterTransactions()
    }

    func filterTransactions() {
        switch segmentedControl.selectedSegmentIndex {
        case 0: 
            filteredTransactions = transactions
        case 1:
            filteredTransactions = transactions.filter { $0.type == "Gelir" }
        case 2: 
            filteredTransactions = transactions.filter { $0.type == "Gider" }
        default:
            filteredTransactions = transactions
        }
        transactionTableView.reloadData()
    }

    func getTransactionsFileURL() -> URL {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentDirectory.appendingPathComponent("transaction.json")
    }

    @IBAction func showDetailsTapped(_ sender: Any) {
        performSegue(withIdentifier: "showDetailChart", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailChart",
           let destination = segue.destination as? DetailChartViewController {
            destination.transactions = self.transactions
        }
    }

    @IBAction func clearAllDataTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Tüm Veriler Silinsin mi?",
                                      message: "Bu işlem geri alınamaz. Emin misiniz?",
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Evet", style: .destructive) { _ in
            self.transactions.removeAll()
            self.saveTransactionsToFile()
            self.updateBalance()
            self.updateBalanceLabel()
            self.filterTransactions() 
        })

        alert.addAction(UIAlertAction(title: "İptal", style: .cancel))
        present(alert, animated: true)
    }

    func saveTransactionsToFile() {
        do {
            let data = try JSONEncoder().encode(transactions)
            try data.write(to: getTransactionsFileURL())
        } catch {
            print("Veri kaydedilemedi: \(error)")
        }
    }

    func loadTransactionsFromFile() {
        do {
            let data = try Data(contentsOf: getTransactionsFileURL())
            transactions = try JSONDecoder().decode([Transaction].self, from: data)
        } catch {
            print("Veri yüklenemedi: \(error)")
        }
    }

    func updateBalance() {
        balance = transactions.reduce(0.0) { $0 + ($1.type == "Gelir" ? $1.amount : -$1.amount) }
    }

    func updateBalanceLabel() {
        balanceLabel.text = String(format: "%.2f₺", balance)
        balanceLabel.textAlignment = .center
        balanceLabel.font = UIFont.boldSystemFont(ofSize: 24)
        balanceLabel.textColor = UIColor.black
        balanceLabel.frame = CGRect(x: 0, y: 100, width: self.view.frame.width, height: 60)
    }

    @IBAction func addIncomeTapped(_ sender: UIButton) {
        isIncome = true
        showCategorySelectionAlert(for: incomeCategories)
    }

    @IBAction func addExpenseTapped(_ sender: UIButton) {
        isIncome = false
        showCategorySelectionAlert(for: expenseCategories)
    }

    func showCategorySelectionAlert(for categories: [String]) {
        let alert = UIAlertController(title: "Kategori Seçin", message: nil, preferredStyle: .actionSheet)
        for category in categories {
            alert.addAction(UIAlertAction(title: category, style: .default) { _ in
                self.selectedCategory = category
                self.confirmTransaction()
            })
        }
        alert.addAction(UIAlertAction(title: "İptal", style: .cancel))
        present(alert, animated: true)
    }

    func confirmTransaction() {
        guard let amountText = amountTextField.text,
              let amount = Double(amountText),
              let category = selectedCategory else {
            showAlert(message: "Lütfen geçerli bir tutar ve kategori seçin.")
            return
        }

        let type = isIncome ? "Gelir" : "Gider"
        let newTransaction = Transaction(type: type, category: category, amount: amount, date: Date())
        transactions.insert(newTransaction, at: 0)

        updateBalance()
        updateBalanceLabel()
        filterTransactions() 
        amountTextField.text = ""
        saveTransactionsToFile()
    }

    func showAlert(message: String) {
        let alert = UIAlertController(title: "Hata", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }

    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredTransactions.count
    }


    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Sil") { (action, view, completionHandler) in
        
            let transactionToDelete = self.filteredTransactions[indexPath.row]
            
         
            if let originalIndex = self.transactions.firstIndex(where: {
                $0.date == transactionToDelete.date &&
                $0.amount == transactionToDelete.amount &&
                $0.category == transactionToDelete.category &&
                $0.type == transactionToDelete.type
            }) {
                self.transactions.remove(at: originalIndex)
            }
            
      
            self.filteredTransactions.remove(at: indexPath.row)
            
        
            self.updateBalance()
            self.updateBalanceLabel()
            self.saveTransactionsToFile()
            
          
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
      
            completionHandler(true)
        }
        
       
        deleteAction.backgroundColor = .systemRed  
        
       
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteAction])
        return swipeActions
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let transaction = filteredTransactions[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        let dateString = formatter.string(from: transaction.date)

        cell.textLabel?.text = "\(transaction.type): \(transaction.category)"
        cell.detailTextLabel?.text = "\(String(format: "%.2f₺", transaction.amount)) • \(dateString)"
        cell.textLabel?.textColor = transaction.type == "Gelir" ? .systemGreen : .systemRed
        cell.backgroundColor = UIColor.systemGray4
        return cell
    }
}
