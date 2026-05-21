# Python Preferences

- Please always type hint code using modern type hint practices for python 3.13, UNLESS the project indicates that an
  earlier version of python is used
- Please always use the pathlib library over any os commands
- When using pathlib, I prefer to use the `.joinpath` method over the overloaded `/` operator
- Please use typer over argparse or click
- Please always put import statements at the top of the file, NEVER put them within a method or exception block
- Please always use the pytest package and never use unittest package for testing
- You always update the relevant `__init__.py` files when adding methods to a function. This includes the import
  statements and the **all** list.

## Variable Names

- Variable name: lower_snake_case
- Class name: camelCase
- Constant Name: UPPER_SNAKE_CASE
- Function Name: lower_snake_case

## Pandas

In pandas, we always prefer to use Pyarrow data dtypes. This requires that we `import pyarrow as pa` in our scripts.
When importing data, be sure to specify `engine=pyarrow` for the functions that allow for it.

For strings and timestamps, we use the following variables as shorthand for the more cumbersome datatypes.

```python
pa_string = pd.ArrowDtype(pa.string())
pa_timestamp = pd.ArrowDtype(pa.timestamp("ns"))
```

It is important to use `pa_string` and not `string[pyarrow]`, which was implemented earlier and is not fully an
ArrowDtype. Note that pa_string will still be represented as `string[pyarrow]` when reviewing dataframes.

Finally, the ONLY EXCEPTION to this is the categorical dtype, which is not yet implemented in pandas.
