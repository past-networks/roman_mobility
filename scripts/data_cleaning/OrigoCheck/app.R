library(shiny)
library(leaflet)
library(dplyr)
library(sf)

# Load data
origo_simple <- readRDS("../../data/origo_simple.RData")
str(origo_simple)

ui <- fluidPage(
  titlePanel("Inscription Origo Validation"),
  
  sidebarLayout(
    sidebarPanel(
      width = 3,
      selectInput("inscription", "Select Inscription:", 
                  choices = NULL),
      uiOutput("inscription_info"),
      hr(),
      h4("Origo Assignment"),
      selectInput("origo_pleiades_id", "Pleiades Place:", 
                  choices = NULL),
      selectInput("origo_certainty", "Certainty:",
                  choices = c("certain", "probable", "uncertain"),
                  selected = "certain"),
      actionButton("confirm", "Confirm Assignment", 
                   class = "btn-success"),
      actionButton("flag", "Flag for Review", 
                   class = "btn-warning"),
      actionButton("skip", "Skip"),
      hr(),
      downloadButton("export", "Export Results")
    ),
    
    mainPanel(
      width = 9,
      leafletOutput("map", height = "500px"),
      hr(),
      h4("Inscription Text"),
      wellPanel(
        style = "max-height: 200px; overflow-y: auto;",
        verbatimTextOutput("inscription_text")
      ),
      hr(),
      verbatimTextOutput("status")
    )
  )
)

