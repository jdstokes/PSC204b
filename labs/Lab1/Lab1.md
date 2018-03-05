Lab1 warmup
================

We will try to reproduce some statistics from [A Statistical Analysis of the Work of Bob Ross](https://fivethirtyeight.com/features/a-statistical-analysis-of-the-work-of-bob-ross/) to demonstrate, that even basic knowledge of R will allow you to replicate world renown stats site data :)

1.  Download and load data from here [path to data](https://raw.githubusercontent.com/fivethirtyeight/data/master/bob-ross/elements-by-episode.csv) to variable df\_bob. I will tell you, that R works with web links quite well. SO you don't have to load the file from HDD ;)

``` r
# Your code
df_bob <- read.csv("https://raw.githubusercontent.com/fivethirtyeight/data/master/bob-ross/elements-by-episode.csv", header = T)
nrow(df_bob)
```

    ## [1] 403

``` r
ncol(df_bob)
```

    ## [1] 69

At this point I recommend looking at the table closesly. What type of data you have? What are the columns etc.

``` r
# Your code


head(df_bob)
```

    ##   EPISODE                 TITLE APPLE_FRAME AURORA_BOREALIS BARN BEACH
    ## 1  S01E01 "A WALK IN THE WOODS"           0               0    0     0
    ## 2  S01E02        "MT. MCKINLEY"           0               0    0     0
    ## 3  S01E03        "EBONY SUNSET"           0               0    0     0
    ## 4  S01E04         "WINTER MIST"           0               0    0     0
    ## 5  S01E05        "QUIET STREAM"           0               0    0     0
    ## 6  S01E06         "WINTER MOON"           0               0    0     0
    ##   BOAT BRIDGE BUILDING BUSHES CABIN CACTUS CIRCLE_FRAME CIRRUS CLIFF
    ## 1    0      0        0      1     0      0            0      0     0
    ## 2    0      0        0      0     1      0            0      0     0
    ## 3    0      0        0      0     1      0            0      0     0
    ## 4    0      0        0      1     0      0            0      0     0
    ## 5    0      0        0      0     0      0            0      0     0
    ## 6    0      0        0      0     1      0            0      0     0
    ##   CLOUDS CONIFER CUMULUS DECIDUOUS DIANE_ANDRE DOCK DOUBLE_OVAL_FRAME FARM
    ## 1      0       0       0         1           0    0                 0    0
    ## 2      1       1       0         0           0    0                 0    0
    ## 3      0       1       0         0           0    0                 0    0
    ## 4      1       1       0         0           0    0                 0    0
    ## 5      0       0       0         1           0    0                 0    0
    ## 6      0       1       0         0           0    0                 0    0
    ##   FENCE FIRE FLORIDA_FRAME FLOWERS FOG FRAMED GRASS GUEST
    ## 1     0    0             0       0   0      0     1     0
    ## 2     0    0             0       0   0      0     0     0
    ## 3     1    0             0       0   0      0     0     0
    ## 4     0    0             0       0   0      0     0     0
    ## 5     0    0             0       0   0      0     0     0
    ## 6     0    0             0       0   0      0     0     0
    ##   HALF_CIRCLE_FRAME HALF_OVAL_FRAME HILLS LAKE LAKES LIGHTHOUSE MILL MOON
    ## 1                 0               0     0    0     0          0    0    0
    ## 2                 0               0     0    0     0          0    0    0
    ## 3                 0               0     0    0     0          0    0    0
    ## 4                 0               0     0    1     0          0    0    0
    ## 5                 0               0     0    0     0          0    0    0
    ## 6                 0               0     0    1     0          0    0    1
    ##   MOUNTAIN MOUNTAINS NIGHT OCEAN OVAL_FRAME PALM_TREES PATH PERSON
    ## 1        0         0     0     0          0          0    0      0
    ## 2        1         0     0     0          0          0    0      0
    ## 3        1         1     0     0          0          0    0      0
    ## 4        1         0     0     0          0          0    0      0
    ## 5        0         0     0     0          0          0    0      0
    ## 6        1         1     1     0          0          0    0      0
    ##   PORTRAIT RECTANGLE_3D_FRAME RECTANGULAR_FRAME RIVER ROCKS SEASHELL_FRAME
    ## 1        0                  0                 0     1     0              0
    ## 2        0                  0                 0     0     0              0
    ## 3        0                  0                 0     0     0              0
    ## 4        0                  0                 0     0     0              0
    ## 5        0                  0                 0     1     1              0
    ## 6        0                  0                 0     0     0              0
    ##   SNOW SNOWY_MOUNTAIN SPLIT_FRAME STEVE_ROSS STRUCTURE SUN TOMB_FRAME TREE
    ## 1    0              0           0          0         0   0          0    1
    ## 2    1              1           0          0         0   0          0    1
    ## 3    0              0           0          0         1   1          0    1
    ## 4    0              1           0          0         0   0          0    1
    ## 5    0              0           0          0         0   0          0    1
    ## 6    1              1           0          0         1   0          0    1
    ##   TREES TRIPLE_FRAME WATERFALL WAVES WINDMILL WINDOW_FRAME WINTER
    ## 1     1            0         0     0        0            0      0
    ## 2     1            0         0     0        0            0      1
    ## 3     1            0         0     0        0            0      1
    ## 4     1            0         0     0        0            0      0
    ## 5     1            0         0     0        0            0      0
    ## 6     1            0         0     0        0            0      1
    ##   WOOD_FRAMED
    ## 1           0
    ## 2           0
    ## 3           0
    ## 4           0
    ## 5           0
    ## 6           0

It should be clear that what you have in each column is a logical (boolean) 0-1 value. This will come in handy :)

1.  How many episodes were aired? Save to n\_episodes variable.

``` r
n_episodes <- nrow(df_bob)
n_episodes
```

    ## [1] 403

1.  What percent if BOB's paintings have more than one TREE (column TREES)? How many take place in Winter?

``` r
# Your code
df_bob$TREES
```

    ##   [1] 1 1 1 1 1 1 1 1 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0 1
    ##  [36] 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0 1 1 1 1 1 0 1 1 0 0 1 0 1 1 1 1 1 1
    ##  [71] 1 1 1 1 0 0 1 1 0 1 1 1 0 1 1 1 1 1 1 0 1 1 1 1 1 1 1 1 1 1 0 1 0 1 1
    ## [106] 0 1 1 1 0 1 1 1 0 1 0 1 1 1 1 1 0 1 1 1 1 0 1 1 1 1 1 1 1 1 1 1 1 1 0
    ## [141] 1 1 1 0 1 1 1 0 1 1 1 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1
    ## [176] 0 1 1 0 1 1 1 1 1 1 0 1 0 1 1 1 1 1 1 1 1 1 1 1 1 0 1 0 1 1 1 0 1 1 0
    ## [211] 1 0 0 1 1 1 1 0 1 1 1 1 1 1 1 1 1 1 1 0 1 1 0 1 1 1 1 1 1 1 1 1 0 1 1
    ## [246] 1 1 1 1 1 1 1 0 1 0 1 1 1 1 1 1 1 1 1 1 1 1 0 1 1 0 1 0 1 1 1 1 0 1 1
    ## [281] 1 1 1 0 1 1 1 1 0 1 1 1 1 0 1 1 1 0 0 1 1 1 1 1 1 1 1 1 0 1 1 1 1 1 1
    ## [316] 1 1 1 1 0 1 0 1 0 0 1 1 1 1 1 1 1 1 1 0 0 1 1 1 1 1 1 1 1 1 1 0 1 1 1
    ## [351] 1 1 1 1 1 0 1 1 1 1 1 0 1 1 1 1 1 1 0 1 1 1 0 0 1 1 1 0 0 1 1 1 1 1 1
    ## [386] 1 0 1 1 1 1 1 1 1 1 1 1 1 1 0 1 1 1

``` r
# sum(df_bob$TREES)/n_episodes
# sum(df_bob$WINTER)/n_episodes
```

1.  How many episodes have more than one trees AND take place in winter?

``` r
# Your code
nrow(df_bob[df_bob$TREES == 1 & df_bob$WINTER == 1, ])/n_episodes
```

    ## [1] 0.1588089

1.  Create a new column called N\_THEMES that sums how many different themes are in a single image. Take look at ?rowSums function.

``` r
# Your code
df_bob$N_THEMES = rowSums(df_bob[, c(3:69)])
summary(df_bob$N_THEMES)
```

    ##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
    ##   0.000   6.000   8.000   7.993  10.000  15.000

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
