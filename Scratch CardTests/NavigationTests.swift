import Testing

struct NavigationTests {
    @Test func `GIVEN an activation sheet WHEN dismissed THEN no sheet is presented`() {
        let sut = Navigation()
        sut.showSheet(.activation)

        sut.dismissSheet()

        #expect(sut.sheet == nil)
    }
}
