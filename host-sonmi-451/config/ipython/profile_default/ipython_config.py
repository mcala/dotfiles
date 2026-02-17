c = get_config()  # noqa

## lines of code to run at IPython startup.
#  Default: []
c.InteractiveShellApp.exec_lines = ["%autoreload 2"]

## A list of dotted module names of IPython extensions to load.
#  Default: []
c.InteractiveShellApp.extensions = ["autoreload"]

## Set the editor used by IPython (default to $EDITOR/vi/notepad).
c.TerminalInteractiveShell.editor = 'NVIM_APPNAME="nvim-lazy" nvim'

#  Default: 79
c.PlainTextFormatter.max_width = 120

# Ensure history is enabled
c.HistoryManager.enabled = True

c.HistoryManager.hist_file = ".ipython_history.sqlite"
c.HistoryManager.db_cache_size = 1000
