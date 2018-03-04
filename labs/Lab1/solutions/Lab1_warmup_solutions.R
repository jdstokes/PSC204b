# 1
#☺ There are two approaches. One is load the data to your HDD and use read.csv
df_bob <- read.csv("c:/Users/hejtm/Downloads/elements-by-episode.csv", header = T)
nrow(df_bob)

#second is more hacky and overall better, just copy paste this
df_bob <- read.csv("https://raw.githubusercontent.com/fivethirtyeight/data/master/bob-ross/elements-by-episode.csv", header = T)
nrow(df_bob)
ncol(df_bob)

# 2
n_episodes <- nrow(df_bob)
n_episodes

# 3
sum(df_bob$TREES)/n_episodes
sum(df_bob$WINTER)/n_episodes

# 4
nrow(df_bob[df_bob$TREES == 1 & df_bob$WINTER == 1, ])/n_episodes

# 5
#F First two columns are strings. So we want to add only numbers in the third to the last one c(3:70)
df_bob$N_THEMES = rowSums(df_bob[, c(3:70)])
summary(df_bob$N_THEMES)

# 6
# Lets find the max 
max_themes <- max(df_bob$N_THEMES)
df_theme_overload <- df_bob[df_bob$N_THEMES == max_themes, ]
df_theme_overload$TITLE


# 7
mean(df_bob$N_THEMES)
median(df_bob$N_THEMES)

# 8
# We again need to sum only numeric values, so skipping first two
theme_sums <- colSums(df_bob[,c(3:69)])
df_themes <- data.frame(theme = colnames(df_bob[, c(3:69)]), n = as.vector(theme_sums))
head(df_themes,3)

# 9
df_themes$percent <- round(df_themes$n*100/n_episodes)
df_themes <- df_themes[order(-df_themes$n),]
df_top_themes <- df_themes[1:10, ]
barplot(df_top_themes$percent, names.arg = df_top_themes$theme, 
        xlab="Number of occurences", ylab = "Theme name", cex.names=0.5)

# 10
# creating a vector saying if the cell is 1 or not
selector <- df_bob[1, ] == 1
# if you take a looks 
colnames(df_bob)[as.vector(selector)]