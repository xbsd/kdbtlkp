.libPaths("/usr/lib64/R/library")
library(shiny)
library(shinydashboard)
library(data.table)
library(DT)


#dir <- "/srv/shiny-server/cms/raj_tlkp"
dir <- "~/r/kdbtlkp/"
hostname <- "localhost"
port <- 5000

setwd(dir)

source(paste0(dir,"qserver.R"))
h<-open_connection(hostname,port)

tableList <- execute(h,"tabs")

if (length(tableList)==0){
  print (paste0("No Tables Found, Please check KDB+ Session on Port ",as.character(port)))
  stopApp("No Tables Found")
}

tcols <- execute(h,paste0("cols each ",paste0("`",tableList,collapse="")))

if (length(tableList)==1) {
  tcols <- setNames(list(tcols), list(tableList))
} else {
  tcols <- setNames(tcols, tableList)
}



server <- function(input, output,session) {

  output$selectTable <- renderUI({
    selectInput("tableName","Select Dataset" , c(tableList), selected = "t1", 
    multiple = FALSE, selectize = TRUE)})
  
  getTab <- eventReactive(input$tableName, {
  tname <- input$tableName
  
  # Create a generic placeholder table
  dfcols   <- eval(parse(text=paste0("tcols$",tname)))
  dftext   <- paste0("data.frame(",paste0(dfcols,"=character()",collapse=","),")")
  df       <- eval(parse(text=dftext))
  
  print(tname)
  
  tnamejs <- paste0("function (d) { d.table = \"",tname,"\" }")
  colstr = paste0("{column_number : ",seq(0,ncol(df)-1),", filter_type : 'text'}",collapse=",")
  st = paste0("yadcf.init(table,[",colstr,"])")

  dt <- datatable(df, rownames = FALSE,  options = list(
    bSortClasses = FALSE,
    language.thousands=",",
    columnDefs = list(list(searchable = TRUE)),
    search = list(regex=TRUE, search_prefix='^'),
    searching = TRUE,
    ajax = list(
      serverSide = TRUE, processing = TRUE,
      #url = 'http://datatables.net/examples/server_side/scripts/jsonp.php',
      url = paste0("http://",hostname,":",as.character(port),"/"),
      dataType = 'jsonp',
      type = "POST",
      data = JS(tnamejs)
    )),
      callback = JS(st))
#  print (dt)
  dt
  })
  
  output$table <- renderDataTable(getTab())

}
