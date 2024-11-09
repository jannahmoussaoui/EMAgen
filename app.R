########################################################################################################################
#                               R Code for the "EMAgen" shiny application
#                                          Jannah R. Moussaoui
########################################################################################################################

#####
# INSTRUCTIONS FOR DEBUGGING/RUNNING LOCALLY:
#####

# (1) Create constants (run lines 11 - 26):
#    ID <- "12345"                                 # ID Number
#    ema_start_date <- as.Date("2025-11-07")       # Date the EMA surveys should start (usually "tomorrow")
#    weekday_wake <- "05:30:00 AM"                 # Typical wake-up time on weekdays
#    weekday_sleep <- "10:00:00 PM"                # Typical sleep time on weekdays
#    weekend_wake <-"07:00:00 AM"                  # Typical wake-up time on weekends
#    weekend_sleep <- "11:00:00 PM"                # Typical sleep time on weekends
#    school_end <- "03:30:00 PM"                   # Typical end time of school
#    timezone <- "America/New_York"                # Participant's timezone
#    SURVEY_WAKE <- 21623                          # ID of the morning surveys
#    SURVEY_MOMENTARY <- 22175                     # ID of the momentary surveys
#    SURVEY_SLEEP <- 22176                         # ID of the bedtime surveys
#    PROTOCOL_DURATION <- 22                       # Number of days in EMA protocol (Day 0 through Day 14)
#    MOMENT_REPS <- 5                              # Number of times momentary surveys repeat within-day
#    HOUR_BUFFER <- 3600                           # 3600 second buffer (1 hour)
#    DAY_BUFFER <- 86400                           # 86400 second buffer (24 hours)
#    FORMAT <- "%Y-%m-%d %I:%M:%S %p"              # Time formatting
#
# (2) Load packages (run lines 40 - 43)
#
# (3) Create functions (run lines 250 - 340)
#
# (4) Create dataframe (run lines 344 - 417)


#####
# SET UP
#####

# Call Packages
library(shiny)
library(bslib)
library(lubridate)
library(openxlsx)

# Define the custom theme
custom_theme <- bs_theme(
  bg = "#FAF4EE",
  fg = "#000000",
  primary = "#B67754", 
  secondary = "#ffffff" 
)

# Define a custom CSS
custom_css <- "
body {
  font-family: 'Raleway', sans-serif;
  background-image: url('background.svg');
  background-size: cover;
  background-repeat: no-repeat;
  background-attachment: fixed;
  background-position: center;
  margin: 0;
  padding: 0;
  font-size: 19px; /* Optional: Adjust font size */
}

.card {
  background-color: #B67754 !important;
  font-size: 15px; /* Optional: Adjust font size */
  color: #ffffff !important; /* Set text color inside cards */
}

.card-content {
  font-weight: normal;
  font-size: 19px; /* Optional: Adjust font size */
  color: #ffffff; /* Set normal text color to white */
  line-height: 1.25; /* Adjust line height for single spacing */
}

.card-content img {
  display: block;
  margin-left: auto;
  margin-right: auto;
  height: 100px; /* Set the height of the logo */
}

.card-inner {
  background-color: #FAF4EE !important;
  font-size: 15px; /* Optional: Adjust font size */
  color: #B67754 !important; /* Set text color inside these specific cards */
}

.btn-container {
    display: flex;
    justify-content: flex-start; /* Align items to the start */
    gap: 10px; /* Space between buttons */
}

.btn-container button {
    background: #B67754; /* Set the background for buttons */
    color: #FAF4EE; /* Text color for buttons */
    border: none; /* Remove border if you want */
    padding: 10px 15px; /* Add padding for better appearance */
    cursor: pointer; /* Change cursor to pointer on hover */
}

.btn-container button:hover {
    background: #7B4E35; /* Darken on hover for better UX */
}

.btn {
    background: #B67754 !important; /* Set the background for buttons */
    color: #FAF4EE !important; /* Text color for buttons */
    border: none !important; /* Remove border if you want */
    padding: 10px 15px; /* Add padding for better appearance */
    cursor: pointer; /* Change cursor to pointer on hover */
    font-size: 15px; /* Optional: Adjust font size */
}

