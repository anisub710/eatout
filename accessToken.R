library("httr")
library("jsonlite")
search.query <- list(grant_type = "client_credentials", client_id = "oUBxMAlVRNvt92rrkhyqCw", 
                     client_secret = 
                       "r084ZHHwidD5SvbKQrbTEvuOVsLn8koFiZTuVqN0nI6j0wBsgdQdPdqO7vddfBz6")
response <- POST("https://api.yelp.com/oauth2/token", query = search.query)
response
body <- fromJSON(content(response, "text"))

access_token <- "yweqTXomlxGi_YeT86B1JhwPr8EdzljgxLPE4dutNuedrLqE_YW1Y_2wWCUPZ4u9QdH6aU-gr8Q7w_QJgsaavt6-auMn53iCwJSMDo557Wviktlu-wBQQSH1b2-uWHYx"

#USE access.code for headers
access.code <- paste0("bearer ", access_token)
#Example of GET call with authorization
# response.first <-GET ("https://api.yelp.com/v3/businesses/search?term=delis&latitude=37.786882&longitude=-122.399972", add_headers(Authorization = access.code))
# body.first <- fromJSON(content(response.first, "text"))    
