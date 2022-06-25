import UIKit
import Charts
import JGProgressHUD

class ViewController: UIViewController {
    
    @IBOutlet var chartView: LineChartView!
    
    var 本益比基準 = [Double]()
    var 本淨比基準 = [Double]()
    var 顯示資料筆數 = 12 // 一年
    var MAModels = [MovingAverageViewModel]()
    var legend = Legend()
    var yearMonth: String = ""
    var 基準選擇: String = "本益比"
    let hud = JGProgressHUD()

    override func viewDidLoad() {
        super.viewDidLoad()
        hud.textLabel.text = "Loading"
        hud.show(in: self.view)
        configureChartView()
        legend = chartView.legend
        fetchStockData()
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
        
        legend.entries[0].formColor = MAConstants.sixTimesColor
        legend.entries[1].formColor = MAConstants.fiveTimesColor
        legend.entries[2].formColor = MAConstants.fourTimesColor
        legend.entries[3].formColor = MAConstants.threeTimesColor
        legend.entries[4].formColor = MAConstants.twoTimesColor
        legend.entries[5].formColor = MAConstants.oneTimesColor
        legend.entries[6].formColor = MAConstants.redColor
        legend.entries[7].form = .none
        legend.entries = [
            legend.entries[7], legend.entries[6],
            legend.entries[0], legend.entries[1], legend.entries[2],
            legend.entries[3], legend.entries[4], legend.entries[5]
        ]
        
        let index = MAModels.count-1
        legend.entries[0].label = "\(MAModels[index].年月)"
        legend.entries[1].label = String(format: "股價 %.2f", MAModels[index].月平均收盤價)
        if 基準選擇 == "本益比" {
            legend.entries[2].label = String(format: "\(本益比基準[5])倍 %.2f", MAModels[index].近四季EPS * 本益比基準[5])
            legend.entries[3].label = String(format: "\(本益比基準[4])倍 %.2f", MAModels[index].近四季EPS * 本益比基準[4])
            legend.entries[4].label = String(format: "\(本益比基準[3])倍 %.2f", MAModels[index].近四季EPS * 本益比基準[3])
            legend.entries[5].label = String(format: "\(本益比基準[2])倍 %.2f", MAModels[index].近四季EPS * 本益比基準[2])
            legend.entries[6].label = String(format: "\(本益比基準[1])倍 %.2f", MAModels[index].近四季EPS * 本益比基準[1])
            legend.entries[7].label = String(format: "\(本益比基準[0])倍 %.2f", MAModels[index].近四季EPS * 本益比基準[0])
        }
        else {
            legend.entries[2].label = String(format: "\(本淨比基準[5])倍 %.2f", MAModels[index].近一季BPS * 本淨比基準[5])
            legend.entries[3].label = String(format: "\(本淨比基準[4])倍 %.2f", MAModels[index].近一季BPS * 本淨比基準[4])
            legend.entries[4].label = String(format: "\(本淨比基準[3])倍 %.2f", MAModels[index].近一季BPS * 本淨比基準[3])
            legend.entries[5].label = String(format: "\(本淨比基準[2])倍 %.2f", MAModels[index].近一季BPS * 本淨比基準[2])
            legend.entries[6].label = String(format: "\(本淨比基準[1])倍 %.2f", MAModels[index].近一季BPS * 本淨比基準[1])
            legend.entries[7].label = String(format: "\(本淨比基準[0])倍 %.2f", MAModels[index].近一季BPS * 本淨比基準[0])
        }
        
        
    }
    
    @IBAction func 本益比本淨比切換(_ sender: UISegmentedControl) {
        let targetIndex = sender.selectedSegmentIndex
        switch targetIndex {
        case 0:
            基準選擇 = "本益比"
            setupData()
        case 1:
            基準選擇 = "本淨比"
            setupData()
        default:
            基準選擇 = "本益比"
            setupData()
            
        }
    }
    
    @IBAction func 時間選擇(_ sender: UISegmentedControl) {
        let targetIndex = sender.selectedSegmentIndex
        switch targetIndex {
        case 0:
            顯示資料筆數 = 12
            fetchStockData()
        case 1:
            顯示資料筆數 = 36
            fetchStockData()
        case 2:
            顯示資料筆數 = 60
            fetchStockData()
        default:
            顯示資料筆數 = 12
            fetchStockData()
        }
    }
    
