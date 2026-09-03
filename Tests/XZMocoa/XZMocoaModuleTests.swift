//
//  XZMocoaModuleTests.swift
//  XZKit
//
//  Created by Xezun on 2026/9/3.
//

import XCTest
import XZKit

/// XZMocoaModule 的单元测试。
///
/// 重点验证「一层存储 + 双注册」重构后的行为：
/// - 下标键 "name"、":name"、"kind:name" 的映射与等价性；
/// - 懒加载、加载状态查询、注册与删除；
/// - 遍历子模块时对双注册键的去重；
/// - XZMocoaExtendedModule 便利属性与基础方法的一致性。
///
/// @note XZMocoa 依赖 UIKit，本测试需在 iOS 平台（模拟器）下构建运行。
final class XZMocoaModuleTests: XCTestCase {

    /// 被测模块。每个用例使用独立 domain，避免 XZMocoaDomain 单例缓存造成用例间干扰。
    private var module: XZMocoaModule!
    /// domain 序号，保证每个用例的 domain 唯一。
    private static var sequence = 0

    override func setUp() {
        super.setUp()
        Self.sequence += 1
        module = XZMocoaModule(for: "mocoa://xzunittest\(Self.sequence)/")
        XCTAssertNotNil(module, "测试根模块创建失败")
    }

    override func tearDown() {
        module = nil
        super.tearDown()
    }

    /// 创建一个仅用于「作为子模块被注册」的独立模块。
    private func makeDetachedModule(_ tag: String) -> XZMocoaModule {
        let module = XZMocoaModule(for: "mocoa://xzut\(tag)\(Self.sequence)/custom")
        XCTAssertNotNil(module)
        return module!
    }

    // MARK: - 创建与 URL

    /// 通过 URL 字符串创建模块，host 与 path 应被正确解析。
    func testModuleForURLString() {
        let module = XZMocoaModule(for: "mocoa://xzutcreate/home")
        XCTAssertNotNil(module)
        XCTAssertEqual(module?.url.host, "xzutcreate")
        XCTAssertEqual(module?.url.path, "/home")
    }

    /// 相同 URL 应返回 domain 缓存的同一实例。
    func testModuleForURLReturnsCachedInstance() {
        let a = XZMocoaModule(for: "mocoa://xzutcache/main")
        let b = XZMocoaModule(for: "mocoa://xzutcache/main")
        XCTAssertNotNil(a)
        XCTAssertTrue(a === b, "相同 URL 应返回同一模块实例")
    }

    // MARK: - 下标访问与双注册等价性

    /// 下标应懒加载创建子模块，并生成正确的 URL。
    func testSubscriptLazyCreatesSubmodule() {
        let sub = module["black"]
        XCTAssertEqual(sub.url.lastPathComponent, "black")
    }

    /// 核心：default 分类下，"name" 与 ":name" 必须映射到同一模块（双注册）。
    func testDefaultKindNameEquivalence() {
        let simplified = module["black"]
        let standard = module[":black"]
        XCTAssertTrue(simplified === standard, "'black' 与 ':black' 应为同一模块")
    }

    /// 核心：cell 的 ":" 与 "" 键等价。
    func testCellKeyEquivalence() {
        XCTAssertTrue(module[":"] === module[""], "':' 与 '' 应为同一 cell 模块")
    }

    /// 相同键多次访问应返回同一实例（幂等）。
    func testSubscriptIdempotent() {
        XCTAssertTrue(module["header:black"] === module["header:black"])
    }

    /// 下标 "kind:name" 与 submodule(forKind:forName:) 应一致。
    func testSubscriptMatchesSubmoduleForKind() {
        let bySubscript = module["header:black"]
        let byMethod = module.submodule(forKind: "header", forName: "black")
        XCTAssertTrue(bySubscript === byMethod)
    }

    /// default 分类：submodule(forKind:"", forName:"main") 与 module["main"] 一致。
    func testDefaultKindSubmoduleMatchesSubscript() {
        let byMethod = module.submodule(forKind: "", forName: "main")
        XCTAssertTrue(byMethod === module["main"])
    }

    /// 不同 kind 的同名模块应相互独立。
    func testDifferentKindsAreDistinct() {
        let cell = module["black"]           // default:black
        let header = module["header:black"]  // header:black
        XCTAssertFalse(cell === header, "default 与 header 分类下的 black 应不同")
    }

    // MARK: - 加载状态、注册与删除

