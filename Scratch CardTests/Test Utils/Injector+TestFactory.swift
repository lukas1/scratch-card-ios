@MainActor
func makeInjector(
    codeGenerator: @escaping ScratchCardCodeGenerator = { "SC-4829-7316" },
    testSession: TestURLSession = TestURLSession()
) -> SharedInjector {
    SharedInjector(
        codeGenerator: codeGenerator,
        testSession: testSession
    )
}
