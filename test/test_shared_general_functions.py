import importlib
import os
import sys
from pathlib import Path
from unittest.mock import MagicMock, patch

from qgis.PyQt.QtCore import Qt
from qgis.gui import QgsCheckableComboBox
from qgis.testing import unittest


# Import bootstrap may need to be refactored to a utilities class when the testing suite grows
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
        combo_box = MagicMock(spec=QgsCheckableComboBox)
        combo_box.count.return_value = 4
        check_states = [
            Qt.CheckState.Checked,
            Qt.CheckState.Unchecked,
            Qt.CheckState.PartiallyChecked,
            Qt.CheckState.Checked,
        ]
        item_data = ["data1", "data2", "data3", "data4"]
        combo_box.itemCheckState.side_effect = lambda index: check_states[index]
        combo_box.itemData.side_effect = lambda index: item_data[index]

        result = gen_f.get_checkedItemsData(combo_box)

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

        with patch.object(gen_f, "QgsMessageLog") as message_log:
            gen_f.critical_log(
                func=failing_function,
                location="file/path/of/function.py",
                header="Database operation",
                error=ValueError("connection failed"),
            )

        message_log.logMessage.assert_called_once_with(
            message=(
                "Database operation ERROR at "
                "file/path/of/function.py>failing_function\n"
                "ERROR: connection failed"
            ),
            tag=gen_f.main_c.PLUGIN_NAME_LABEL,
            level=gen_f.Qgis.MessageLevel.Critical,
            notifyUser=True,
        )


if __name__ == "__main__":
    unittest.main()