.btn:hover {
    background: #7B4E35 !important; /* Darken on hover for better UX */
}

/* Override Shiny's default notification styles */
.shiny-notification {
  background-color: #B67754 !important; /* Dark purple background */
  color: #ffffff !important; /* White text */
  border: none !important; /* No border */
  font-family: 'Raleway', sans-serif; /* Match font family */
  font-weight: bold; /* Make the text bold */
  padding: 10px; /* Add some padding */
  border-radius: 5px; /* Round the corners */
  box-shadow: none; /* Remove shadow if necessary */
}
"

#####
# DEFINE SHINY USER INTERFACE
#####

ui <- fluidPage(
  theme = custom_theme,  # Apply the custom theme
  tags$head(
    tags$link(rel = "stylesheet"),
    tags$style(HTML(custom_css))
  ),
  div(style = "padding-top: 20px;", # Add space between the top of the cards and the top of the window
      fluidRow(
        column(4, 
               card(
                 div(class = "card-content", 
                     h1(strong("Overview")), 
                     p("Ecological momentary assessment (EMA) involves repeated sampling of a person's cognitions or behaviors, typically through
                       brief surveys sent to a smartphone. To increase compliance, researchers often tailor survey trigger times to participants' wake-up and bedtimes
                       times such that surveys are only sent during waking hours. However, wake/sleep times vary between weekdays vs. weekends and, for adolescents,
                       potentially even between the school year vs. summer. When working with adolescents, researchers may additionally need to block surveys from coming
                       during school hours. Unfortunately, most EMA platforms do not allow for this level of personalization. Therefore, we created EMAgen, an
                       openly accessible shiny application that automates generation of personalized schedules which can then be uploaded to EMA platforms."),
                     h4(strong("Instructions")),
                     p("By default, this application will generate 5 surveys a day for 22 days. The first survey will come within 1 hour of waking
                       up and the last survey will come within 1 hour of going to bed. When no school end time is specified, the remaining three surveys
                       will come at semi-random times between the first and last surveys, but never within an hour of one another. When a school-end time is specified,
                       the surveys will come at random times between the end of school and the last survey. Parameters can be adjusted according to study protocols."),
                     h4(strong("Reference")),
                     p("Moussaoui, J.R. & D’Adamo, L. (2024). EMAgen. https://jannahmoussaoui.shinyapps.io/EMAgen/"),
                     p("All code is openly available on GitHub: https://github.com/jannahmoussaoui/EMAgen")
                 )
               )
        ),
        column(8, 
               card(
                 div(class = "card-content", 
                     img(src = "logo.svg", height = "100px")
                 ),
                 fluidRow(
                   column(6, card(class = "card-inner", div(class = "card-inner", 
                                                            h4(strong("EMA Protocol Parameters")),
                                                            textInput("SURVEY_WAKE", "Morning Survey ID", value = "999"),
                                                            textInput("SURVEY_MOMENTARY", "Momentary Survey ID", value = "888"),
                                                            textInput("SURVEY_SLEEP", "Nighttime Survey ID", value = "777"),
                                                            textInput("PROTOCOL_DURATION", "Number of Days", value = "22"),
                                                            textInput("MOMENT_REPS", "Number of Surveys", value = "5")))),
                   column(6, card(class = "card-inner", div(class = "card-inner", 
                                                            h4(strong("Participant Information")),
                                                            textInput("ID", "Avicenna ID", value = "123"),
                                                            dateInput("ema_start_date", "EMA Start Date", value = as.Date("2024-01-01")),
                                                            textInput("weekday_wake", "Weekday Wake-up Time", value = "07:00:00 AM"),
                                                            textInput("weekday_sleep", "Weekday Sleep Time", value = "11:30:00 PM"),
                                                            textInput("weekend_wake", "Weekend Wake-up Time", value = "11:00:00 AM"),
                                                            textInput("weekend_sleep", "Weekend Sleep Time", value = "01:30:00 AM"),
                                                            selectInput("timezone", "Timezone",
                                                                        choices = c("America/New_York", "America/Chicago", "America/Denver", "America/Los_Angeles"),
                                                                        selected = "America/New_York"),
                                                            selectInput("in_school", "Is the teen currently in school?",
                                                                        choices = c("Yes", "No"),
                                                                        selected = "No"),
                                                            conditionalPanel(
                                                              condition = "input.in_school == 'Yes'",
                                                              textInput("school_end", "School End Time", value = "03:30:00 PM")),
                                                            div(class = "btn-container",
                                                                actionButton("generate", "Generate"),
                                                                downloadButton("download", "Download Schedule")
                                                            ))))
                 )
               )
        )
      )
  )
)

#####
# DEFINE SHINY SERVIER LOGIC
#####

server <- function(input, output) {
  today_date <- format(Sys.Date(), "%m.%d.%y")
  options(scipen = 999)
    # Create a reactive value to store schedule_df
  schedule_df <- reactiveVal(NULL)
  schedule_nonepochs_df <- reactiveVal(NULL)
  metadata_df <- reactiveVal(NULL)
  
  observeEvent(input$generate, {
    # Get input values
    ID <- input$ID
    ema_start_date <- input$ema_start_date
    weekday_wake <- input$weekday_wake
    weekday_sleep <- input$weekday_sleep
    weekend_wake <- input$weekend_wake
    weekend_sleep <- input$weekend_sleep
    school_end <- input$school_end
    timezone <- input$timezone
    in_school <- input$in_school
    SURVEY_WAKE <- input$SURVEY_WAKE
    SURVEY_MOMENTARY <- input$SURVEY_MOMENTARY
    SURVEY_SLEEP <- input$SURVEY_SLEEP
    PROTOCOL_DURATION <- as.numeric(input$PROTOCOL_DURATION) 
    MOMENT_REPS <- as.numeric(input$MOMENT_REPS)
    
    # Handle school status
    school_end <- if (in_school == "No") FALSE else school_end
    
    # Define constants
    HOUR_BUFFER <- 3600
    DAY_BUFFER <- 86400
    FORMAT <- "%Y-%m-%d %I:%M:%S %p"
    
    # CREATE FUNCTIONS
    # (1) Function generate_random_time() to generate random time within a defined window
    generate_random_time <- function(window_open, window_close) {
      if (is.na(window_open) | is.na(window_close) | window_open >= window_close) {
        return(NA)
      }
      random_time <- runif(1, as.numeric(window_open), as.numeric(window_close))
      momentary_time <- as.POSIXct(random_time, origin = "1970-01-01", tz = timezone)
      formatted_time <- format(momentary_time, "%Y-%m-%d %I:%M:%S %p %Z")
      return(formatted_time)
    }
    
    # (2) Function get_window_wake() to get the wake window
    get_window_wake <- function(date) {
      if (weekdays(date) %in% c("Saturday", "Sunday")) {
        window_open <- as.POSIXct(paste(date, weekend_wake), format = FORMAT, tz = timezone)
        window_close <- window_open + HOUR_BUFFER
      } else {
        window_open <- as.POSIXct(paste(date, weekday_wake), format = FORMAT, tz = timezone)
        window_close <- window_open + HOUR_BUFFER
      }
      return(list(window_open = window_open, window_close = window_close))
    }
    
    # (3) Function get_window_sleep() to get the sleep window
    get_window_sleep <- function(date) {
      if (weekdays(date) %in% c("Friday", "Saturday")) {
        window_close <- as.POSIXct(paste(date, weekend_sleep), format = FORMAT, tz = timezone)
        if (hour(window_close) < 12) {
          window_close <- window_close + DAY_BUFFER
        }
        window_open <- window_close - HOUR_BUFFER
      } else {
        window_close <- as.POSIXct(paste(date, weekday_sleep), format = FORMAT, tz = timezone)
        if (hour(window_close) < 12) {
          window_close <- window_close + DAY_BUFFER
        }
        window_open <- window_close - HOUR_BUFFER
      }
      return(list(window_open = window_open, window_close = window_close))
    }
    
    # (4) Function get_window_momentary() to get the momentary window
    get_window_momentary <- function(date) {
      if (weekdays(date) %in% c("Saturday", "Sunday")) {
        window_open <- as.POSIXct(paste(date, weekend_wake), format = FORMAT, tz = timezone) + HOUR_BUFFER
        window_close <- as.POSIXct(paste(date, weekend_sleep), format = FORMAT, tz = timezone) - HOUR_BUFFER
      } else {
        window_open <- as.POSIXct(paste(date, weekday_wake), format = FORMAT, tz = timezone) + HOUR_BUFFER
        window_close <- as.POSIXct(paste(date, weekday_sleep), format = FORMAT, tz = timezone) - HOUR_BUFFER
      }
      # Ensure the window times are logical
      if (window_open >= window_close) {
        window_close <- window_close + DAY_BUFFER
      }
      return(list(window_open = window_open, window_close = window_close))
    }
    
    # (5) Function get_window_school() to get the school window
    get_window_school <- function(date) {
      window_open <- as.POSIXct(paste(date, school_end), format = FORMAT, tz = timezone)
      window_close <- window_open + HOUR_BUFFER
      
      # Ensure the window times are logical
      if (window_open >= window_close) {
        window_close <- window_close + DAY_BUFFER
      }
      
      return(list(window_open = window_open, window_close = window_close))
    }
    
    # (6) Function get_window_post_school() to get the post-school window
    get_window_post_school <- function(date) {
      window_open <- as.POSIXct(paste(date, school_end), format = FORMAT, tz = timezone) + HOUR_BUFFER
      window_close <- as.POSIXct(paste(date, weekday_sleep), format = FORMAT, tz = timezone) - HOUR_BUFFER
      
      # Ensure the window times are logical
      if (window_open >= window_close) {
        window_close <- window_close + DAY_BUFFER
      }
      
      return(list(window_open = window_open, window_close = window_close))
    }
    
    # (7) Function to check if time is within one hour of any existing time
    is_within_one_hour <- function(new_time, existing_times) {
      for (existing_time in existing_times) {
        if (abs(difftime(new_time, existing_time, units = "secs")) < 3600) {
          return(TRUE)
        }
      }
      return(FALSE)
    }
    
    # CREATE SCHEDULE
    # (1) Initialize empty data frame to store the schedule
    schedule_df <- data.frame(user_id = character(),
                              activity_id = numeric(),
                              scheduled_time = character(),
                              stringsAsFactors = FALSE)
    
    # (2) Morning Surveys (daily within 1 hour of wake up)
    for (i in 1:PROTOCOL_DURATION) {
      current_date <- ema_start_date + days(i)
      time_window <- get_window_wake(current_date)
      survey_time <- generate_random_time(time_window$window_open, time_window$window_close)
      survey_time_posix <- as.POSIXct(survey_time, format = FORMAT, tz = timezone)
      schedule_df <- rbind(schedule_df, data.frame(user_id = ID,
                                                   activity_id = SURVEY_WAKE,
                                                   scheduled_time = survey_time))
    }
    
    # (3) Night Surveys (daily within 1 hour of sleep)
    for (i in 1:PROTOCOL_DURATION) {
      current_date <- ema_start_date + days(i)
      time_window <- get_window_sleep(current_date)
      repeat {
        survey_time <- generate_random_time(time_window$window_open, time_window$window_close)
        survey_time_posix <- as.POSIXct(survey_time, format = FORMAT, tz = timezone)
        if (!is_within_one_hour(survey_time_posix, as.POSIXct(schedule_df$scheduled_time, format = FORMAT, tz = timezone))) {
          break
        }
      }
      schedule_df <- rbind(schedule_df, data.frame(user_id = ID,
                                                   activity_id = SURVEY_SLEEP,
                                                   scheduled_time = survey_time))
    }
    
    # (4) Momentary Surveys
    # Drop first and last
    MOMENT_REPS <- MOMENT_REPS - 2
    
    for (i in 1:PROTOCOL_DURATION) {
      current_date <- ema_start_date + days(i)
      if (weekdays(current_date) %in% c("Saturday", "Sunday") || school_end == FALSE) {
        # 3x day between wake-up and bed
        for (j in 1:MOMENT_REPS) {
          time_window <- get_window_momentary(current_date)
          repeat {
            survey_time <- generate_random_time(time_window$window_open, time_window$window_close)
            survey_time_posix <- as.POSIXct(survey_time, format = FORMAT, tz = timezone)
            if (!is_within_one_hour(survey_time_posix, as.POSIXct(schedule_df$scheduled_time, format = FORMAT, tz = timezone))) {
              break
            }
          }
          schedule_df <- rbind(schedule_df, data.frame(user_id = ID,
                                                       activity_id = SURVEY_MOMENTARY,
                                                       scheduled_time = survey_time))
        }
      } else {
        # 1x between school end and 1 hour after; 2x between 1 hour post-school and 1 hour before bed
        for (j in 1:MOMENT_REPS) {
          if (j == 1) {
            time_window <- get_window_school(current_date)
          } else {
            time_window <- get_window_post_school(current_date)
          }
          repeat {
            survey_time <- generate_random_time(time_window$window_open, time_window$window_close)
            survey_time_posix <- as.POSIXct(survey_time, format = FORMAT, tz = timezone)
            if (!is_within_one_hour(survey_time_posix, as.POSIXct(schedule_df$scheduled_time, format = FORMAT, tz = timezone))) {
              break
            }
          }
          schedule_df <- rbind(schedule_df, data.frame(user_id = ID,
                                                       activity_id = SURVEY_MOMENTARY,
                                                       scheduled_time = survey_time))
        }
      }
    }
    
    
    schedule_nonepochs <- schedule_df
    metadata <- data.frame(
      ID = ID,
      ema_start_date = ema_start_date,
      weekday_wake = weekday_wake,
      weekday_sleep = weekday_sleep,
      weekend_wake = weekend_wake,
      weekend_sleep = weekend_sleep,
      school_end = school_end,
      timezone = timezone,
      stringsAsFactors = FALSE
    )
    
    schedule_df$scheduled_time <- ymd_hms(schedule_df$scheduled_time, tz = timezone)
    schedule_df$scheduled_time <- as.numeric(schedule_df$scheduled_time) * 1000
    
    # Store the schedule in the reactive value
    schedule_df(schedule_df)
    schedule_nonepochs_df(schedule_nonepochs)
    metadata_df(metadata)
    
    showNotification("Sessions Generated!", type = "message", duration = 3)
  })
  
  output$download <- downloadHandler(
    filename = function() {
      paste(input$ID, ".zip", sep = "")
    },
    content = function(file) {
      # Create a temporary directory to store the CSV files
      temp_dir <- tempdir()
      
      # Write schedule_df to CSV
      schedule_file <- paste(temp_dir, paste(input$ID, "_session_epochs_", today_date, ".csv", sep = ""), sep = "/")
      write.csv(schedule_df(), schedule_file, row.names = FALSE, quote = FALSE)
      
      # Write schedule_nonepochs_df to CSV
      schedule_nonepochs_file <- paste(temp_dir, paste(input$ID, "_session_human_", today_date, ".csv", sep = ""), sep = "/")
      write.csv(schedule_nonepochs_df(), schedule_nonepochs_file, row.names = FALSE, quote = FALSE)
      
      # Write metadata_df to CSV
      metadata_file <- paste(temp_dir, paste(input$ID, "_metadata_", today_date, ".csv", sep = ""), sep = "/")
      write.csv(metadata_df(), metadata_file, row.names = FALSE, quote = FALSE)
      
      # Create a zip file containing all CSV files
      zip::zipr(zipfile = file, files = c(schedule_file, schedule_nonepochs_file, metadata_file))
    }
  )
}

#####
# CALL APPLICATION
#####

shinyApp(ui, server)