    /// submoduleIfLoaded 非懒加载：未创建时返回 nil，创建后返回同一实例。
    func testSubmoduleIfLoaded() {
        XCTAssertNil(module.submoduleIfLoaded(forKind: "header", forName: "black"))
        let loaded = module["header:black"]
        let found = module.submoduleIfLoaded(forKind: "header", forName: "black")
        XCTAssertTrue(loaded === found)
    }

    /// setSubmodule 注册自定义模块后，应能通过查询与下标取回同一实例。
    func testSetSubmodule() {
        let custom = makeDetachedModule("set")
        module.setSubmodule(custom, forKind: "header", forName: "black")
        XCTAssertTrue(custom === module.submoduleIfLoaded(forKind: "header", forName: "black"))
        XCTAssertTrue(custom === module["header:black"])
    }

    /// 核心：注册 default 分类子模块时，"name" 与 ":name" 应双注册到同一实例。
    func testSetSubmoduleDefaultKindDoubleRegistration() {
        let custom = makeDetachedModule("doublereg")
        module.setSubmodule(custom, forKind: "", forName: "black")
        XCTAssertTrue(custom === module["black"])
        XCTAssertTrue(custom === module[":black"])
    }

    /// setHeader(nil) 删除后，非懒加载查询应返回 nil。
    func testRemoveHeaderSubmodule() {
        _ = module.header(forName: "black")
        XCTAssertNotNil(module.submoduleIfLoaded(forKind: "header", forName: "black"))
        module.setHeader(nil, forName: "black")
        XCTAssertNil(module.submoduleIfLoaded(forKind: "header", forName: "black"))
    }

    /// 核心：删除 default 分类子模块后，"name" 与 ":name" 应同时失效（对称删除）。
    func testRemoveDefaultKindSubmodule() {
        _ = module["black"]
        XCTAssertNotNil(module.submoduleIfLoaded(forKind: "", forName: "black"))
        module.setCell(nil, forName: "black")
        XCTAssertNil(module.submoduleIfLoaded(forKind: "", forName: "black"))
    }

    // MARK: - 路径访问

    /// submodule(forPath:) 应逐段懒加载多级子模块。
    func testSubmoduleForPath() {
        let sub = module.submodule(forPath: "list/main")
        XCTAssertEqual(sub.url.lastPathComponent, "main")
    }

    /// 路径访问与逐级下标应得到同一实例。
    func testSubmoduleForPathMatchesSubscript() {
        let byPath = module.submodule(forPath: "list/header")
        let bySubscript = module["list"]["header"]
        XCTAssertTrue(byPath === bySubscript)
    }

    // MARK: - 遍历

    /// 核心：双注册的 default 模块在遍历时应只出现一次（去重）。
    func testEnumerateSubmodulesNoDuplicates() {
        _ = module["black"]         // default：双注册 "black" 与 ":black"
        _ = module["header:white"]  // header：单注册
        var count = 0
        module.enumerateSubmodules { _, _, _, _ in
            count += 1
        }
        XCTAssertEqual(count, 2, "遍历应对双注册去重，共 2 个子模块")
    }

    /// 遍历应回传正确的 kind 与 name。
    func testEnumerateSubmodulesKindAndName() {
        _ = module["black"]
        _ = module["header:white"]
        var pairs = Set<String>()
        module.enumerateSubmodules { _, kind, name, _ in
            pairs.insert("\(kind.rawValue)|\(name.rawValue)")
        }
        XCTAssertTrue(pairs.contains("|black"), "应包含 default 分类的 black")
        XCTAssertTrue(pairs.contains("header|white"), "应包含 header 分类的 white")
    }

    // MARK: - 便利属性（XZMocoaExtendedModule）

    /// main/home/user/list 便利属性应与对应下标一致。
    func testExtendedNameProperties() {
        XCTAssertTrue(module.main === module["main"])
        XCTAssertTrue(module.home === module["home"])
        XCTAssertTrue(module.user === module["user"])
        XCTAssertTrue(module.list === module["list"])
    }

    /// header/cell/footer 便利属性应与标准键一致。
    func testExtendedViewProperties() {
        XCTAssertTrue(module.header === module["header:"])
        XCTAssertTrue(module.cell === module[":"])
        XCTAssertTrue(module.footer === module["footer:"])
    }

    /// 带名便利方法应与 "kind:name" 下标一致。
    func testExtendedForNameMethods() {
        XCTAssertTrue(module.header(forName: "black") === module["header:black"])
        XCTAssertTrue(module.footer(forName: "black") === module["footer:black"])
        XCTAssertTrue(module.cell(forName: "black") === module["black"])
    }
}
