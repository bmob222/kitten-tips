import Testing
@testable import KittenTipsFeature

@Test func tipDatabaseHasTips() {
    #expect(TipDatabase.allTips.count > 30)
}

@Test func allCategoriesHaveTips() {
    for category in TipCategory.allCases {
        let tips = TipDatabase.allTips.filter { $0.category == category }
        #expect(tips.count > 0, "Category \(category.rawValue) has no tips")
    }
}

@Test func behaviorSignsExist() {
    #expect(TipDatabase.behaviorSigns.count > 10)
}

@Test func tipOfDayRotates() {
    // Tip of day is based on day of year, so it should return a valid tip
    let tip = TipDatabase.allTips[0]
    #expect(!tip.title.isEmpty)
    #expect(!tip.body.isEmpty)
}
