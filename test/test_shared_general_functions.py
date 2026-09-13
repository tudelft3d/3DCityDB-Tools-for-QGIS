import importlib
import os
import sys
from pathlib import Path

from qgis.PyQt.QtCore import Qt
from qgis.PyQt.QtTest import QSignalSpy
from qgis.PyQt.QtWidgets import QVBoxLayout
from qgis.core import QgsApplication
from qgis.gui import QgsCheckableComboBox, QgsMessageBar
from qgis.testing import start_app, unittest

start_app()

# Import bootstrap may need to be refactored to a utilities class when the testing suite grows
# Hacky solution to run tests in situ 
PLUGIN_ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(PLUGIN_ROOT.parent))
try:
    gen_f = importlib.import_module(
        f"{PLUGIN_ROOT.name}.cdb4.shared.functions.general_functions"
    )
finally:
    sys.path.pop(0)


class TestSharedGeneralFunctions(unittest.TestCase):
    def test_get_checked_items_data(self) -> None:
        """Only data from fully checked items is returned."""
        ccbx = QgsCheckableComboBox()
        ccbx.addItemWithCheckState("item 1", Qt.CheckState.Checked, "data1")
        ccbx.addItemWithCheckState("item 2", Qt.CheckState.Unchecked, "data2")
        ccbx.addItemWithCheckState("item 3", Qt.CheckState.PartiallyChecked, "data3")
        ccbx.addItemWithCheckState("item 4", Qt.CheckState.Checked, "data4")

        result = gen_f.get_checkedItemsData(ccbx)

        self.assertEqual(result, ["data1", "data4"])

    def test_get_file_relative_path_for_supplied_file(self) -> None:
        """A supplied path is made relative to the plugins directory."""

        result = gen_f.get_file_relative_path(__file__)

        expected = os.path.join(
            PLUGIN_ROOT.name, "test", "test_shared_general_functions.py"
        )
        self.assertEqual(result, expected)

    def test_get_file_relative_path_defaults_to_its_module(self) -> None:
        """Without an argument, the function returns its module's relative path."""
        result = gen_f.get_file_relative_path()

        expected = os.path.join(
            PLUGIN_ROOT.name,
            "cdb4",
            "shared",
            "functions",
            "general_functions.py",
        )
        self.assertEqual(result, expected)

    def test_critical_log_writes_formatted_message(self) -> None:
        """Errors are written to the QGIS log with their source and severity."""
        def failing_function() -> None:
            pass

        message_spy = QSignalSpy(
            QgsApplication.messageLog().messageReceived
        )
        notification_spy = QSignalSpy(
            QgsApplication.messageLog().messageReceived[bool]
        )

        gen_f.critical_log(
            func=failing_function,
            location="file/path/of/function.py",
            header="Database operation",
            error=ValueError("connection failed"),
        )

        self.assertEqual(len(message_spy), 1)
        message, tag, level = message_spy[0]
        self.assertEqual(
            message,
            (
                "Database operation ERROR at "
                "file/path/of/function.py>failing_function\n"
                "ERROR: connection failed"
            ),
        )
        self.assertEqual(tag, gen_f.main_c.PLUGIN_NAME_LABEL)
        self.assertEqual(level, gen_f.Qgis.MessageLevel.Critical)
        self.assertEqual(list(notification_spy), [[True]])

    def test_push_message_bar_message_dispatches_by_message_level(self) -> None:
        """Each supported message level is shown on the inserted message bar."""
        title = "Operation status"
        message = "Operation completed"
        cases = (
            gen_f.Qgis.MessageLevel.Info,
            gen_f.Qgis.MessageLevel.Warning,
            gen_f.Qgis.MessageLevel.Critical,
            gen_f.Qgis.MessageLevel.Success,
        )

        for message_level in cases:
            with self.subTest(message_level=message_level):
                layout = QVBoxLayout()
                gen_f.push_message_bar_message(
                    layout=layout,
                    index=0,
                    message=message,
                    message_type=message_level,
                    title=title,
                )

                message_bar = layout.itemAt(0).widget()
                self.assertIsInstance(message_bar, QgsMessageBar)
                message_item = message_bar.currentItem()
                self.assertEqual(message_item.title(), title)
                self.assertEqual(message_item.text(), message)
                self.assertEqual(message_item.level(), message_level)

    def test_push_message_bar_message_uses_generic_fallback(self) -> None:
        """An unrecognized message level uses the generic message method (defaulting to Info)"""

        layout = QVBoxLayout()
        gen_f.push_message_bar_message(
            layout=layout,
            index=0,
            message="Unknown status",
            message_type=gen_f.Qgis.MessageLevel.NoLevel,
            title="Operation status",
        )

        message_bar = layout.itemAt(0).widget()
        self.assertIsInstance(message_bar, QgsMessageBar)
        message_item = message_bar.currentItem()
        self.assertEqual(message_item.text(), "Unknown status"),
        self.assertEqual(message_item.level(), gen_f.Qgis.MessageLevel.Info),
        self.assertEqual(message_item.title(), "Operation status")

if __name__ == "__main__":
    unittest.main()
