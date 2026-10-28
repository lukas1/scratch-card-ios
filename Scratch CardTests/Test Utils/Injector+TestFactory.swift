@MainActor
func makeInjector(
    codeGenerator: @escaping ScratchCardCodeGenerator = { "SC-4829-7316" },
    testSession: TestURLSession? = nil
) -> SharedInjector {
    SharedInjector(
        codeGenerator: codeGenerator,
        testSession: testSession ?? TestURLSession()
    )
}
