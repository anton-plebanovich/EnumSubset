import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(EnumSubsetMacros)
import EnumSubsetMacros

let testMacros: [String: Macro.Type] = [
    "EnumSubset": EnumSubset.self,
]
#endif

final class EnumSubsetTests: XCTestCase {
    
    func testMacro() throws {
#if canImport(EnumSubsetMacros)
        assertMacroExpansion(
            """
            @EnumSubset<Database>
            enum SupportedDatabase: String, CaseIterable {
                case divtrackerV2
                case eod
                case fmp
            }
            """,
            expandedSource: """
            enum SupportedDatabase: String, CaseIterable {
                case divtrackerV2
                case eod
                case fmp
            
                var asSuperset: Database {
                    switch self {
                    case .divtrackerV2:
                        return .divtrackerV2
                    case .eod:
                        return .eod
                    case .fmp:
                        return .fmp
                    }
                }
            
                init?(_ database: Database) {
                    switch database {
                    case .divtrackerV2:
                        self = .divtrackerV2
                    case .eod:
                        self = .eod
                    case .fmp:
                        self = .fmp
                    default:
                        return nil
                    }
                }
            }
            """,
            macros: testMacros
        )
#else
        throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }
    
    func testMacroComposedSupersetType() throws {
#if canImport(EnumSubsetMacros)
        assertMacroExpansion(
            """
            @EnumSubset<Namespace.Database>
            enum SupportedDatabase: String, CaseIterable {
                case divtrackerV2
                case eod
                case fmp
            }
            """,
            expandedSource: """
            enum SupportedDatabase: String, CaseIterable {
                case divtrackerV2
                case eod
                case fmp
            
                var asSuperset: Namespace.Database {
                    switch self {
                    case .divtrackerV2:
                        return .divtrackerV2
                    case .eod:
                        return .eod
                    case .fmp:
                        return .fmp
                    }
                }
            
                init?(_ database: Namespace.Database) {
                    switch database {
                    case .divtrackerV2:
                        self = .divtrackerV2
                    case .eod:
                        self = .eod
                    case .fmp:
                        self = .fmp
                    default:
                        return nil
                    }
                }
            }
            """,
            macros: testMacros
        )
#else
        throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }
    
    func testSlopeSubsetOnStruct() throws {
#if canImport(EnumSubsetMacros)
        assertMacroExpansion(
            """
            @EnumSubset<Database>
            struct Skier {}
            """,
            expandedSource: """
            struct Skier {}
            """,
            diagnostics: [
                DiagnosticSpec(message: "'@EnumSubset' macro can only be applied to enums", line: 1, column: 1)
            ],
            macros: testMacros
        )
#else
        throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }
    
    func testSlopeSubsetOnNongeneric() throws {
#if canImport(EnumSubsetMacros)
        assertMacroExpansion(
            """
            @EnumSubset
            enum Skier {}
            """,
            expandedSource: """
            enum Skier {}
            """,
            diagnostics: [
                DiagnosticSpec(message: "'@EnumSubset' macro should have superset defined as its generic parameter", line: 1, column: 1)
            ],
            macros: testMacros
        )
#else
        throw XCTSkip("macros are only supported when running tests for the host platform")
#endif
    }
}
