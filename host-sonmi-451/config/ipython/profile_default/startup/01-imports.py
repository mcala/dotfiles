from pathlib import Path

import pandas as pd


# Setting to zero will have pandas produce the exact terminal size of rows/columns
pd.set_option("display.max_columns", 0)
pd.set_option("display.max_rows", 0)


def reset_df_display() -> None:
    pd.set_option("display.max_columns", 50)
    pd.set_option("display.max_rows", 80)


def display_full(df: pd.DataFrame) -> None:
    """Display DataFrame without truncation"""
    with pd.option_context(
        "display.max_rows",
        None,
        "display.max_columns",
        None,
        "display.width",
        None,
        "display.max_colwidth",
        None,
    ):
        print(df)
