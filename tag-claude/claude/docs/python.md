# Python Preferences

- Please always type hint code using modern type hint practices for python 3.12, UNLESS the project indicates that an earlier version of python is used
- Please always use the pathlib library over any os commands
- When using pathlib, I prefer to use the `.joinpath` method over the overloaded `/` operator
- Please always put import statements at the top of the file, NEVER put them within a method or exception block
- Please always use the pytest package and never use unittest package for testing
- You always update the relevant `__init__.py` files when adding methods to a function. This includes the import statements and the **all** list.

## Variable Names

- Variable name: lower_snake_case
- Class name: camelCase
- Constant Name: UPPER_SNAKE_CASE
- Function Name: lower_snake_case

## Pandas

In pandas, we always prefer to use Pyarrow data dtypes. This requires that we `import pyarrow as pa` in our scripts. When importing data, be sure to specify `engine=pyarrow` for the functions that allow for it.

For strings and timestamps, we use the following variables as shorthand for the more cumbersome datatypes.

```python
pa_string = pd.ArrowDtype(pa.string())
pa_timestamp = pd.ArrowDtype(pa.timestamp("ns"))
```

It is important to use `pa_string` and not `string[pyarrow]`, which was implemented earlier and is not fully an ArrowDtype. Note that pa_string will still be represented as `string[pyarrow]` when reviewing dataframes.

Finally, the ONLY EXCEPTION to this is the categorical dtype, which is not yet implemented in pandas.

### Tweak Functions

After we import source data, we use a "tweak" function to process it. The tweak function always takes in a dataframe and outputs a dataframe. We then change the data by chaining methods together as follows:

- rename columns--always all lowercase, with single spaces replaced by underscores and then removing any other whitespace. A clean_column_name utility function should be available to you.
- use the assign method to ensure that each column is parsed properly and uses the correct datatypes. This is INTENIONALLY VERBOSE so that we can see exactly how the data is changed from the source
- Use .loc to intentionally select the columns that we want from the raw data

<example>

```python
import re
import pandas

def clean_column_name(col: str) -> str:
    col = col.replace('\t', '').replace('\n','')
    col = re.sub(r' +', '_', col)
    return col.lower()

def tweak_mainbill(df: pd.DataFrame) -> pd.DataFrame:
    return (
        df.rename(columns=clean_column_name)
        .assign(
            billtype=lambda df_: df_.billtype.str.strip().astype("category"),
            billnumber=lambda df_: df_.billtype.str.strip().astype("unt16[pyarrow]"),
            identicalbillnumber=lambda df_: df_.identicalbillnumber.str.strip()
            .apply(lambda string: util.trim_bill_number(string))
            .astype(pa_string),
            actualbillnumber=lambda df_: df_.actualbillnumber.str.strip().astype(
                pa_string
            ),
            oldbillnumber=lambda df_: df_.oldbillnumber.str.strip().astype(pa_string),
            lastsessionfullbillnumber=lambda df_: df_.lastsessionfullbillnumber.str.strip()
            .apply(lambda string: util.trim_bill_number(string))
            .astype(pa_string),
            currentstatus=lambda df_: df_.currentstatus.str.strip().astype("category"),
            billparty1=lambda df_: df_.billparty1.str.strip().astype("category"),
            billparty2=lambda df_: df_.billparty2.str.strip().astype("category"),
            billparty3=lambda df_: df_.billparty3.str.strip().astype("category"),
            firstprime=lambda df_: df_.firstprime.str.split(",", expand=True)[0]
            .replace("OPEN", pd.NA)
            .apply(lambda string: util.fix_primes(string))
            .astype("category"),
            secondprime=lambda df_: df_.secondprime.str.split(",", expand=True)[0]
            .apply(lambda string: util.fix_primes(string))
            .astype("category"),
            thirdprime=lambda df_: df_.thirdprime.str.split(",", expand=True)[0]
            .apply(lambda string: util.fix_primes(string))
            .astype("category"),
            synopsis=lambda df_: df_.synopsis.str.strip().replace(pd.NA, "OPEN"),
            governoraction=lambda df_: df_.governoraction.str.strip().astype("category"),
            ldoa=lambda df_: pd.to_datetime(df_.ldoa).astype(pa_timestamp),
            introdate=lambda df_: pd.to_datetime(df_.introdate).astype(pa_timestamp),
            proposeddate=lambda df_: pd.to_datetime(df_.proposeddate).astype(
                pa_timestamp
            ),
            moddate=lambda df_: pd.to_datetime(df_.moddate).astype(pa_timestamp),
            governordateofaction=lambda df_: pd.to_datetime(
                df_.governordateofaction
            ).astype(pa_timestamp),
            codification=lambda df_: df_.codification.str.strip().astype(pa_string),
            effectivedate=lambda df_: pd.to_datetime(df_.effectivedate).astype(
                pa_timestamp
            ),
            efdatenote=lambda df_: df_.efdatenote.str.strip().astype(pa_string),
            fncertified=lambda df_: df_.fncertified.astype(pa_string),
            bill=lambda df_: (
                df_.billtype.astype(str) + df_.billnumber.astype(str)
            ).astype(pa_string),
        )
        .loc[
            :,
            [
                "bill",
                "billtype",
                "billnumber",
                "synopsis",
                "identicalbillnumber",
                "actualbillnumber",
                "oldbillnumber",
                "lastsessionfullbillnumber",
                "currentstatus",
                "billparty1",
                "billparty2",
                "billparty3",
                "firstprime",
                "secondprime",
                "thirdprime",
                "governoraction",
                "governordateofaction",
                "pamphletlaw",
                "chapterlaw",
                "codification",
                "effectivedate",
                "efdatenote",
                "ldoa",
                "introdate",
                "moddate",
                "proposeddate",
                "fncertified",
            ],
        ]
    )
```

</example>
