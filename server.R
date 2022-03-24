library(shiny)
library(shinydashboard)
library(DT)
library(shinyWidgets)
library(dplyr)
library(googlesheets4)
library(plotly)
library(zoo)
library(leaflet)


# Define server logic required to draw a histogram
server <- function(input, output, session) {
    
    # Get data from a googlesheet -----
    # options(gargle_oauth_cache = ".cache") # designate project-specific cache
    # gargle::gargle_oauth_cache() # check the value of the option
    # googlesheets4::gs4_auth()# trigger auth on purpose to store a token in the specified cache
    cache_directory <- ".cache/" # can add to config file
    # list.files(cache_directory) # see your token file in the cache
    # googlesheets4::gs4_deauth() # de auth
    
    
    googlesheets4::gs4_auth(email = "lic.market.insights@gmail.com", cache = cache_directory)
    link <-  "https://docs.google.com/spreadsheets/d/1prwjGx-XBc2ynq_lAVklMrXbjSMMEl3Lx5-5S9fZBTU/edit#gid=192150056"
    gdt <- range_read(ss = link, sheet="GDT Results")
    location <- range_read(ss =link, sheet="Locations")
    # other <- range_read(ss =link, sheet="Other MP")
    # fonterra <- range_read(ss =link, sheet="Fonterra MP")
    
    # Clean data -----
    str(gdt)
    gdt <- gdt %>% distinct() %>% mutate(Date = as.Date(Date)) %>% arrange(Date)
    gdt <- gdt %>% mutate(Month = as.numeric(format(Date, format = "%m"))
                          , Year = as.numeric(format(Date, format = "%Y"))
                          , ID = row_number())
    gdt <- gdt %>% mutate(Date1 = format(as.Date(Date), format = "%d/%m/%Y"))
    gdt$Date1 <- factor(gdt$Date1, levels = c(as.character(gdt$Date1))) # this is to sort category in plotly barchart later
    
    
    # str(fonterra)
    # fonterra <- fonterra %>% distinct() 
    # fonterra$Date <- as.Date(fonterra$Date)
    # fonterra <- fonterra %>% filter(!is.na(Date)) %>% arrange(Date)
    # fonterra <- fonterra %>% mutate(Month = as.numeric(format(Date, format = "%m"))
    #                                 , Year = as.numeric(format(Date, format = "%Y"))
    #                                 , Date =format(Date, format = "%d/%m/%Y"))
    # 
    # other <- other %>% distinct() %>% mutate(Update = format(as.Date(Update), format = "%d/%m/%Y")) %>% arrange(Provider)
    
    # 1. GDT Results Tab ----------------------------------------------------------
    # The latest result
    
    day <- format(gdt$Date[nrow(gdt)], format = "%d/%m/%Y")
    texttoshow <- paste0("The latest GDT result on ", day, ":")
    percent <- paste0(gdt$`Change (%)`[nrow(gdt)], "%")
    output$text1 <- renderText(texttoshow)
    
    output$infoBox1 <- renderInfoBox({
        color <- 'green'
        if(percent < 0) color <- 'red'
        infoBox(value = percent, title = "", color = color)
    })
    # GDT Result tab
    output$year_slider <- renderUI({
        max_year <- max(gdt$Year)
        min_year <- min(gdt$Year)
        
        sliderInput("yearSlider", "Year Slider", min_year, max_year
                    , value = c(max_year-1, max_year), sep="")
    })
    
    output$event_no <- renderUI({
        numericInput("eventno", "Number of latest events:", 26, min = 1, max = nrow(gdt))
    })
    
    
    reactive_gdt <- reactive({
        req(input$yearSlider, input$eventno)
        gdt %>% filter(Year >= input$yearSlider[1]
                   , Year <= input$yearSlider[2]) %>%
            arrange(ID) %>%
            select(Date1, `Change (%)`) %>% slice_tail(n=input$eventno)

    })
    
    # Interactive GDT barchart
    output$gdt_bar1 <- renderPlotly({
        reactive_gdt() %>% plot_ly(x=~Date1, y=~`Change (%)`, type = 'bar', showlegend=F
                                   ,color = ~`Change (%)` < 0, colors = c("#28a745", "#dc3545")
                                   ,name = ~ifelse(`Change (%)` < 0, yes = "Down", no = "Up")
                                   ,text=~`Change (%)`, textposition ="top") %>% 
                                     layout(xaxis = list(type = "category", title = "Date"))
                                   })
    



    
    # Interactive GDT Table 
    output$gdt_table <- renderDT(
        
        datatable(reactive_gdt(), rownames = F, options = list(paging=F
                                                    ,scrollY = "30vh"
                                                    ,scrollX="100%"))
    )
    
    
    # 2. Fonterra Tab ----------------------------------------------------------
    
    output$mymap <- renderLeaflet({
    logo <- makeIcon(
        iconUrl = "https://seeklogo.com/images/F/fonterra-logo-109C40CB48-seeklogo.com.png",
        iconWidth = 31*215/230, iconHeight = 25,
        iconAnchorX = 31*215/230/2, iconAnchorY = 16
    )
   location %>% 
        leaflet() %>%
        addTiles() %>%
        addMarkers(icon =logo, popup = ~Site)
    })
    
}
