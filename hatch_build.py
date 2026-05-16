import subprocess
import sys

from hatchling.builders.hooks.plugin.interface import BuildHookInterface


class CustomBuildHook(BuildHookInterface):
    def initialize(self, version, build_data):
        subprocess.check_call([sys.executable, "scripts/build_fluentqml_qrc.py"])
