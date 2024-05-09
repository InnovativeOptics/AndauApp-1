#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(tidyverse)

# Load Andau loupe data
andau_data <- readxl::read_excel("andau_loupe_data.xlsx")

# Load dental data
dental_data <- readxl::read_excel("Dental_data.xlsx")%>%
  filter(`Laser Mfg` != "") %>%
  mutate(VLT = scales::percent(as.numeric(VLT)))


shinyServer(function(input, output, session) {
  observeEvent(input$mfg,{
    # filter dental data to select mfg
    mfg_filtered_dental_data <- dental_data %>% 
      filter(`Laser Mfg` == input$mfg)
    # update select input - laser model
    updateSelectInput(inputId = "mod",
                      choices = sort(mfg_filtered_dental_data$`Laser Model`))
  })

  
  loupe_insert <- eventReactive(input$loupestyle,{
    andau_data %>% 
      filter(`Andau Frame` == input$loupestyle)
  })
  selected_data <- eventReactive(input$mod,{
    req(input$mfg)
    dental_data %>% 
      filter(`Laser Mfg` == input$mfg,
             `Laser Model` == input$mod)
  })
  user_info <- eventReactive(input$run,{
    tibble(
    "Andau Loupe Style" = loupe_insert()$`Andau Frame`,
    "Laser Information" = glue::glue_safe(selected_data()$`Laser Mfg`, " ", selected_data()$`Laser Model`),
    "Laser Specifications" = selected_data()$Wavelengths)
  })
  output$userInfo <- renderTable(bordered = T,
                                  align = "l",
                                  striped=T,
                                  {
                                    user_info()
                                  })
  table_info <- eventReactive(input$run,{
    tibble("INVO Part Number" = if_else(selected_data()$`Eyewear Lens Compatible` == "GP30",
                                                     glue::glue_safe(loupe_insert()$`Innovative Optics Insert`,"." , selected_data()$`Eyewear Lens Compatible`),
                                                     glue::glue_safe(loupe_insert()$`Innovative Optics Insert`,"." , selected_data()$`Eyewear Lens Compatible`, ".2B")),
           "Optical Density Specifications" = selected_data()$`Optical Density`,
           "Visible Light Transmission" = selected_data()$VLT)
  })
  
  output$tableInfo <- renderTable(bordered = T,
                                  align = "l",
                                  striped=T,
                                  height="100%",
                                  {
    table_info()
  })
  rec1_table <- eventReactive(input$run,{
    tibble("INVO Part Number" = selected_data()$`Rec1`)
  })
  output$tableRec1 <- renderTable(bordered = T,
                                  align = "l",
                                  striped=T,
                                  {
                                    rec1_table()
                                  })
  rec2_table <- eventReactive(input$run,{
    tibble("INVO Part Number" = selected_data()$`Rec2`)
  })
  output$tableRec2 <- renderTable(bordered = T,
                                  align = "l",
                                  striped=T,
                                  {
                                    rec2_table()
                                  })
  rec3_table <- eventReactive(input$run,{
    tibble("INVO Part Number" = selected_data()$`Rec3`)
  })
  output$tableRec3 <- renderTable(bordered = T,
                                  align = "l",
                                  striped=T,
                                  {
                                    rec3_table()
                                  })
  image_location <- eventReactive(input$run,{
    c(if_else(input$loupestyle == "Bolle" | input$loupestyle == "Jazz", 
            glue::glue_safe("www/", input$loupestyle, "/", selected_data()$`Eyewear Lens Compatible`, ".jpg"),
            if_else(input$loupestyle == "MOS" & selected_data()$`Eyewear Lens Compatible` == "Pi1",
            glue::glue_safe("www/", input$loupestyle, "/", selected_data()$`Eyewear Lens Compatible`, ".jpg"),        
            glue::glue_safe("www/", input$loupestyle, "/", selected_data()$`Eyewear Lens Compatible`, ".JPG"))),
            if_else(selected_data()$`Eyewear Lens Compatible` == "Pi19",
                    glue::glue_safe("www/recs/", selected_data()$`Rec1`, ".jpeg"),
                    glue::glue_safe("www/recs/", selected_data()$`Rec1`, ".jpg")
                    ),
            if_else(selected_data()$`Eyewear Lens Compatible` == "Pi19",
                    glue::glue_safe("www/recs/", selected_data()$`Rec1`, ".jpeg"),
                    glue::glue_safe("www/recs/", selected_data()$`Rec2`, ".jpg")
                    ),
            glue::glue_safe("www/recs/", selected_data()$`Rec3`, ".jpg"))
  })
  output$productImage <- renderImage({
    req(input$loupestyle)
    req(input$mfg)
    req(input$mod)
    list(src = image_location()[[1]],
         width = "500px",
         contentType = "image/jpeg")
  }
  ,deleteFile = FALSE)
  
  output$rec1 <- renderImage({
    req(input$loupestyle)
    req(input$mfg)
    req(input$mod)
    list(src = image_location()[[2]],
         height = "300px",
         contentType = "image/jpeg")
  }
  ,deleteFile = FALSE)
  
  output$rec2 <- renderImage({
    req(input$loupestyle)
    req(input$mfg)
    req(input$mod)
    list(src = image_location()[[3]],
         height = "300px",
         contentType = "image/jpeg")
  }
  ,deleteFile = FALSE)
  
  output$rec3 <- renderImage({
    req(input$loupestyle)
    req(input$mfg)
    req(input$mod)
    list(src = image_location()[[4]],
         height = "300px",
         contentType = "image/jpeg")
  }
  ,deleteFile = FALSE)

})
# # Define server logic required to draw a histogram
# shinyServer(function(input, output, session) {
#   # filter dental data when manufacturer was selected
#   dental_data_new <- eventReactive(input$dentman,{
#     dental_data %>%
#       filter(`Laser Mfg` == input$dentman)
#   })
#   # update choices in dental model based on input from manufacturer
#   observeEvent(dental_data_new(), {
#     choices <- unique(dental_data_new()$`Laser Model`)
#     updateSelectInput(inputId = "dentmod",
#                       choices = choices)
#   })
#   # filter dental data new when model is selected
#   dental_data_final <- eventReactive(input$dentmod,{
#     dental_data_new() %>% 
#       filter(`Laser Model` == input$dentmod) %>% 
#       select(`Eyewear Lens Compatible`) 
#   })
#   # output filtered dental data set
#   output$sugdent <- renderTable({
#     req(dental_data_final()) 
#     dent_od <- od_data %>%  
#       filter(Product == dental_data_final()[[1]])
#     tibble(andau_data_new(), 
#            dental_data_final(),
#            "Optical Density Specifications" = 
#              c(dent_od$`OD Specs`))
#   })  
#   # filter medical data when manufacturer was selected
#   medical_data_new <- eventReactive(input$medman,{
#     medical_data %>%
#       filter(`Laser Mfg` == input$medman) 
#   })
#   # update choices in dental model based on input from manufacturer
#   observeEvent(medical_data_new(), {
#     choices <- unique(medical_data_new()$`Laser Model`)
#     updateSelectInput(inputId = "medmod",
#                       choices = choices)
#   })
#   # filter dental data new when model is selected
#   medical_data_final <- eventReactive(input$medmod,{
#     medical_data_new() %>% 
#       filter(`Laser Model` == input$medmod) %>% 
#       select(`Eyewear Lens Compatible`) 
#   })
#   # output filtered dental data set
#   output$sugmed <- renderTable({
#     req(medical_data_new())
#     med_od <- od_data %>%  
#       filter(Product == medical_data_final()[[1]])
#     tibble(andau_data_new(), 
#            medical_data_final(),
#            "Optical Density Specifications" = med_od$`OD Specs`)
#   }) 
#   # filter Andau data based on frame style
#   andau_data_new <- eventReactive(input$frame,{
#     andau_data %>% 
#       filter(`Andau Frame` == input$frame)
#   })
#   # output text showing which insert fits frame
#   # output$suginsert <- renderTable({
#   #   req(input$frame)
#   #   andau_data_new()
#   # })
#   # sample image render
#   output$Loupe <- renderImage({
#     list(src = "Images/MOS/MOS-Andau.IVR.R.Pi1.2B.jpg",
#          height = "100%")
#   }, deleteFile = FALSE)
#   # return lens for category of laser
#   category_lens <- eventReactive(input$category,{
#     req(input$frame)
#     req(input$category)
#     andau_data_full %>% 
#       filter(`Andau Frame` == input$frame) %>% 
#       select(input$category)
#   })
#   # render table for category
#   output$suglensCategory <- renderTable({
#     req(input$category)
#     category_od <- od_data %>%  
#       filter(Product == category_lens()[[1]])
#     tibble(andau_data_new(), 
#            "Eyewear Lens Compatible" = category_lens()[1],
#            "Optical Density Specifications" = category_od$`OD Specs`)
#   })
# })
