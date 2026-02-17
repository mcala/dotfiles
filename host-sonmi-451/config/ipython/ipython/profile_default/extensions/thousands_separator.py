default_int_printer = None


def print_int(number, printer, cycle):
    printer.text(f"{number:,}")


def load_ipython_extension(ipython):
    global default_int_printer

    default_int_printer = ipython.display_formatter.formatters["text/plain"].for_type(
        int, print_int
    )


def unload_ipython_extension(ipython):
    ipython.display_formatter.formatters["text/plain"].for_type(
        int, default_int_printer
    )
