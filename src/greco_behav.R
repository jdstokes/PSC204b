# Collection functions for extracting and manipulating
# data from Greco, a virtual reality navigation dataset

# Jared Stokes stokesjd@gmail.com

# Directory information ----
dir_nav <- '/Volumes/jdstokes/Studies/greco/data/behav/behav_scan';
dir_map <- '/Volumes/jdstokes/Studies/greco/data/behav/map_draw'
dir_tables <- '/Volumes/jdstokes/Studies/greco/analysis/tables'

# Get subject list --------
subj_list <- list.files(dir)

# Load navigation task subject data
load_data_nav <- function(subj){
  path <- file.path(dir_nav,subj,paste(subj,'.txt',sep=''))
  return(read.table(path, sep = '\t', header = T))
}

# Load map task subject data
load_data_map <- function(subj){
  path <- file.path(dir_map,paste(subj,'_MD_output.csv',sep=''))
  return(read.table(path, sep = '\t', header = T))
}

# Load navigation performance data
load_table_nav <- function(subj){
  path <- file.path(dir_tables,'greco_tables_behav.csv')
  return(read.table(path, sep = '\t', header = T))
}

# Load map drawing performance data
load_table_discrim <- function(){
  path <- file.path(dir_tables,'behav_discrim_table.csv')
  return(read.table(path, sep = ',', header = T))
}