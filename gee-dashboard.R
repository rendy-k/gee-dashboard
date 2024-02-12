library(shiny)
library(shinydashboard)
library(leaflet)
library(raster)


### UI ----
ui <- dashboardPage(
  skin="green",
  dashboardHeader(title="Forest Dashboard"),
  dashboardSidebar(
    menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard"))
  ),
  dashboardBody(
    # First tab content
    tabItem(
      tabName = "dashboard",
      h2("Forest Cover Loss and Emissions"),
      fluidRow(
        box(plotOutput("plot1", height=100), width=4),
        
        # Raster map
        box(
          leafletOutput("mymap"), width=8
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
  treecover_2000 <- raster("data/treecover_2000.tif")
  # Palette
  pal_emission <- colorNumeric("Reds", values(emission), na.color="transparent")
  pal_carbon <- colorNumeric("YlOrBr", values(carbon), na.color="transparent")
  pal_lossyear <- colorNumeric("Greens", values(lossyear), na.color="transparent")
  
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
}


# Run app
shinyApp(ui, server)