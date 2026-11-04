# Melbourne Airport heat explorer
#
# Intended user: a council or emergency-planning officer who has to say
# whether hot weather is becoming more frequent.
# Question: have days above a chosen temperature become more frequent at
# Melbourne Airport since 1970, and does the answer depend on what counts
# as "hot"?
#
# All calculations and charts come from the melbheat package, so the app only
# handles inputs and layout. The reactive chain is
#   inputs -> exceed() -> usable() -> periods() -> said() / trend_plot()
#   inputs -> sens()   (threshold tab)
# Each step does one job and stops early with a helpful message (validate())
# when the choice cannot produce a result.

library(shiny)
library(bslib)

measure_info <- list(
  tmax = list(noun = "hot days", range = c(25, 45), default = 35),
  tmin = list(noun = "hot nights", range = c(10, 28), default = 20)
)

accent <- "#b45309"
ink <- "#1f2933"

# ---- User interface ------------------------------------------------------
ui <- page_sidebar(
  title = "Are hot days getting more common at Melbourne Airport?",
  fillable = FALSE,
  theme = bs_theme(
    version = 5,
    bg = "#fffdf9",
    fg = ink,
    primary = accent,
    secondary = "#475569",
    base_font = font_collection("system-ui", "-apple-system", "Segoe UI",
                                "Roboto", "Helvetica Neue", "sans-serif")
  ),
  tags$head(tags$link(rel = "stylesheet", href = "app.css")),

  sidebar = sidebar(
    width = 340,
    h2("Choose your definition of \"hot\"", class = "side-title"),
    radioButtons(
      "measure", "1. What are you counting?",
      choices = c("Hot days (daily maximum)" = "tmax",
                  "Hot nights (daily minimum)" = "tmin")
    ),
    sliderInput("threshold", "2. A day counts if it is above",
                min = 25, max = 45, value = 35, step = 1, post = " \u00B0C"),
    helpText("35 \u00B0C is a common benchmark for a hot day and 20 \u00B0C for a hot night.",
             " Move the slider to test other definitions."),
    checkboxGroupInput(
      "months", "3. Months to include",
      choices = setNames(1:12, month.abb), selected = 1:12, inline = TRUE
    ),
    div(class = "preset-row",
        actionButton("whole_year", "Use whole year", class = "btn-sm btn-outline-secondary"),
        actionButton("summer", "Use summer only (Dec\u2013Feb)", class = "btn-sm btn-outline-secondary")),
    hr(),
    h2("Compare two periods", class = "side-title"),
    sliderInput("split_year", "4. Compare years up to \u2026 with years after",
                min = 1985, max = 2015, value = 2000, step = 1, sep = ""),
    checkboxInput("advanced", "Show advanced setting", value = FALSE),
    conditionalPanel(
      "input.advanced",
      sliderInput("min_cov", "5. Smallest share of days a year must have recorded",
                  min = 50, max = 100, value = 80, step = 5, post = "%"),
      helpText("Years with fewer recorded days are greyed out and left out of the averages,",
               " because missing days make their counts too low.")
    )
  ),

  navset_card_tab(
    nav_panel(
      "See the trend",
      div(class = "brief",
          p(strong("For: "), "council and emergency-planning officers who need to say whether",
            " hot weather is becoming more frequent."),
          p(strong("Question: "), "Have days above a chosen temperature become more frequent",
            " at Melbourne Airport since 1970, and does the answer change with what you",
            " count as \"hot\"?"),
          p(strong("It cannot tell you: "), "why temperatures changed, or what happened in",
            " other parts of Melbourne.")),
      uiOutput("results"),
      p(class = "limit-note",
        strong("Keep in mind: "),
        "this is one weather station at the airport, so it does not represent every suburb.",
        " Readings are as recorded and are not adjusted for changes in instruments or site.")
    ),
    nav_panel(
      "Does the threshold matter?",
      h3("Is the answer the same for other definitions of a hot day?",
         class = "table-title"),
      uiOutput("sens_results"),
      p(class = "limit-note",
        strong("Keep in mind: "),
        "the same two periods and months from the sidebar are used at every threshold,",
        " so changing them changes this chart too.")
    ),
    nav_panel(
      "Guide",
      div(
        class = "guide",
        h3("How to use the controls"),
        tags$ol(
          tags$li(strong("What are you counting? "),
                  "Hot days use each day's highest temperature; hot nights use each",
                  " night's lowest temperature."),
          tags$li(strong("Threshold. "),
                  "A day is counted when its temperature is strictly above this value. The",
                  " range and default change with the measure."),
          tags$li(strong("Months. "),
                  "Restrict the count to some months, for example December to February."),
          tags$li(strong("Compare years. "),
                  "Splits the record into years up to the chosen year and years after it."),
          tags$li(strong("Advanced setting. "),
                  "The smallest share of days a year must have recorded to be trusted.")
        ),
        h3("The fields behind the charts"),
        tags$table(
          class = "table table-sm field-table",
          tags$thead(tags$tr(tags$th("Field"), tags$th("Meaning"))),
          tags$tbody(
            tags$tr(tags$td("tmax / tmin"), tags$td("Daily maximum / minimum temperature (\u00B0C) at Melbourne Airport, Bureau of Meteorology station 086282.")),
            tags$tr(tags$td("n_days"), tags$td("Calendar days in the chosen months of that year.")),
            tags$tr(tags$td("n_observed"), tags$td("Days with a recorded temperature.")),
            tags$tr(tags$td("n_exceed"), tags$td("Observed days above your threshold. This is the bar height.")),
            tags$tr(tags$td("coverage"), tags$td("n_observed divided by n_days. A year below your smallest-share setting is grey.")),
            tags$tr(tags$td("Average days per year"), tags$td("Mean of n_exceed over the years with enough data in a period.")),
            tags$tr(tags$td("Typical swing (SD)"), tags$td("Standard deviation of the yearly counts: how much single years differ from their average.")),
            tags$tr(tags$td("Ratio"), tags$td("Later average divided by earlier average. 1.4 means 40% more hot days."))
          )
        ),
        h3("How to read the outputs"),
        tags$ul(
          tags$li("Start with the box at the top of ", em("See the trend"),
                  ": it says what changed and how sure we can be."),
          tags$li("The range given there is rough: it treats years as independent. If it",
                  " includes zero, the two periods are not clearly different."),
          tags$li("Then open ", em("Does the threshold matter?"),
                  ". A finding that holds at 30, 35 and 40 \u00B0C does not depend on one cut-off.")
        ),
        h3("Limitations"),
        tags$ul(
          tags$li("One station, at the airport. It does not represent every suburb."),
          tags$li("Values are as recorded, not adjusted for instrument or site changes. Recent",
                  " values may not be fully quality controlled."),
          tags$li("The record starts mid-1970 and ends in July 2022, so those two years are",
                  " greyed out."),
          tags$li("Comparing two averages describes the data; it does not explain the cause."),
          tags$li("Years are calendar years, so a summer from December to February is split",
                  " across two years.")
        ),
        p(class = "source",
          "Source: Australian Bureau of Meteorology, Climate Data Online, Melbourne Airport",
          " (086282). Copyright Commonwealth of Australia.")
      )
    )
  )
)

