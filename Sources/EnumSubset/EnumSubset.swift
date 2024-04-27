
/// TODO: DOC
@attached(member, names: named(init), named(asSuperset))
public macro EnumSubset<Enum>() = #externalMacro(module: "EnumSubsetMacros", type: "EnumSubset")
