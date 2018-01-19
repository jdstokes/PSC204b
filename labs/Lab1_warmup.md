Lab1 warmup
================

We will try to reproduce some statistics from [A Statistical Analysis of the Work of Bob Ross](https://fivethirtyeight.com/features/a-statistical-analysis-of-the-work-of-bob-ross/) to demonstrate, that even basic knowledge of R will allow you to replicate world renown stats site data :)

1.  Download and load data from here [path to data](https://raw.githubusercontent.com/fivethirtyeight/data/master/bob-ross/elements-by-episode.csv) to variable df\_bob. I will tell you, that R works with web links quite well. SO you don't have to load the file from HDD ;)

``` r
# Your code
```

At this point I recommend looking at the table closesly. What type of data you have? What are the columns etc.

``` r
# Your code
```

It should be clear that what you have in each column is a logical (boolean) 0-1 value. This will come in handy :)

1.  How many episodes were aired? Save to n\_episodes variable.

2.  What percent if BOB's paintings have more than one TREE (column TREES)? How many take place in Winter?

``` r
# Your code
```

1.  How many episodes have have more than one trees AND take place in winter?

``` r
# Your code
```

1.  Create a new column called N\_THEMES that sums how many different themes are in a single image. Take look at ?rowSums function.

``` r
# Your code
```

1.  Select those episodes with the MOST themes overall and save them to df\_theme\_overload. E.g. if the most themes occuring are 15, select ALL episodes that have 15 themes.

``` r
# Your code
```

1.  What are the average amount of themes occuring in an episode. Calculate mean, median etc.

``` r
# Your code
```

1.  Calculate how many times each of the themes occured and save to a new data.frame df\_themes. Try to transform the table to the long format. So that the table has two columns \[theme, n\]. There are more approaches, but I recommend creating a new df\_themes from the data in df\_themes. Useful functions will be ?data.frame, ?colnames, ?as.vector and ?colSums.

``` r
# Your code
```

1.  In the df\_themes add new column that has the numbers of themes converted to percent. Round to whole numbers. Plot the result with the barplot function.

``` r
# Your code
#orders from the highes to lowest

#we will plot only the firt 20
```

![](https://raw.githubusercontent.com/lab-code/R-for-non-programmers/master/R/Practice/bob-fig.png)

1.  Select a first episode ever aired and print all names of themes it actually has. You will need function ?colnames and somehow select only those names that have 1 in the row. You might also need to convert data frame to vector - google how it can be done.

``` r
# Your code
```
