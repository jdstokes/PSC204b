#Converts homework to markdown using https://github.com/benbalter/word-to-markdown/

ConvertWord2Md <- function(dir,filen){
  word.name <- filen
  word.path <- paste(dir,word.name,sep="")
  
  md.name <- strsplit(filen,".docx")
  md.format <- ".md"
  md.path <- paste(dir,md.name,md.format,sep="")
  
  
  command <- paste("w2m",word.path,">",md.path)
  
  print(command)
  system(command)
}

dir <- "/Users/jdstokes/repos/204b/homework/word/"

word.list <- list.files(path=dir,pattern=".docx")
for (i in word.list){
  print(i)
  ConvertWord2Md(dir,i)
}




