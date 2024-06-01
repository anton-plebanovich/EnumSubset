import SwiftCompilerPlugin
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

// TODO: DOC
public struct EnumSubset: MemberMacro {
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        providingMembersOf declaration: some SwiftSyntax.DeclGroupSyntax,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        guard let enumDeclSyntax = declaration.as(EnumDeclSyntax.self) else {
            context.diagnose(
                Diagnostic(
                    node: Syntax(declaration),
                    message: ErrorDiagnosticMessage(
                        id: "unsupported-type",
                        message: "'@EnumSubset' macro can only be applied to enums"
                    )
                )
            )
            
            return []
        }
        
        guard let supersetType = node
            .attributeName.as(IdentifierTypeSyntax.self)?
            .genericArgumentClause?
            .arguments.first?
            .description else {
            
            context.diagnose(
                Diagnostic(
                    node: Syntax(declaration),
                    message: ErrorDiagnosticMessage(
                        id: "missing-superset-generic",
                        message: "'@EnumSubset' macro should have superset defined as its generic parameter"
                    )
                )
            )
            
            return []
        }
        
        let supersetMemberType = supersetType.components(separatedBy: ".").last!
        let supersetTypeVariableName = supersetMemberType.prefix(1).localizedLowercase + supersetMemberType.dropFirst()
        
//        let enumName = enumDeclSyntax.name.trimmed
        let members = enumDeclSyntax.memberBlock.members
        let caseDecls = members.compactMap { $0.decl.as(EnumCaseDeclSyntax.self) }
        let elements = caseDecls.flatMap { $0.elements }
        
        let varSyntax = try VariableDeclSyntax("var asSuperset: \(raw: supersetType)") {
            try SwitchExprSyntax("switch self") {
                for element in elements {
                    SwitchCaseSyntax("""
                    case .\(element.name): return .\(element.name)
                    """)
                }
            }
        }
        
        let initializer = try InitializerDeclSyntax("init?(_ \(raw: supersetTypeVariableName): \(raw: supersetType))") {
            try SwitchExprSyntax("switch \(raw: supersetTypeVariableName)") {
                for element in elements {
                    SwitchCaseSyntax("""
                    case .\(element.name): self = .\(element.name)
                    """)
                }
                SwitchCaseSyntax("default: return nil")
            }
        }
        
        return [
            DeclSyntax(varSyntax),
            DeclSyntax(initializer),
        ]
    }
}

@main
struct EnumSubsetPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        EnumSubset.self,
    ]
}

private struct InvalidDeclarationTypeError: Error {}

private struct ErrorDiagnosticMessage: DiagnosticMessage, Error {
    let message: String
    let diagnosticID: MessageID
    let severity: DiagnosticSeverity
    
    init(id: String, message: String) {
        self.message = message
        diagnosticID = MessageID(domain: "com.anton.plebanovich.enum.subset", id: id)
        severity = .error
    }
}