    func fetchStockData() {
        APICaller.shared.getStockData { [weak self] result in
            
            guard let strongSelf = self else {
                return
            }
            
            switch result {
            case .success(let 股票):
                self?.本益比基準 = 股票.data[0].本益比基準.map({ return Double($0) ?? 0 })
                self?.本淨比基準 = 股票.data[0].本淨比基準.map({ return Double($0) ?? 0 })
                self?.MAModels = Array(股票.data[0].河流圖資料.compactMap({ 河流圖資料 -> MovingAverageViewModel in
                    strongSelf.yearMonth = 河流圖資料.年月
                    let i = strongSelf.yearMonth.index(strongSelf.yearMonth.startIndex, offsetBy: 4)
                    strongSelf.yearMonth.insert("/", at: i)
                    return MovingAverageViewModel(年月: strongSelf.yearMonth,
                                                  月平均收盤價: Double(河流圖資料.月平均收盤價) ?? 0,
                                                  近四季EPS: Double(河流圖資料.近四季Eps) ?? 0,
                                                  近一季BPS: Double(河流圖資料.近一季Bps) ?? 0)
                })[0..<strongSelf.顯示資料筆數].reversed())
                DispatchQueue.main.sync {
                    self?.setupData()
                    self?.hud.dismiss()
                }
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    
}

extension ViewController: ChartViewDelegate {
    
    func setupData() {
        
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
     
            let yVals = (0..<MAModels.count).map { j -> ChartDataEntry in
                
                var val:Double = 0.0
                
                if i == 0 {
                    val = self.MAModels[j].月平均收盤價
                }
                else {
                    if 基準選擇 == "本益比" {
                        val = self.MAModels[j].近四季EPS * self.本益比基準[i-1]
                    }
                    else {
                        val = self.MAModels[j].近一季BPS * self.本淨比基準[i-1]
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
                set.label = "股價 \(yVals[i].y)"
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
                if 基準選擇 == "本益比" {
                    set.label = "\(String(self.本益比基準[i-1])) 倍 "
                }
                else {
                    set.label = "\(String(self.本淨比基準[i-1])) 倍 "
                }
            }
            else {  // 18.18~31.83
                set.drawFilledEnabled = true
                set.fillAlpha = 1
                set.fillColor = color
                set.fillFormatter = DefaultFillFormatter(block: { dataSet, dataProvider in
                    return CGFloat(self.chartView.leftAxis.axisMinimum)
                })
                if 基準選擇 == "本益比" {
                    set.label = "\(String(self.本益比基準[i-1])) 倍 "
                }
                else {
                    set.label = "\(String(self.本淨比基準[i-1])) 倍 "
                }
            }
            
            return set
        }
        
        dataSets.reverse()
                
        let data = LineChartData(dataSets: dataSets)
        data.setValueFont(.systemFont(ofSize: 7,
                                      weight: .light))
        
        legend.extraEntries = [LegendEntry(label: "\(MAModels[MAModels.count-1].年月)")]
        
        chartView.data = data
        
        configureLegend()
    }
}

extension ViewController: AxisValueFormatter {

    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return MAModels[min(max(Int(value), 0), MAModels.count - 1)].年月
    }

    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        let index = Int(entry.x)
        chartView.legend.entries[0].label = "\(MAModels[index].年月)"
        chartView.legend.entries[1].label = String(format: "股價 %.2f", MAModels[index].月平均收盤價)
        if 基準選擇 == "本益比" {
            chartView.legend.entries[2].label = String(format: "\(本益比基準[5])倍 %.2f", MAModels[index].近四季EPS * 本益比基準[5])
            chartView.legend.entries[3].label = String(format: "\(本益比基準[4])倍 %.2f", MAModels[index].近四季EPS * 本益比基準[4])
            chartView.legend.entries[4].label = String(format: "\(本益比基準[3])倍 %.2f", MAModels[index].近四季EPS * 本益比基準[3])
            chartView.legend.entries[5].label = String(format: "\(本益比基準[2])倍 %.2f", MAModels[index].近四季EPS * 本益比基準[2])
            chartView.legend.entries[6].label = String(format: "\(本益比基準[1])倍 %.2f", MAModels[index].近四季EPS * 本益比基準[1])
            chartView.legend.entries[7].label = String(format: "\(本益比基準[0])倍 %.2f", MAModels[index].近四季EPS * 本益比基準[0])
        }
        else {
            chartView.legend.entries[2].label = String(format: "\(本淨比基準[5])倍 %.2f", MAModels[index].近一季BPS * 本淨比基準[5])
            chartView.legend.entries[3].label = String(format: "\(本淨比基準[4])倍 %.2f", MAModels[index].近一季BPS * 本淨比基準[4])
            chartView.legend.entries[4].label = String(format: "\(本淨比基準[3])倍 %.2f", MAModels[index].近一季BPS * 本淨比基準[3])
            chartView.legend.entries[5].label = String(format: "\(本淨比基準[2])倍 %.2f", MAModels[index].近一季BPS * 本淨比基準[2])
            chartView.legend.entries[6].label = String(format: "\(本淨比基準[1])倍 %.2f", MAModels[index].近一季BPS * 本淨比基準[1])
            chartView.legend.entries[7].label = String(format: "\(本淨比基準[0])倍 %.2f", MAModels[index].近一季BPS * 本淨比基準[0])
        }
        
    }
    
 
}


