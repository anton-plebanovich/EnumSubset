import EnumSubset
import Foundation

enum Database: String, CaseIterable {
    case divtrackerV2 = "divtracker-v2"
    case eod
    case events
    case finbox
    case fmp
    case iex
    case manual
    case merged
    case origin
    case seekingAlpha = "seeking-alpha"
    case yahoo
}

//@EnumSubset<Database>
//enum MainDatabase: String {
//    case divtrackerV2
//    case eod
//    case fmp
//}
//
//let main = MainDatabase.divtrackerV2
//let database = main.asDatabase
//let _ = MainDatabase(database)
