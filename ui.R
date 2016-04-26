#KDB+ Table Lookup
library(shiny)
library(shinydashboard)

## Sidebar content
sidebar <- dashboardSidebar(
  sidebarMenu(
    uiOutput("selectTable")
  )
)

## Body content
body <- dashboardBody(
  
  # Include all CSS and JS Files
  includeCSS   ("www/raj.css"),
  includeCSS   ("www/jquery.dataTables.yadcf.css"),
  includeCSS   ("www/dataTables.jqueryui.css"),
  includeScript("www/jquery-ui.1.9.0.js"),
  includeScript("www/jquery.dataTables.yadcf.js"),
  
  dataTableOutput('table'))



dashboardPage(skin="blue",
  dashboardHeader(title = "IMS Table Viewer"),
  sidebar,
  body,
  title = "IMS Table Viewer"
)



  