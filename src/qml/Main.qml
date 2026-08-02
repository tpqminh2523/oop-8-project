import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import QtQuick.Controls

import "components/sidebar"
import "components/dialogs"
import "pages"


Window {
    id: mainWindow
    width: 1920
    height: 1080
    visible: true
    title: "Finance Dashboard App"

    visibility: Window.Maximized

    // Debug-only dialog preview bar. Hidden by default; only shown when the app
    // is launched with `--debug-dialogs` (e.g. `FManagement --debug-dialogs`).
    // This used to be shown unconditionally and covered the bottom-left of every page.
    readonly property bool debugDialogsEnabled: Qt.application.arguments.indexOf("--debug-dialogs") !== -1

    RowLayout {
        anchors.fill: parent
        spacing: 0
        visible: sessionController.isLoggedIn

        // 1. SIDEBAR NAVIGATION MENU
        Sidebar_menu_1 {
            id: sidebarMenu
            Layout.fillHeight: true
            Layout.preferredWidth: 330
        }

        // 2. PAGE CONTAINER (Switches page based on sidebar selection)
        StackLayout {
            id: pageStack
            Layout.fillWidth: true
            Layout.fillHeight: true

            currentIndex: sidebarMenu.selectedIndex

            // --- 8 MAIN PAGES ---
            OverviewPage { }      // Index 0
            TransactionsPage { }  // Index 1
            BillsPage { }         // Index 2
            BudgetsPage { }       // Index 3
            SavingsPage { }       // Index 4
            CategoriesPage { }    // Index 5
            ReportsPage { }       // Index 6
            SettingsPage { }      // Index 7
        }
    }

    // Login screen - shown first, before any app content, until sessionController
    // reports a successful login. Also shown again immediately after logout.
    LoginPage {
        anchors.fill: parent
        visible: !sessionController.isLoggedIn

        Connections {
            target: sessionController
            function onLoggedInChanged() {
                if (sessionController.isLoggedIn) {
                    sidebarMenu.selectedIndex = 0 // always land on Overview after login
                }
            }
        }
    }

    // Dialog preview overlay - for developers to eyeball dialog styling only.
    // Only visible with --debug-dialogs so it never ships on top of the real UI.
    DialogTestOverlay {
        visible: mainWindow.debugDialogsEnabled
    }
}