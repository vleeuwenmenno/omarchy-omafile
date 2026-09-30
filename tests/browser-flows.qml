import QtQuick
import QtTest
import Quickshell
import "FilePlugin/components" as Plugin
import "FilePlugin/tests" as Mocks
ShellRoot {
  id: harness
  property bool passed: false
  Mocks.MockService { id: mock }
  FloatingWindow {
    id: window
    visible: true
    implicitWidth: 1000; implicitHeight: 640
    Plugin.Browser { id: browser; anchors.fill: parent; service: mock }
    TestCase {
      id: tests
      name: "BrowserFlows"
      when: window.visible
      onCompletedChanged: {
        if (!harness.passed) console.log("OMAFILE_BROWSER_FLOWS_FAILED")
        Qt.quit()
      }
      function cleanup() { if (qtest_results.failed) console.log("FAILED_IN " + qtest_results.functionName) }
      function pane() { return browser.activePane() }
      function names() { return pane().rows.map(function (r) { return r[0] }) }
      function waitRows() { tryVerify(function () { return pane().rows.length === 3 && !pane().loading }, 5000) }
      function menuItem(label) {
        var idx = -1
        for (var i = 0; i < browser.menuActions.length; i++) if (browser.menuActions[i].label === label) idx = i
        verify(idx >= 0, "menu item " + label)
        browser.runAction(browser.menuActions[idx].key)
      }

      function test_1_openWith() {
        waitRows()
        tryVerify(function () { return DesktopEntries.applications.values.length > 0 }, 10000)
        pane().setCursor(0, false, false)
        browser.menuEntry = pane().cursorEntry()
        browser.runAction("openwith")
        compare(browser.dialogMode, "openwith")
        var list = findChild(browser, "openWithList")
        wait(200)
        mouseClick(list.itemAtIndex(0))
        var call = mock.called("openWith")
        verify(call !== null, "openWith called by click")
        compare(call.args[1], "/tmp/alpha.yml")
        compare(browser.dialogMode, "")
      }

      function test_2_sortMenu() {
        waitRows()
        mouseClick(findChild(browser, "viewButton"))
        verify(browser.menuOpen)
        compare(browser.menuKind, "view")
        menuItem("Z to A")
        verify(!browser.menuOpen)
        compare(pane().sortBy, "name")
        compare(pane().descending, true)
        browser.setView("grid")
        mouseClick(findChild(browser, "viewButton"))
        menuItem("Last modified")
        compare(pane().sortBy, "modified")
        compare(pane().descending, true)
        compare(names()[0], "docs")
        compare(names()[1], "alpha.yml")
        browser.setView("list")
      }

      function test_3_viewMenu() {
        waitRows()
        var modes = [["Compact", "compact"], ["Grid", "grid"], ["List", "list"]]
        for (var i = 0; i < modes.length; i++) {
          mouseClick(findChild(browser, "viewButton"))
          compare(browser.menuKind, "view")
          menuItem(modes[i][0])
          compare(pane().view, modes[i][1])
          wait(50)
          mouseClick(pane(), 60, pane().view === "list" ? 40 : 20)
          compare(pane().selectedCount, 1, "click selects in " + modes[i][1])
        }
      }

      function test_3a_thumbnailRequests() {
        waitRows()
        browser.setView("grid")
        waitForRendering(browser)
        var call = mock.called("thumbnailFor")
        verify(call !== null, "grid asks for a generated thumbnail")
        compare(call.args[0], "/tmp/alpha.yml")
        compare(call.args[2], "large")
        for (var i = 0; i < mock.calls.length; i++)
          if (mock.calls[i].name === "thumbnailFor") verify(mock.calls[i].args[0] !== "/tmp/beta.png", "images load directly")
        browser.setView("list")
      }

      function test_3b_zoomAndMenus() {
        waitRows()
        browser.setViewScale(1)
        mouseClick(findChild(browser, "viewButton"))
        compare(browser.menuKind, "view")
        waitForRendering(browser)
        mouseClick(findChild(browser, "zoom-in"))
        verify(browser.menuOpen, "zoom keeps the menu open")
        compare(browser.viewScale, 1.1)
        mouseClick(findChild(browser, "zoom-in"))
        compare(browser.viewScale, 1.2)
        mouseClick(findChild(browser, "zoom-out"))
        compare(browser.viewScale, 1.1)
        compare(pane().viewScale, 1.1)
        mouseClick(findChild(browser, "zoom-reset"))
        compare(browser.viewScale, 1)
        var hidden = pane().showHidden
        menuItem("Show hidden files")
        compare(pane().showHidden, !hidden)
        verify(!browser.menuOpen)
        pane().showHidden = hidden
        mouseWheel(pane(), 200, 200, 0, 120, Qt.NoButton, Qt.ControlModifier)
        compare(browser.viewScale, 1.1)
        mouseWheel(pane(), 200, 200, 0, -240, Qt.NoButton, Qt.ControlModifier)
        compare(browser.viewScale, 0.9)
        for (var i = 0; i < 30; i++) mouseWheel(pane(), 200, 200, 0, 120, Qt.NoButton, Qt.ControlModifier)
        compare(browser.viewScale, 3)
        for (var j = 0; j < 30; j++) mouseWheel(pane(), 200, 200, 0, -120, Qt.NoButton, Qt.ControlModifier)
        compare(browser.viewScale, 0.5)
        browser.setViewScale(1)
        mouseClick(findChild(browser, "mainMenuButton"))
        compare(browser.menuKind, "main")
        menuItem("Keyboard shortcuts")
        compare(browser.dialogMode, "shortcuts")
        browser.closeDialog()
      }

      function test_3c_dragAndDrop() {
        waitRows()
        pane().setSortOrder("name", false)
        var data = pane().dragMimeData(["/tmp/alpha.yml", "/tmp/my file #2.txt"])
        compare(data["text/uri-list"], "file:///tmp/alpha.yml\r\nfile:///tmp/my%20file%20%232.txt\r\n")

        mock.calls = []
        browser.dropFiles(["/tmp/alpha.yml"], "/tmp", "auto")
        compare(mock.called("beginTransfer"), null, "dropping into the same folder does nothing")
        browser.dropFiles(["/tmp/docs"], "/tmp/docs/inner", "copy")
        compare(mock.called("beginTransfer"), null, "a folder never goes into itself")

        browser.dropFiles(["/tmp/alpha.yml", "/tmp/beta.png"], "/tmp/docs", "auto")
        var call = mock.called("beginTransfer")
        compare(call.args[0], "move")
        compare(call.args[1], ["/tmp/alpha.yml", "/tmp/beta.png"])
        compare(call.args[2], "/tmp/docs")

        mock.devices = { "/media/usb": 2 }
        browser.dropFiles(["/tmp/alpha.yml"], "/media/usb", "auto")
        compare(mock.called("beginTransfer").args[0], "copy", "another drive copies")
        mock.devices = ({})

        mock.calls = []
        browser.dropFiles(["/home/me/Downloads/pic.png"], "/tmp", "copy")
        compare(mock.called("beginTransfer").args[0], "copy")
        compare(mock.called("statPaths"), null, "copies skip the device check")

        mock.values = { confirmTrash: false }
        browser.dropFiles(["/tmp/alpha.yml"], "/tmp/.trash", "trash")
        compare(mock.called("trashPaths").args[0], ["/tmp/alpha.yml"])
        mock.values = ({})

        waitRows()
        pane().selectAll()
        compare(pane().selectedCount, 3)
        var first = pane().activeView().itemAtIndex(0)
        mousePress(first, 40, first.height / 2)
        compare(pane().selectedCount, 3, "pressing a selected item keeps the selection for dragging")
        mouseRelease(first, 40, first.height / 2)
        compare(pane().selectedCount, 1, "releasing without a drag selects just that item")
      }

      function test_3e_breadcrumbDrops() {
        var bar = findChild(browser, "pathBar")
        verify(bar !== null, "path bar")
        compare(bar.crumbTarget({ label: "~", path: "~" }), bar.home || "/")
        compare(bar.crumbTarget({ label: "docs", path: "~/docs" }), (bar.home || "") + "/docs")
        compare(bar.crumbTarget({ label: "tmp", path: "/tmp" }), "/tmp")
        mock.calls = []
        bar.filesDropped(["/tmp/docs/inner.txt"], "/tmp", "auto")
        compare(mock.called("beginTransfer").args[0], "move")
        compare(mock.called("beginTransfer").args[2], "/tmp")
      }

      function test_4_mouseBackForward() {
        waitRows()
        pane().navigate("/tmp/docs")
        pane().navigate("/tmp/docs/inner")
        compare(pane().path, "/tmp/docs/inner")
        mouseClick(pane(), 200, 200, Qt.BackButton)
        compare(pane().path, "/tmp/docs")
        mouseClick(pane(), 200, 200, Qt.BackButton)
        compare(pane().path, "/tmp")
        mouseClick(pane(), 200, 200, Qt.ForwardButton)
        compare(pane().path, "/tmp/docs")
        pane().navigate("/tmp")
        waitRows()
      }

      function test_5_preview() {
        waitRows()
        pane().setSortOrder("name", false)
        pane().setCursor(0, false, false)
        compare(pane().cursorEntry().name, "alpha.yml")
        keyClick(Qt.Key_Space)
        verify(browser.previewOpen)
        compare(browser.previewKind, "text")
        compare(browser.previewText, "key: value\n")
        var text = findChild(browser, "previewText")
        verify(text.visible, "text preview visible")
        keyClick(Qt.Key_Right)
        compare(browser.previewEntry.name, "beta.png")
        compare(browser.previewKind, "image")
        keyClick(Qt.Key_Space)
        verify(!browser.previewOpen)
      }

      function test_6_settingsFit() {
        window.implicitWidth = 480
        window.implicitHeight = 330
        wait(100)
        browser.showDialog("settings", "Settings", "", null)
        wait(50)
        var card = findChild(browser, "dialogCard")
        verify(card.width <= browser.width, "card width " + card.width + " fits " + browser.width)
        verify(card.height <= browser.height, "card height " + card.height + " fits " + browser.height)
        browser.closeDialog()
        window.implicitWidth = 1000
        window.implicitHeight = 640
        wait(100)
      }

      function labels(entry) {
        return browser.contextActions(entry).map(function (a) { return a.label })
      }

      function test_5a_trashView() {
        waitRows()
        pane().setSortOrder("name", false)
        var bar = findChild(browser, "trashBarA")
        verify(!bar.visible, "no trash bar outside the trash")
        pane().setCursor(0, false, false)
        verify(labels(pane().cursorEntry()).indexOf("Move to trash") >= 0)
        verify(labels(pane().cursorEntry()).indexOf("Restore") < 0)

        mock.trashCount = 0
        pane().navigate("/tmp/.trash")
        waitRows()
        waitForRendering(browser)
        verify(bar.visible, "trash bar shows in the trash")
        var button = findChild(bar, "emptyTrashButton")
        verify(!button.enabled, "empty trash is disabled when the trash is empty")
        compare(findChild(bar, "trashSummary").text, "Empty")

        mock.trashCount = 3
        verify(button.enabled)
        compare(findChild(bar, "trashSummary").text, "3 items")
        mock.calls = []
        mouseClick(button)
        verify(findChild(browser, "trashBarA") !== null)
        compare(browser.confirmAction, "emptytrash")
        compare(mock.called("emptyTrash"), null, "asks before emptying")
        keyClick(Qt.Key_Return)
        verify(mock.called("emptyTrash") !== null)
        compare(browser.confirmAction, "")
        verify(!button.enabled, "disabled again once emptied")
        compare(pane().path, "/tmp/.trash")

        waitRows()
        pane().setCursor(0, false, false)
        var entry = pane().cursorEntry()
        compare(entry.path, "/tmp/.trash/alpha.yml")
        var inTrash = labels(entry)
        verify(inTrash.indexOf("Move to trash") < 0, "no second trash from the trash")
        verify(inTrash.indexOf("Delete permanently") >= 0)
        verify(inTrash.indexOf("Restore") >= 0)
        var empty = browser.contextActions(null)
        var emptyItem = empty.filter(function (a) { return a.key === "emptytrash" })[0]
        verify(emptyItem !== undefined, "empty area menu offers Empty trash")
        verify(emptyItem.disabled === true)

        mock.calls = []
        keyClick(Qt.Key_Delete)
        compare(mock.called("trashPaths"), null, "Delete never trashes again")
        compare(browser.confirmAction, "delete")
        keyClick(Qt.Key_Return)
        compare(mock.called("deletePaths").args[0], ["/tmp/.trash/alpha.yml"])

        mock.calls = []
        pane().setCursor(0, false, false)
        keyClick(Qt.Key_Delete, Qt.ShiftModifier)
        compare(browser.confirmAction, "delete")
        keyClick(Qt.Key_Escape)
        compare(browser.confirmAction, "")
        compare(mock.called("deletePaths"), null)

        pane().setCursor(1, false, false)
        browser.menuEntry = pane().cursorEntry()
        var restoring = browser.menuEntry.name
        browser.menuActions = browser.contextActions(browser.menuEntry)
        menuItem("Restore")
        compare(mock.called("restoreFromTrash").args[0], [restoring])
        compare(browser.statusText, "1 item restored")

        waitRows()
        mock.calls = []
        mock.values = { confirmTrash: false }
        pane().setCursor(0, false, false)
        browser.menuActions = browser.contextActions(pane().cursorEntry())
        menuItem("Delete permanently")
        compare(mock.called("trashPaths"), null)
        compare(browser.confirmAction, "delete")
        keyClick(Qt.Key_Escape)
        mock.values = ({})

        pane().navigate("/tmp")
        waitRows()
        verify(!bar.visible)
      }

      function test_7_pickOpen() {
        waitRows()
        mock.pickRequest = { mode: "open", multiple: false, directory: false, result: "/run/x.json",
          filters: [{ name: "Images", patterns: ["*.png"] }, { name: "All", patterns: ["*"] }], currentFilter: 0 }
        browser.beginPickSession()
        verify(findChild(browser, "pickBar").visible)
        tryVerify(function () { return !pane().loading && pane().rows.length === 2 })
        waitForRendering(browser)
        verify(names().indexOf("alpha.yml") < 0, "filter hides yml")
        browser.pickFilter = 1
        compare(pane().rows.length, 3)
        var idx = names().indexOf("beta.png")
        pane().setCursor(idx, false, false)
        keyClick(Qt.Key_Return)
        var call = mock.called("finishPick")
        verify(call !== null)
        compare(call.args[0].ok, true)
        compare(call.args[0].paths[0], "/tmp/beta.png")
        compare(call.args[0].filter, 1)
        verify(!browser.picking)
      }

      function test_8_pickSaveAndCancel() {
        mock.calls = []
        mock.pickRequest = { mode: "save", result: "/run/y.json", currentFolder: "/tmp", currentName: "new.txt", filters: [] }
        browser.beginPickSession()
        tryVerify(function () { return !pane().loading && pane().rows.length === 3 })
        waitForRendering(browser)
        mouseClick(findChild(browser, "pickAccept"))
        compare(mock.called("finishPick").args[0].paths[0], "/tmp/new.txt")
        mock.calls = []
        mock.pickRequest = { mode: "save", result: "/run/z.json", currentFolder: "/tmp", currentName: "alpha.yml" }
        browser.beginPickSession()
        tryVerify(function () { return !pane().loading && pane().rows.length === 3 })
        waitForRendering(browser)
        mouseClick(findChild(browser, "pickAccept"))
        compare(mock.called("finishPick"), null, "asks before replacing")
        keyClick(Qt.Key_Escape)
        verify(browser.picking, "escape only dismisses the replace prompt")
        mouseClick(findChild(browser, "pickAccept"))
        keyClick(Qt.Key_Return)
        compare(mock.called("finishPick").args[0].paths[0], "/tmp/alpha.yml")
        mock.calls = []
        mock.pickRequest = { mode: "open", result: "/run/w.json" }
        browser.beginPickSession()
        waitForRendering(browser)
        keyClick(Qt.Key_Escape)
        compare(mock.called("finishPick").args[0].ok, false)
        console.log("OMAFILE_BROWSER_FLOWS_PASSED")
        harness.passed = true
      }
    }
  }
  Timer { interval: 60000; running: true; onTriggered: { console.log("OMAFILE_BROWSER_FLOWS_TIMEOUT"); Qt.quit() } }
}
