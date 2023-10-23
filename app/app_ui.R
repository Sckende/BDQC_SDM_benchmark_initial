ui <- dashboardPage(
    dashboardHeader(title = "Explorateur de SDMs"),
    dashboardSidebar(
        # width = "0px"
        selectInput("species_select",
            label = "Species",
            choices = species
        ),
        selectInput("inla_sortie",
            label = "Sortie INLA",
            choices = c("range", "pocc")
        ),
        selectInput("Maxent_sortie",
            label = "Sortie Maxent",
            choices = c("L", "LQ")
        )
    ),
    dashboardBody(
        # First row
        fluidRow(
            box(
                title = "carte e-bird",
                width = 4,
                plotOutput("map_eBird")
            ),
            box(
                title = "carte INLA - auto-corrélation spatiale",
                width = 4,
                plotOutput("map_Vince")
            )
        ),
        # Third row
        fluidRow(
            box(
                title = "carte mapSpecies",
                width = 4
            ),
            box(
                title = "carte Maxent",
                width = 4,
                plotOutput("map_Maxent")
            ),
            box(
                title = "carte BRT",
                width = 4
            )
        )
    )
)
