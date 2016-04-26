.libPaths("/usr/lib64/R/library")
library(shiny)
library(shinydashboard)
library(data.table)
library(DT)


dir <- "/srv/shiny-server/cms/raj_tlkp"
setwd(dir)

source("/srv/shiny-server/cms/raj_tlkp/qserver.R")
h<-open_connection("dnbig001",5000)

tableList <- c("Plan","Product")
tableList <- c("t","t1","Product","Prescriber")
tcols <- execute(h,paste0("cols each ",paste0("`",tableList,collapse="")))
tcols <- setNames(tcols, tableList)

employee = data.frame(
  `First name` = character(), `Last name` = character(), Position = character(),
  Office = character(),
  check.names = FALSE
)

t1 = data.frame(`First name` = character(), `Last name` = character(),check.names = FALSE)

server <- function(input, output,session) {

  output$selectTable <- renderUI({
    selectInput("tableName","Select Dataset" , tableList, selected = "t1", 
    multiple = FALSE, selectize = TRUE)})
  
  z <- eventReactive(input$tableName, {
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
      url = "http://dnbig001.us01.apmn.org:5000/",
      dataType = 'jsonp',
      type = "POST",
      data = JS(tnamejs)
    )),
      callback = JS(st))
#  print (dt)
  dt
  })
  
  output$table <- renderDataTable(z())


}