server <- function(input, output, session) {
  
  # Use origo_simple data
  inscriptions <- reactive({
    origo_simple
  })
  
  pleiades_places <- reactive({
    # Extract unique places from origo_simple
    origo_simple %>%
      filter(!is.na(origo_pleiades_id)) %>%
      select(pleiades_id = origo_pleiades_id, 
             pleiades_name = origo_pleiades_name, 
             geometry = origo_geometry) %>%
      distinct()
  })
  
  # Extract coordinates from geometry
  get_coords <- function(geometry) {
    if (is.na(geometry) || geometry == "" || is.null(geometry)) {
      return(data.frame(lon = NA, lat = NA))
    }
    
    tryCatch({
      coords <- st_coordinates(st_as_sfc(geometry, crs = 4326))
      data.frame(lon = coords[1], lat = coords[2])
    }, error = function(e) {
      data.frame(lon = NA, lat = NA)
    })
  }
  
  # Track validation results
  results <- reactiveVal(data.frame(
    inscription_id = character(),
    origo = character(),
    origo_certainty = character(),
    origo_pleiades_id = character(),
    origo_pleiades_name = character(),
    origo_geometry = character(),
    status = character(),
    timestamp = character(),
    stringsAsFactors = FALSE
  ))
  
  # Update inscription choices
  observe({
    req(nrow(inscriptions()) > 0)
    updateSelectInput(
      session, 
      "inscription",
      choices = setNames(inscriptions()$id, inscriptions()$id)
    )
  })
  
  # Render base map
  output$map <- renderLeaflet({
    leaflet() %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      setView(lng = 15, lat = 42, zoom = 5)
  })
  
  # Update map when inscription selected
  observeEvent(input$inscription, {
    req(input$inscription)
    
    current_insc <- inscriptions() %>% 
      filter(id == input$inscription)
    
    # Get inscription coordinates
    insc_coords <- get_coords(current_insc$origo_geometry)
    
    # Find nearby Pleiades places (if inscription has geometry)
    if (!is.na(insc_coords$lon)) {
      # Add coordinates to places
      places_data <- pleiades_places()
      
      if (nrow(places_data) > 0) {
        coords_df <- do.call(rbind, lapply(places_data$geometry, get_coords))
        
        places_with_coords <- cbind(places_data, coords_df) %>%
          filter(!is.na(lon), !is.na(lat))
        
        # Calculate distances and filter
        nearby_places <- places_with_coords %>%
          mutate(
            dist = sqrt((lon - insc_coords$lon)^2 + (lat - insc_coords$lat)^2)
          ) %>%
          filter(dist < 1) %>%
          arrange(dist)
        
        if (nrow(nearby_places) > 0) {
          leafletProxy("map") %>%
            clearMarkers() %>%
            addMarkers(
              lng = insc_coords$lon, 
              lat = insc_coords$lat,
              icon = makeAwesomeIcon(
                icon = "info",
                markerColor = "red",
                library = "fa"
              ),
              popup = paste0("<b>Inscription:</b> ", current_insc$id)
            ) %>%
            addCircleMarkers(
              data = nearby_places,
              lng = ~lon, 
              lat = ~lat,
              radius = 8,
              color = "blue",
              fillOpacity = 0.6,
              popup = ~paste0("<b>", pleiades_name, "</b><br>", "ID: ", pleiades_id),
              layerId = ~pleiades_id
            ) %>%
            fitBounds(
              lng1 = min(c(insc_coords$lon, nearby_places$lon), na.rm = TRUE) - 0.5,
              lat1 = min(c(insc_coords$lat, nearby_places$lat), na.rm = TRUE) - 0.5,
              lng2 = max(c(insc_coords$lon, nearby_places$lon), na.rm = TRUE) + 0.5,
              lat2 = max(c(insc_coords$lat, nearby_places$lat), na.rm = TRUE) + 0.5
            )
          
          updateSelectInput(
            session, 
            "origo_pleiades_id",
            choices = c(
              "" = "", 
              setNames(
                nearby_places$pleiades_id,
                paste0(nearby_places$pleiades_name, " (", nearby_places$pleiades_id, ")")
              )
            ),
            selected = current_insc$origo_pleiades_id
          )
        } else {
          # No nearby places found
          leafletProxy("map") %>%
            clearMarkers() %>%
            addMarkers(
              lng = insc_coords$lon, 
              lat = insc_coords$lat,
              popup = paste0("<b>Inscription:</b> ", current_insc$id)
            )
          
          updateSelectInput(
            session, 
            "origo_pleiades_id",
            choices = c("" = ""),
            selected = ""
          )
        }
      }
    } else {
      # No geometry - just list all places
      all_places <- pleiades_places()
      
      if (nrow(all_places) > 0) {
        updateSelectInput(
          session, 
          "origo_pleiades_id",
          choices = c(
            "" = "", 
            setNames(
              all_places$pleiades_id,
              paste0(all_places$pleiades_name, " (", all_places$pleiades_id, ")")
            )
          ),
          selected = current_insc$origo_pleiades_id
        )
      }
      
      leafletProxy("map") %>%
        clearMarkers()
    }
    
    # Set certainty
    if (!is.na(current_insc$origo_certainty) && current_insc$origo_certainty != "") {
      updateSelectInput(
        session, 
        "origo_certainty",
        selected = current_insc$origo_certainty
      )
    }
  })
  
  # Display inscription details
  output$inscription_info <- renderUI({
    req(input$inscription)
    current <- inscriptions() %>% filter(id == input$inscription)
    
    tagList(
      h4("Current Values"),
      p(strong("ID:"), current$id),
      p(strong("Origo:"), 
        ifelse(is.na(current$origo) || current$origo == "", "—", current$origo)),
      p(strong("Certainty:"), 
        ifelse(is.na(current$origo_certainty) || current$origo_certainty == "", "—", current$origo_certainty)),
      p(strong("Pleiades ID:"), 
        ifelse(is.na(current$origo_pleiades_id) || current$origo_pleiades_id == "", "—", current$origo_pleiades_id)),
      p(strong("Pleiades Name:"), 
        ifelse(is.na(current$origo_pleiades_name) || current$origo_pleiades_name == "", "—", current$origo_pleiades_name))
    )
  })
  
  # Display inscription text
  output$inscription_text <- renderText({
    req(input$inscription)
    current <- inscriptions() %>% filter(id == input$inscription)
    
    if (is.na(current$inscription_text) || current$inscription_text == "") {
      "[No text available]"
    } else {
      current$inscription_text
    }
  })
  
  # Handle confirmation
  observeEvent(input$confirm, {
    req(input$inscription, input$origo_pleiades_id, input$origo_certainty)
    
    selected_place <- pleiades_places() %>%
      filter(pleiades_id == input$origo_pleiades_id)
    
    if (nrow(selected_place) > 0) {
      new_result <- data.frame(
        inscription_id = input$inscription,
        origo = selected_place$pleiades_name[1],
        origo_certainty = input$origo_certainty,
        origo_pleiades_id = input$origo_pleiades_id,
        origo_pleiades_name = selected_place$pleiades_name[1],
        origo_geometry = selected_place$geometry[1],
        status = "confirmed",
        timestamp = as.character(Sys.time()),
        stringsAsFactors = FALSE
      )
      
      results(rbind(results(), new_result))
      
      # Move to next inscription
      advance_inscription()
    }
  })
  
  # Handle flagging
  observeEvent(input$flag, {
    req(input$inscription)
    
    new_result <- data.frame(
      inscription_id = input$inscription,
      origo = NA,
      origo_certainty = NA,
      origo_pleiades_id = NA,
      origo_pleiades_name = NA,
      origo_geometry = NA,
      status = "flagged",
      timestamp = as.character(Sys.time()),
      stringsAsFactors = FALSE
    )
    
    results(rbind(results(), new_result))
    advance_inscription()
  })
  
  # Handle skip
  observeEvent(input$skip, {
    advance_inscription()
  })
  
  # Function to advance to next inscription
  advance_inscription <- function() {
    current_idx <- which(inscriptions()$id == input$inscription)
    if (length(current_idx) > 0 && current_idx < nrow(inscriptions())) {
      updateSelectInput(
        session, 
        "inscription",
        selected = inscriptions()$id[current_idx + 1]
      )
    }
  }
  
  # Export results
  output$export <- downloadHandler(
    filename = function() {
      paste0("origo_validation_", Sys.Date(), ".csv")
    },
    content = function(file) {
      write.csv(results(), file, row.names = FALSE)
    }
  )
  
  # Status display
  output$status <- renderText({
    sprintf(
      "Validated: %d/%d inscriptions\nConfirmed: %d | Flagged: %d", 
      nrow(results()), 
      nrow(inscriptions()),
      sum(results()$status == "confirmed", na.rm = TRUE),
      sum(results()$status == "flagged", na.rm = TRUE)
    )
  })
}

shinyApp(ui, server)