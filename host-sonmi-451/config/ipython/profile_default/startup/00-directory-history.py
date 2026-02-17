import os
from IPython import get_ipython


def initialize_directory_history():
    """Initialize directory-specific history files"""
    ip = get_ipython()
    if not ip:
        return

    current_dir = os.getcwd()
    history_file = os.path.join(current_dir, ".ipython_history.sqlite")

    # Force initialization if history file doesn't exist or is different
    if not os.path.exists(history_file) or ip.history_manager.hist_file != history_file:
        try:
            # Close existing database if open
            if hasattr(ip.history_manager, "db") and ip.history_manager.db:
                ip.history_manager.db.close()

            # Set new history file
            ip.history_manager.hist_file = history_file

            # Initialize the new database
            ip.history_manager.init_db()

            print(f"Initialized history database at: {history_file}")
        except Exception as e:
            print(f"Error initializing history database: {e}")


def switch_history_on_cd():
    """Switch to directory-specific history files when changing directories"""
    initialize_directory_history()


# Initialize history for the current directory
initialize_directory_history()

# Register event to switch history when changing directories
ip = get_ipython()
if ip:
    ip.events.register("pre_execute", lambda: switch_history_on_cd())
