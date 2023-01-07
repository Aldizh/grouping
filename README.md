# Programming Exercise - Grouping

The goal of this exercise is to identify rows in a CSV file that
__may__ represent the __same person__ based on a provided __Matching Type__ (definition below).

The resulting program should allow us to test at least three matching types:
 - one that matches records with the same email address
 - one that matches records with the same phone number
 - one that matches records with the same email address OR the same phone number

## Guidelines

* **Please DO NOT fork this repository with your solution**
* Use any language you want, as long as it can be compiled on OSX
* Only use code that you have license to use
* Don't hesitate to ask us any questions to clarify the project

## Resources

### CSV Files

Three sample input files are included. All files should be successfully
processed by the resulting code.

### Matching Type

A matching type is a declaration of what logic should be used to compare the rows.

For example: A matching type named same_email might make use of an algorithm that 
matches rows based on email columns.

## Interface

At a high level, the program should take two parameters. The input file
and the matching type.

## Output

The expected output is a copy of the original CSV file with the unique 
identifier of the person each row represents prepended to the row.

## Solution approach

- Create a uniqueness map of the criteria based on columns
- Matching criteria will determine the key of the row entry on this map
- We will call this key personID
- Iterate through the rows
  - If there is a value for matching criteria (email/phone)
    - If it exists on our map tag with the same person ID
    - Otherwise tag with a new person ID
- Basically we only tag rows with a new personID that are unique by the criteria

## Assumtions
- Accounting only for U.S numbers
- If there are multiple columns for same criteria such as email1 and email2 consider both
- File size < 10mb

## Running the project

```$ ruby init.rb```

## Libraries used

csv ruby library for working with csv files