# ---- Server --------------------------------------------------------------
server <- function(input, output, session) {

  # Changing the measure resets the threshold slider to a sensible range.
  observeEvent(input$measure, {
    info <- measure_info[[input$measure]]
    updateSliderInput(session, "threshold",
                      min = info$range[1], max = info$range[2],
                      value = info$default)
  })

  observeEvent(input$whole_year, {
    updateCheckboxGroupInput(session, "months", selected = 1:12)
  })
  observeEvent(input$summer, {
    updateCheckboxGroupInput(session, "months", selected = c(12, 1, 2))
  })

  # Step 1: yearly counts for the chosen definition of "hot".
  exceed <- reactive({
    validate(need(
      length(input$months) > 0,
      "Choose at least one month in the sidebar to see results."
    ))
    melbheat::annual_exceedances(
      variable = input$measure,
      threshold = input$threshold,
      months = as.integer(input$months),
      min_coverage = input$min_cov / 100
    )
  })

  # Step 2: stop with a clear message if no year has enough data, or no day
  # ever goes above the threshold.
  usable <- reactive({
    ex <- exceed()
    validate(
      need(any(ex$reliable),
           paste0("No year has at least ", input$min_cov,
                  "% of its days recorded for these months. ",
                  "Choose more months, or lower the smallest share of days under Advanced setting.")),
      need(sum(ex$n_exceed[ex$reliable]) > 0,
           paste0("No year had a day above ", input$threshold,
                  " \u00B0C in these months. Lower the threshold to see counts."))
    )
    ex
  })

  # Step 3: average annual count before and after the chosen year, and a
  # plain-language reading of the gap.
  periods <- reactive(melbheat::summarise_periods(usable(), input$split_year))
  said <- reactive(melbheat::describe_periods(periods()))

  # One plot object is shared by the screen and the PNG download.
  trend_plot <- reactive(melbheat::plot_exceedances(usable(), input$split_year))

  # One block holds the whole result. If the choices cannot produce a result,
  # usable() stops here and the user sees a single helpful message instead of
  # several empty outputs (see validate() in the steps above).
  output$results <- renderUI({
    usable()
    tagList(
      uiOutput("headline"),
      plotOutput("trend_plot", height = "420px", fill = FALSE),
      p(class = "reading-hint",
        strong("How to read this chart: "),
        "each bar is one year; a taller bar means more days above your threshold.",
        " The dark lines are the averages before and after the dashed line. Compare the gap",
        " between them with how much single years bounce around."),
      div(class = "download-row",
          downloadButton("download_png", "Download chart (PNG)",
                         class = "btn-sm btn-outline-secondary"),
          downloadButton("download_csv", "Download yearly counts (CSV)",
                         class = "btn-sm btn-outline-secondary")),
      h3("Period averages", class = "table-title"),
      tableOutput("period_table"),
      textOutput("data_note")
    )
  })

  output$headline <- renderUI({
    d <- said()
    validate(need(d$enough_data, paste(d$headline, d$how_sure)))
    div(
      class = "takeaway",
      p(strong("What this shows: "), d$headline),
      p(class = "how-sure", strong("How sure are we? "), d$how_sure)
    )
  })

  output$trend_plot <- renderPlot(
    trend_plot(),
    alt = "Bar chart of the number of days each year above the chosen temperature, with lines showing the average before and after the chosen year."
  )

  output$period_table <- renderTable({
    p <- periods()
    dash <- "\u2013"
    data.frame(
      Period = p$period,
      Years = ifelse(p$n_years > 0, paste0(p$first_year, dash, p$last_year), dash),
      `Years with enough data` = p$n_years,
      `Average days per year` = ifelse(p$n_years > 0, sprintf("%.1f", p$mean_exceed), dash),
      `Typical swing (SD)` = ifelse(is.na(p$sd_exceed), dash, sprintf("%.1f", p$sd_exceed)),
      `Lowest to highest year` = ifelse(p$n_years > 0,
                                        paste0(p$min_exceed, dash, p$max_exceed), dash),
      check.names = FALSE
    )
  }, striped = TRUE, spacing = "s", width = "100%")

  output$data_note <- renderText({
    ex <- exceed()
    sprintf("%d of %d years have at least %d%% of their days recorded for the chosen months; the others are greyed out and excluded from the averages.",
            sum(ex$reliable), nrow(ex), input$min_cov)
  })

  # Threshold tab: repeat the comparison across many thresholds.
  sens <- reactive({
    validate(need(
      length(input$months) > 0,
      "Choose at least one month in the sidebar to see results."
    ))
    s <- melbheat::threshold_sensitivity(
      variable = input$measure,
      months = as.integer(input$months),
      split_year = input$split_year,
      min_coverage = input$min_cov / 100
    )
    validate(need(
      any(!is.na(s$difference)),
      paste0("No threshold has enough data in both periods. ",
             "Move the comparison year or choose more months.")
    ))
    s
  })

  output$sens_results <- renderUI({
    sens()
    tagList(
      plotOutput("sens_plot", height = "420px", fill = FALSE),
      p(class = "reading-hint",
        strong("How to read this chart: "),
        "each point is one threshold. If the orange line (later years) sits above the grey",
        " line everywhere, the finding does not hinge on one cut-off. The gap gets smaller in",
        " days at high thresholds simply because hot days become rare, so check the ratio",
        " in the table. The dashed line is your chosen threshold."),
      tableOutput("sens_table")
    )
  })

  output$sens_plot <- renderPlot(
    melbheat::plot_sensitivity(sens(), highlight = input$threshold),
    alt = "Line chart of the average number of days per year in the earlier and later period for different temperature thresholds."
  )

  output$sens_table <- renderTable({
    s <- sens()
    tab <- data.frame(
      s$threshold,
      sprintf("%.1f", s$mean_before),
      sprintf("%.1f", s$mean_after),
      sprintf("%+.1f", s$difference),
      ifelse(is.na(s$ratio), "\u2013", sprintf("%.2f", s$ratio))
    )
    names(tab) <- c("Threshold (\u00B0C)", "Earlier average", "Later average",
                    "Difference (days a year)", "Ratio (later / earlier)")
    tab
  }, striped = TRUE, spacing = "xs", width = "100%")

  # Downloads say what they contain and carry a useful default file name.
  file_stub <- reactive({
    sprintf("melbheat_%s_above_%sC",
            if (input$measure == "tmax") "hot-days" else "hot-nights",
            input$threshold)
  })
  output$download_csv <- downloadHandler(
    filename = function() paste0(file_stub(), "_yearly-counts.csv"),
    content = function(file) utils::write.csv(usable(), file, row.names = FALSE)
  )
  output$download_png <- downloadHandler(
    filename = function() paste0(file_stub(), "_chart.png"),
    content = function(file) {
      ggplot2::ggsave(file, plot = trend_plot(), device = "png",
                      width = 10, height = 6, dpi = 150, bg = "white")
    }
  )
}

shinyApp(ui, server)
