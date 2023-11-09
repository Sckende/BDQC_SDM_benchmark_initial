ui <- dashboardPage(
    dashboardHeader(title = "Explorateur de SDMs"),
    dashboardSidebar(
        # width = "0px"
        h4("Espèce"),
        selectInput("species_select",
            label = "",
            choices = species
        ),
        h4("Paramétrage"),
        selectInput("predictors",
            label = "Prédicteurs environnementaux",
            choices = c("Predictors", "noPredictors")
        ),
        selectInput("bias",
            label = "Biais d'échantillonnage",
            choices = c("Bias", "noBias")
        ),
        selectInput("spatial",
            label = "Auto-corrélation spatiale",
            choices = c("Spatial", "noSpatial")
        ),
        h4("Modèles INLA"),
        selectInput("inla_sortie",
            label = "Métrique",
            choices = c("pocc", "range")
        ),
        checkboxInput("inla_occs",
            "Occurrences",
            value = FALSE
        ),
        h4("Modèles Maxent"),
        checkboxInput("Maxent_occs",
            "Occurrences",
            value = FALSE
        ),
        checkboxInput("Maxent_pseudo_abs",
            "Pseudo-absence",
            value = FALSE
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
