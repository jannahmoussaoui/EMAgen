# Overview
**Contributors:** Jannah R. Moussaoui & Laura D'Adamo

Ecological momentary assessment (EMA) involves repeated sampling of a person's 
cognitions or behaviors, typically through brief surveys sent to a smartphone. 
To increase compliance, researchers often tailor survey trigger times to participants' 
sleep/wake times such that surveys are only sent during waking hours. However, sleep/wake
times vary between weekdays vs. weekends and, for adolescents, potentially even between the
school year vs. summer. When working with adolescents, researchers may additionally need to 
block surveys from coming during school hours. Unfortunately, most EMA platforms do not allow 
for this level of personalization. Therefore, we created EMAgen, an openly accessible shiny 
application that automates generation of personalized schedules which can then be uploaded as a
CSV file to EMA platforms.

By default, this application will generate 5 surveys a day for 22 days. The first survey will 
come within 1 hour of waking up and the last survey will come within 1 hour of going to bed. 
When no school end time is specified, the remaining three surveys will come at semi-random
times between the first and last surveys, but never within an hour of one another.
When a school-end time is specified, the surveys will come at random times between the end of
school and the last survey. Parameters can be adjusted according to individual study protocols.
Further, code for this application is open source.

# Resources

- [Mastering R Shiny](https://mastering-shiny.org/)


