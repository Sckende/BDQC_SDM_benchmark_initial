# Load packages
if (!exists("species")) {
    source("/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial/packages_n_local_data.R")
}
# App launch

source("/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial//app/app_ui.R")
source("/home/claire/BDQC-GEOBON/GITHUB/BDQC_SDM_benchmark_initial//app/app_server.R")

shinyApp(ui, server)
