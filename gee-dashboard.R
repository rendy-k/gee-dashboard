library(plotly)
library(readr)
library(shiny)
library(shinydashboard)
library(leaflet)
library(raster)


### UI ----
ui <- dashboardPage(
  skin="green",
  dashboardHeader(title="Forest Dashboard"),
  dashboardSidebar(
    menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
    sliderInput(
      "year_range", "Year range:",min = 2001, max = 2022, value = c(2001, 2022)
    )
  ),
  dashboardBody(
    # First tab content
    tabItem(
      tabName = "dashboard",
      h2("Forest Cover Loss and Emissions"),
      fluidRow(
        column(width = 5,
           box(
             title = "Summary", width = NULL, status = "primary",
             solidHeader = TRUE, fill = TRUE,
             textOutput("stock"),
             textOutput("emission"),
             textOutput("deforestation")
           ),
           box(
             title = "Deforestation rate", width = NULL, solidHeader = TRUE,
             status = "primary",
             plotlyOutput("deforestation_rate", height=200)
           )
        ),

        # Raster map
        box(
          title = "Map", status = "primary", solidHeader = TRUE, fill = TRUE,
          leafletOutput("mymap"), width=7
        )
      ),
    )
  )
)


### Backend ----
server <- function(input, output, session) {
  # Raster map
  # Load raster
  emission <- raster("data/peat_carbon_emission_Gg.tif")
  carbon <- raster("data/carbon_t_per_ha.tif")
  lossyear <- raster("data/lossyear.tif")
  # Palette
  pal_emission <- colorNumeric("viridis", values(emission), na.color="transparent")
  pal_carbon <- colorNumeric("YlOrBr", values(carbon), na.color="transparent")
  pal_lossyear <- colorNumeric("magma", values(lossyear), na.color="transparent")
  
  # Leaflet
  output$mymap <- renderLeaflet({
    leaflet() %>% addTiles() %>%
      setView(lng=103.26, lat=-2.045, zoom=8) %>%
      addRasterImage(emission, colors=pal_emission, group="emission", layerId = "values") %>%
      addRasterImage(carbon, colors=pal_carbon, group="carbon") %>%
      addRasterImage(lossyear, colors=pal_lossyear, group="lossyear") %>%
      addLegend(pal=pal_emission, values=values(emission), title="Emission Gg") %>%
      addLegend(pal=pal_carbon, values=values(carbon), title="Carbon t/ha") %>%
      addLegend(pal=pal_lossyear, values=values(lossyear), title="Loss year", position='topleft') %>%
      addLayersControl(
        position='bottomright',
        overlayGroups=c("emission", "carbon", "lossyear")
      ) %>%
      hideGroup(c("carbon", "lossyear"))
  })
  
  # Deforestation chart
  deforestation_data <- read_csv('data/deforestation_rate.csv', show_col_types = FALSE)
  output$deforestation_rate <- renderPlotly({
    fig <- plot_ly(
      data = deforestation_data,
      x = ~year,
      y = ~percentage,
      text = ~remaining_ha,
      hovertemplate = paste(
        'Year: %{x}\n',
        'Remaining area: %{text} ha\n',
        'Remaining area percentage: %{y} %'),
      type = 'scatter', mode='lines+markers'
    )
  })
  
  # Carbon stock
  output$stock <- renderText({
    paste("Carbon Stock average: 112 ± 57 t/ha")
  })
  
  # Peat emission
  output$emission <- renderText({
    paste("Peat emission average: 0.32 ± 0.28 Gg")
  })
  
  
  
  output$deforestation <- renderText({
    # Year range
    deforestation_in_year = round(
      sum(
        deforestation_data[
          (
            (deforestation_data["year"]>=input$year_range[1]) & (deforestation_data["year"]<=input$year_range[2])
          ),
          "deforestation_ha"
        ]
      )/ (input$year_range[2] - input$year_range[1] + 1),
      0
    )
    deforestation_in_year = format(deforestation_in_year, big.mark=",", scientific=FALSE)
    
    # Deforestation
    paste("Deforestation rate in year ", input$year_range[1], " - ", input$year_range[2], ": ", deforestation_in_year, " ha/yr")
  })
  
}


# Run app
shinyApp(ui, server)