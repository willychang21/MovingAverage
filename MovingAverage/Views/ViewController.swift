import UIKit
import Charts
import JGProgressHUD

class ViewController: UIViewController {
    
    // UI
    @IBOutlet var chartView: LineChartView!
    var legend = Legend()
    let hud = JGProgressHUD()

    // Data
    var 本益比基準 = [Double]()
    var 本淨比基準 = [Double]()
    var 基準選擇: String = "本益比"
    var 時間選擇: Int = 1
    var MAModels = [MovingAverageViewModel]()
    var 股票資料 = [MovingAverageViewModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        hud.textLabel.text = "Loading"
        hud.show(in: self.view)
        fetchStockData()
        legend = chartView.legend
        configureChartView()
    }
    
    func configureChartView() {
        chartView.delegate = self
        chartView.backgroundColor = .black
        chartView.pinchZoomEnabled = false
        chartView.setScaleEnabled(false)
        chartView.drawBordersEnabled = true
        chartView.borderColor = .white
        
        let xAxis = chartView.xAxis
        xAxis.valueFormatter = self
        xAxis.labelPosition = .bottom
        xAxis.labelTextColor = .white
        xAxis.avoidFirstLastClippingEnabled = true
        
        let leftAxis = chartView.leftAxis
        leftAxis.drawLabelsEnabled = false
        
        let rightAxis = chartView.rightAxis
        rightAxis.labelTextColor = .white
        rightAxis.drawBottomYLabelEntryEnabled = true
    }
    
    func configureLegend() {
        
        legend.enabled = true
        legend.textColor = .white
        legend.verticalAlignment = .top
        legend.horizontalAlignment = .left
        legend.direction = .leftToRight
        legend.orientation = .horizontal
        legend.xEntrySpace = 50
        legend.drawInside = false
        
        let colors = [
            MAConstants.redColor,
            MAConstants.sixTimesColor,
            MAConstants.fiveTimesColor,
            MAConstants.fourTimesColor,
            MAConstants.threeTimesColor,
            MAConstants.twoTimesColor,
            MAConstants.oneTimesColor
        ]
        
        guard let 時間 = legend.entries.last else {
            return
        }
        legend.entries.insert(時間, at: 0)
        legend.entries.removeLast()
        
        guard let 現價 = legend.entries.last else {
            return
        }
        legend.entries.insert(現價, at: 1)
        legend.entries.removeLast()
        
        for i in 0...本益比基準.count+1 {
            if i == 0 {
                legend.entries[i].form = .none
            }
            else {
                legend.entries[i].formColor = colors[i-1]
            }
        }
        
        let index = 股票資料.count-1
        let n = 本益比基準.count
        for i in 0...(n+1) {
            if i == 0 { // Year
                legend.entries[i].label = "\(股票資料[index].年月)"
            }
            else if i == 1 { // 現價
                legend.entries[i].label = String(format: "股價 %.2f", 股票資料[index].月平均收盤價)
            }
            else { // 本益比&本淨比股價
                if 基準選擇 == "本益比" && (index != 0) && (index != 1) {
                    legend.entries[i].label = String(format: "\(本益比基準[n-i+1])倍 \(股票資料[index].本益比股價基準[n-i+1])")
                }
                else if 基準選擇 == "本淨比" && (index != 0) && (index != 1){
                    legend.entries[i].label = String(format: "\(本淨比基準[n-i+1])倍 \(股票資料[index].本淨比股價基準[n-i+1])")
                }
            }
        }
        
        hud.dismiss()
        
    }
    
    @IBAction func 本益比本淨比切換(_ sender: UISegmentedControl) {
        let targetIndex = sender.selectedSegmentIndex
        switch targetIndex {
        case 0:
            基準選擇 = "本益比"
            setupDataForChartView(models: 股票資料)
        case 1:
            基準選擇 = "本淨比"
            setupDataForChartView(models: 股票資料)
        default:
            基準選擇 = "本益比"
            setupDataForChartView(models: 股票資料)
        }
    }
    
    @IBAction func 時間切換(_ sender: UISegmentedControl) {
        let targetIndex = sender.selectedSegmentIndex
        switch targetIndex {
        case 0:
            時間選擇 = 1
            選擇時間長度(年: 時間選擇)
            hud.textLabel.text = "Loading"
            hud.show(in: self.view)
            setupDataForChartView(models: 股票資料)
        case 1:
            時間選擇 = 3
            選擇時間長度(年: 時間選擇)
            hud.textLabel.text = "Loading"
            hud.show(in: self.view)
            setupDataForChartView(models: 股票資料)
        case 2:
            時間選擇 = 5
            選擇時間長度(年: 時間選擇)
            hud.textLabel.text = "Loading"
            hud.show(in: self.view)
            setupDataForChartView(models: 股票資料)
        default:
            時間選擇 = 1
            選擇時間長度(年: 時間選擇)
            setupDataForChartView(models: 股票資料)
        }
    }
    
