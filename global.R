library(tidyverse)
library(shiny)
library(bslib)
library(googledrive)
library(googlesheets4)

options(
  gargle_oauth_email = TRUE,
  gargle_oauth_cache = ".secrets"
)

googledrive::drive_auth(cache = ".secrets", email = "innovativeopticsdatabase@gmail.com")
googlesheets4::gs4_auth(cache = ".secrets", email = "innovativeopticsdatabase@gmail.com")

sheet_id <- googledrive::drive_get("Dental_data")$id

# our_data <- googlesheets4::read_sheet(sheet_id, sheet = "Lens_details") %>%
#   mutate(VLT = scales::percent(as.numeric(VLT)),
#          `Price(from)` = scales::dollar(as.numeric(`Price(from)`)))
# 
# oem_data <- googlesheets4::read_sheet(sheet_id, sheet = "laser_info") %>%
#   filter(`Laser Mfg` == "AMD")



andau_data <- googlesheets4::read_sheet(sheet_id, sheet = "Loupe_types", col_types = "c")  %>%
  filter(`Mfg` == "Andau") %>%
  rename(`Andau Frame` = Mod, Style = Size, `Innovative Optics Insert` = `Insert Part Number`)

# Load dental data

dental_data <- googlesheets4::read_sheet(sheet_id, sheet = "laser_info") %>%
  mutate(VLT = scales::percent(as.numeric(VLT)))
# 
# dental_data <- readxl::read_excel("Dental_data.xlsx")%>%
#   filter(`Laser Mfg` != "") %>%
#   mutate(VLT = scales::percent(as.numeric(VLT)))
