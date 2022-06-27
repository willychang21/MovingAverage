import Foundation
import Charts

struct MovingAverageViewModel {
    let 年月: String
    let 月平均收盤價: Double
    let 本益比股價基準,
        本淨比股價基準: [String]
    
    init(年月: String, 月平均收盤價: Double, 本益比股價基準: [String], 本淨比股價基準: [String]) {
        self.年月 = 年月
        self.月平均收盤價 = 月平均收盤價
        self.本益比股價基準 = 本益比股價基準
        self.本淨比股價基準 = 本淨比股價基準
    }
}

struct MAConstants {
    static let oneTimesColor   = NSUIColor(red:  39/255.0, green: 152/255.0, blue: 151/255.0, alpha: 1.0)
    static let twoTimesColor   = NSUIColor(red: 116/255.0, green: 154/255.0, blue: 221/255.0, alpha: 1.0)
    static let threeTimesColor = NSUIColor(red: 201/255.0, green: 224/255.0, blue: 255/255.0, alpha: 1.0)
    static let fourTimesColor  = NSUIColor(red: 255/255.0, green: 221/255.0, blue: 188/255.0, alpha: 1.0)
    static let fiveTimesColor  = NSUIColor(red: 255/255.0, green: 184/255.0, blue: 130/255.0, alpha: 1.0)
    static let sixTimesColor   = NSUIColor(red: 255/255.0, green: 137/255.0, blue: 137/255.0, alpha: 1.0)
    static let redColor        = NSUIColor(red: 255/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)
    static let black           = NSUIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)
}
