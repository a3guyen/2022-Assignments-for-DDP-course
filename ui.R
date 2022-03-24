#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinydashboard)
library(DT)
library(shinyWidgets)
library(dplyr)
library(googlesheets4)
library(plotly)
library(leaflet)


# Define UI for application that draws a histogram
# Define UI for application that draws a histogram
ui <-  dashboardPage(
    dashboardHeader(
        title= "Milk Price Watch"
    ),
    dashboardSidebar( 
        sidebarMenu(
            menuItem(
                tabName="gdt"
                , text= "GDT Results"
            )
            ,menuItem(
                tabName="fonterra"
                , text= "Fonterra Site Locations"
            )
        )
    ),
    dashboardBody(
        includeCSS("www/style.css")
        , tabItems(
            tabItem(
                tabName='gdt'
                , fluidPage(
                    fluidRow(
                        box(width = 4, status = 'primary', title = textOutput("text1")
                              , chooseSliderSkin(skin = "Shiny", color = "blue")
                              , infoBoxOutput('infoBox1'))
                        , box(width = 4, status = 'primary'
                            , chooseSliderSkin(skin = "Shiny", color = "blue")
                            , uiOutput("year_slider"))
                        ,box(width = 4, status = 'primary'
                             , chooseSliderSkin(skin = "Shiny", color = "blue")
                             , uiOutput("event_no"))
                        
                    )
                   , fluidRow(
                       box(width = 12, status = 'primary', title= 'GDT Results' 
                              , plotlyOutput("gdt_bar1", height = "53vh"))
                    )
                    , fluidRow(
                        box(width = 4, status = 'primary', title= 'Data' 
                            , DTOutput('gdt_table'))
                    )
                )
            )
            ,tabItem(
                tabName = "fonterra"
                , fluidPage(
                    fluidRow(
                        box(width = 12, status = 'primary', title= 'Fonterra manufacturing sites' 
                            , leafletOutput("mymap", height = "53vh"))
                )
            )
      
            )

        )
))