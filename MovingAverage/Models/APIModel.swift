import Foundation

// MARK: - 股票
struct 股票: Codable {
    let data: [股票資料]
}

// MARK: - 股票資料
struct 股票資料: Codable {
    let 股票代號,
        股票名稱: String
    let 本益比基準: [String]
    let 本淨比基準: [String]
    let 河流圖資料: [河流圖資料]
    let 目前本益比,
        目前本淨比,
        同業本益比中位數,
        同業本淨比中位數,
        本益比股價評估,
        本淨比股價評估,
        平均本益比,
        平均本淨比,
        本益成長比: String
}

// MARK: - 河流圖資料
struct 河流圖資料: Codable {
    let 年月,
        月平均收盤價,
        近四季Eps,
        月近四季本益比: String
    let 本益比股價基準: [String]
    let 近一季Bps,
        月近一季本淨比: String
    let 本淨比股價基準: [String]
    let 平均本益比,
        平均本淨比,
        近3年年複合成長: String?

    enum CodingKeys: String, CodingKey {
        case 年月, 月平均收盤價
        case 近四季Eps = "近四季EPS"
        case 月近四季本益比, 本益比股價基準
        case 近一季Bps = "近一季BPS"
        case 月近一季本淨比, 本淨比股價基準, 平均本益比, 平均本淨比, 近3年年複合成長
    }
}
