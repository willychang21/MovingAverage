import Foundation
import UIKit

struct Constants {
    static let baseURL = "https://api.nstock.tw/v2/per-river/interview?stock_id="
    static let 股票代號 = "2330"
}

final class APICaller {
    static let shared = APICaller()
    
    private init() {}
    
    ///  取得個股資料
    public func getStockData(completion: @escaping(Result<股票, Error>) -> Void) {
        
        guard let url = URL(string: Constants.baseURL + Constants.股票代號) else {
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            
            guard let data = data, error == nil else {
                return
            }
            
            do {
                let stock = try JSONDecoder().decode(股票.self, from: data)
                completion(.success(stock))
            }
            catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
}


