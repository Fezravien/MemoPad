import UIKit
import CoreData

class MemoData {
    var memoIdx: Int? // 데이터 식별 값
    var title: String? // 메모 제목
    var contents: String? // 메모 내용
    var image: UIImage? // 이미지
    var regdata: Date? // 작성일
    var objectID: NSManagedObjectID?
}