    func fetchStockData() {
        APICaller.shared.getStockData { [weak self] result in
            
            guard let strongSelf = self else {
                return
            }
            
            switch result {
            case .success(let 股票):
                self?.本益比基準 = 股票.data[股票.data.count-1].本益比基準.map({ return Double($0) ?? 0 })
                self?.本淨比基準 = 股票.data[股票.data.count-1].本淨比基準.map({ return Double($0) ?? 0 })
                self?.MAModels = 股票.data[股票.data.count-1].河流圖資料.compactMap({ 河流圖資料 -> MovingAverageViewModel in
                    return MovingAverageViewModel(年月: 河流圖資料.年月.yearMonth,
                                                  月平均收盤價: Double(河流圖資料.月平均收盤價) ?? 0,
                                                  本益比股價基準: 河流圖資料.本益比股價基準,
                                                  本淨比股價基準: 河流圖資料.本淨比股價基準)
                })
                DispatchQueue.main.sync { // 第一次預設 1 年
                    self?.選擇時間長度(年: 1)
                    self?.setupDataForChartView(models: strongSelf.股票資料)
                    self?.hud.dismiss()
                }
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
    func 選擇時間長度(年 year: Int) {
        let n = year * 12
        股票資料 = MAModels[0..<n].reversed()
    }
    
}

extension ViewController: ChartViewDelegate {
    
    func setupDataForChartView(models: [MovingAverageViewModel]) {
                
        let colors = [
            MAConstants.redColor,
            MAConstants.black,
            MAConstants.twoTimesColor,
            MAConstants.threeTimesColor,
            MAConstants.fourTimesColor,
            MAConstants.fiveTimesColor,
            MAConstants.sixTimesColor
        ]

        var dataSets = (0...本益比基準.count).map { i -> LineChartDataSet in
     
            let yVals = (0..<models.count).map { j -> ChartDataEntry in
                
                var val:Double = 0.0
                
                if i == 0 {
                    val = models[j].月平均收盤價
                }
                else {
                    if 基準選擇 == "本益比" {
                        val = Double(models[j].本益比股價基準[i-1]) ?? 0
                    }
                    else {
                        val = Double(models[j].本淨比股價基準[i-1]) ?? 0
                    }
                }
                return ChartDataEntry(x: Double(j),
                                      y: val)
            }
            
            let set = LineChartDataSet(entries: yVals)
            let color = colors[i]
            set.drawCirclesEnabled = false
            set.drawValuesEnabled = false
            set.drawHorizontalHighlightIndicatorEnabled = false
            
            if i == 0 {   // 現價, 最後畫上
                set.lineWidth = 2
                set.setColor(color)
            }
            else if i == 1 { // 倒數第二個畫上: 14.77
                let lineColor = MAConstants.oneTimesColor
                set.lineWidth = 2.5
                set.setColor(lineColor)
                set.drawFilledEnabled = true
                set.fillAlpha = 1
                set.fillColor = color
                set.fillFormatter = DefaultFillFormatter(block: { dataSet, dataProvider in
                    return CGFloat(self.chartView.leftAxis.axisMinimum)
                })
            }
            else {  // 18.18~31.83
                set.drawFilledEnabled = true
                set.fillAlpha = 1
                set.fillColor = color
                set.fillFormatter = DefaultFillFormatter(block: { dataSet, dataProvider in
                    return CGFloat(self.chartView.leftAxis.axisMinimum)
                })
            }
            
            return set
        }
        
        dataSets.reverse()
                
        let data = LineChartData(dataSets: dataSets)
        data.setValueFont(.systemFont(ofSize: 7,
                                      weight: .light))
        
        legend.extraEntries = [LegendEntry(label: "\(股票資料[股票資料.count-1].年月)")]
        
        chartView.data = data
        
        configureLegend()
    }
}

extension ViewController: AxisValueFormatter {

    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return 股票資料[min(max(Int(value), 0), 股票資料.count - 1)].年月
    }

    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        let index = Int(entry.x)
        let n = 本益比基準.count
        for i in 0...(n+1) {
            if i == 0 { // Year
                legend.entries[i].label = "\(股票資料[index].年月)"
            }
            else if i == 1 { // 現價
                legend.entries[i].label = String(format: "股價 %.2f", 股票資料[index].月平均收盤價)
            }
            else { // 本益比&本淨比股價
                if 基準選擇 == "本益比" && (index != 0) && (index != 1) {
                    legend.entries[i].label = String(format: "\(本益比基準[n-i+1])倍 \(股票資料[index].本益比股價基準[n-i+1])")
                }
                else if 基準選擇 == "本淨比" && (index != 0) && (index != 1){
                    legend.entries[i].label = String(format: "\(本淨比基準[n-i+1])倍 \(股票資料[index].本淨比股價基準[n-i+1])")
                }
            }
        }
    }
}


